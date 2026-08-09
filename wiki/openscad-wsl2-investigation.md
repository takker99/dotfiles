# OpenSCAD が WSL2 環境で起動できない問題の調査と解決策

## 症状

`openscad`(引数なし)を実行すると、Qt が GLX の FBConfig を見つけられず `Could not initialize GLX` で SIGABRT:

```
qt.glx: qglx_findConfig: Failed to finding matching FBConfig for
  QSurfaceFormat(version 2.0, options ..., depthBufferSize 0,
                 redBufferSize 1, greenBufferSize 1, blueBufferSize 1,
                 alphaBufferSize -1, stencilBufferSize 0, samples -1,
                 swapBehavior SingleBuffer, profile CompatibilityProfile)
...
Could not initialize GLX
fish: ジョブ 1 ('openscad') はシグナル SIGABRT (中断(アボート)) により強制終了されました
```

`wsl --shutdown` 後の再起動では解消せず。

## 環境

- **WSL2** (カーネル `6.18.33.2-microsoft-standard-WSL2`)
- Ubuntu 24.04 (Noble)
- `DISPLAY=:0`、`WAYLAND_DISPLAY=wayland-0` の両方が設定されている
- `/dev/dri/` 無し、`/dev/dxg` のみ存在 → WSLg の GPU パススルーが効いていない
- `glxgears -info` は正常動作 → `GL_RENDERER = llvmpipe (LLVM 20.1.2)` でソフトウェア OpenGL が走っている
- OpenSCAD は **Nix でインストール**されている
  (`/home/takker/.nix-profile/bin/openscad` →
  `/nix/store/9nvrkik7pyhila4aprh6bsj09hc04qyf-openscad-unstable-...`)

## 調査

### 1. コマンドライン出力は成功

`openscad -o out.stl design.scad` は GUI を起動せず CGAL/Manifold 経由で動作:

```
$ openscad -o /tmp/opencode/test.stl /tmp/opencode/test.scad
Geometries in cache: 1
...
Top level object is a 3D object (PolySet):
   Convex:       yes
   Facets:        18
```

→ STL 等のエクスポートは GPU 不要。GUI が落ちているだけ。

### 2. Xwayland の FBConfig を実地検証

Python + ctypes で `glXGetFBConfigs` / `glXChooseFBConfig` を叩いた結果:

| 問い合わせ | 結果 |
|---|---|
| 全 FBConfigs | 384 件 |
| 属性なしで取得 | 240 件(うち RGB 対応 240, DB=1 は 256, 深度分布 {0:96, 16:96, 24:192}) |
| `RENDER_TYPE = GLX_RGBA_BIT (0x1)` | 240 件 |
| `RENDER_TYPE = 0x8014`(シンボリック) | **0 件** |
| Qt のリクエスト(RENDER_TYPE=0x8014, X_VISUAL_TYPE=TRUE_COLOR, RGB≥1, D=0, S=0, DB=1) | **0 件** |

- Xwayland は `RENDER_TYPE` を **bitmask 値 7**(`RGBA_BIT | CI_BIT | PD_BIT`)で公開している
- Qt 5 の `QGLWidget` は `glXChooseFBConfig` に `RENDER_TYPE = 0x8014`(シンボリック)を渡してくる
- bitwise で `0x8014 & 0x7 = 0` となり、**どの FBConfig にもマッチしない**

→ これが GLX 失敗の直接原因。X11 側をいくら調整しても Qt 側のクエリが変わらない限り解決しない。

### 3. Wayland EGL パスも壊れている

```
$ QT_QPA_PLATFORM=wayland openscad
qt.qpa.wayland: EGL not available
```

Nix の OpenSCAD パッケージを `ldd` して依存を辿ると:

```
libqwayland-egl.so → libEGL.so.1 (libglvnd 1.7.0)
                    libwayland-client.so.0
                    libwayland-egl.so.1
                    ...
```

ところが Nix ストア内に **Mesa の実装がない**:

| 確認項目 | 結果 |
|---|---|
| `libEGL_mesa.so*` in `/nix/store` | **無し** |
| `libGLX_mesa.so*` in `/nix/store` | **無し** |
| `swrast_dri.so` in `/nix/store` | **無し** |
| システムの `/usr/lib/x86_64-linux-gnu/dri/swrast_dri.so` | あり(`libdril_dri.so` への symlink) |
| システムの `/usr/lib/x86_64-linux-gnu/libEGL_mesa.so.0` | あり |

→ Nix の `libEGL.so.1` は glvnd のディスパッチャだけで、Mesa バックエンドが
  ないため EGL を初期化できない。Wayland EGL パスは立ち上がらない。

### 4. EGL の状態を直接確認

```python
libEGL.eglGetDisplay(EGL_DEFAULT_DISPLAY)  # OK: handle 取得
libEGL.eglInitialize(...)                  # OK: 1.5
```

ただし冒頭で:

```
libEGL warning: DRI3 error: Could not get DRI3 device
libEGL warning: Ensure your X server supports DRI3 to get accelerated rendering
```

`vendor / version / apis / exts` クエリは全部 `None` を返す。EGL は初期化はする
が、レンダリングに使える構成を返せない状態。

### 5. 試した Qt 環境変数(全部だめ)

| 環境変数 | 結果 |
|---|---|
| `QT_OPENGL=software` | 変化なし(GLX 失敗) |
| `QT_QPA_PLATFORM=wayland` | `EGL not available` |
| `QT_QPA_PLATFORM=wayland:libqwayland-generic.so` | `EGL not available` |
| `QT_QPA_PLATFORM=wayland:generic` | `EGL not available` |
| `QT_QPA_PLATFORM=wayland QT_OPENGL=software` | `EGL not available` |
| `QT_QPA_PLATFORM=offscreen QT_OPENGL=software` | 立ち上がるが描画なし |
| `QT_QPA_PLATFORM=waylandegl` | プラグイン無し |
| `QT_QPA_PLATFORM=eglfs` | `Could not open egl display` でコアダンプ |
| `MESA_GLX_FORCE_4FBC=1` | 変化なし |
| `MESA_GL_VERSION_OVERRIDE=3.3 MESA_GLSL_VERSION_OVERRIDE=330` | 変化なし |
| `LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libEGL.so.1` | `libGLdispatch.so.0` が見つからず起動不可 |
| `LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu` | glibc バージョン違いで `__nptl_change_stack_perm` 未定義 |

### 6. まとめると…

- **GLX 経路**: Xwayland(llvmpipe)が公開する FBConfig と Qt 5 のクエリが形式不一致(bitmask vs シンボリック)。Qt 側の挙動なので環境変数では覆せない。
- **Wayland EGL 経路**: Nix の OpenSCAD に Mesa 実装が含まれていないため、EGL を初期化できない。
- **CLI 経路**: GUI を起動しないので無関係に動作する。

つまり GUI を立ち上げるための手段が現状の Nix パッケージでは両方とも塞がれている。

## 解決策

### A. apt 版に切り替える(推奨・最も確実)

WSLg + システム Mesa は `glxgears` が動いている通り正常なので、apt 版を被せれば GUI も動く:

```bash
apt install openscad
```

`/usr/bin/openscad` が apt 版(2021.01)、Nix 版は `/home/takker/.nix-profile/bin/openscad`
に残るので PATH で使い分け可能。apt 版は system Qt5 + system Mesa(libglvnd +
libEGL_mesa + swrast_dri)を使うので WSLg 環境と相性問題なし。

### B. Nix で Mesa を入れる(Nix 派の場合)

```bash
nix-env -iA nixpkgs.mesa
```

これで `libEGL_mesa.so` / `libGLX_mesa.so` / `swrast_dri.so` が Nix 側に入る。
Wayland EGL パスが復活する可能性がある。ただし GLX 経路の FBConfig 形式
不一致は Qt 側のバグなので残るので、結局 Wayland で使う形に。

※ 効果は未検証。試す価値はあるが確実ではない。

### C. GUI なしで使う(現状維持)

3D モデル生成が目的であれば、CLI で十分:

```bash
openscad -o out.stl design.scad        # バイナリ STL(Manifold バックエンド)
openscad -o out.stl --backend CGAL design.scad   # CGAL バックエンド
openscad -o out.amf design.scad         # AMF
openscad -o out.3mf design.scad         # 3MF
openscad -o out.svg  design.scad        # 2D ベクタ
openscad -o out.pdf  design.scad        # 2D ベクタ(PDF)
```

※ PNG プレビュー(`-o out.png`)は内部で GL を使うので、この環境では落ちる。

## 補足: なぜ WSLg でこの症状が出るのか

WSLg は本来 Wayland コンポジタ + `xdg-desktop-portal` + アプリ用 Xwayland で動く。
GPU パススルーが効いていれば `/dev/dri/renderD128` が作られ、Wayland EGL で
ハードウェアアクセラレーションが効く。しかし今回は:

- `/dev/dri` が無い → DRI3 ベース GPU パススルー無効
- WSLg 自身が Mesa swrast(llvmpipe)で Xwayland を動かしている
- そこに Qt 5(bitmask を理解しない古い実装)が来る → 形式不一致で詰む

NVIDIA / AMD / Intel の GPU ドライバを Windows 側にきちんと入れて
`%UserProfile%\.wslconfig` で `gpuSupport=true` を明示し、`wsl --shutdown` すれば
`/dev/dri` が復活して Mesa のハードウェア DRI が見えるようになり、この種の
bitmask ミスマッチは概ね解消する(別途 Wayland で使えるなら)。今回は OpenSCAD
が Nix で Mesa を含まないパッケージだったため、ハード GPU 復旧でも GUI は別問題で詰まる可能性が高い。
