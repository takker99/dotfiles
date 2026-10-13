#!/usr/bin/env bash
# Body of the `update` app defined in flake.nix (writeShellApplication).
# Expects FLAKE_SYSTEM (injected via runtimeEnv) and runtimeInputs on PATH.

update_opencode() {
  local sources=nix/opencode/sources.json
  local current latest url sys npm hash tmp count=0
  local platforms='{}'

  if [[ ! -f $sources ]]; then
    echo "opencode: $sources not found" >&2
    return 1
  fi
  if ! current=$(jq -er .version "$sources"); then
    echo "opencode: cannot read the version from $sources" >&2
    return 1
  fi
  if ! latest=$(curl -fsSL https://registry.npmjs.org/@opencode/cli/latest \
      | jq -er '.version | select(test("^[0-9]+[.][0-9]+[.][0-9]+"))'); then
    echo "opencode: cannot determine the latest version from the npm registry" >&2
    return 1
  fi

  if [[ $latest == "$current" ]]; then
    echo "opencode: $current is already the latest release"
    return 0
  fi
  if [[ $(printf '%s\n%s\n' "$current" "$latest" | sort -V | tail -n 1) != "$latest" ]]; then
    echo "opencode: npm latest ($latest) is not newer than $current; skipping" >&2
    return 0
  fi
  if ! jq -e '.platforms | type == "object" and length > 0' "$sources" >/dev/null; then
    echo "opencode: $sources does not list any platform" >&2
    return 1
  fi

  echo "opencode: $current -> $latest"
  while read -r sys npm; do
    url="https://registry.npmjs.org/@opencode/cli-$npm/-/cli-$npm-$latest.tgz"
    if ! hash=$(nix store prefetch-file --unpack --json "$url" \
        | jq -er '.hash | select(startswith("sha256-"))'); then
      echo "opencode: failed to prefetch $url" >&2
      return 1
    fi
    if ! platforms=$(jq -c --arg sys "$sys" --arg npm "$npm" --arg hash "$hash" \
        '. + {($sys): {npm: $npm, hash: $hash}}' <<<"$platforms"); then
      echo "opencode: failed to record the hash for $sys" >&2
      return 1
    fi
    echo "  $sys -> $hash"
    count=$((count + 1))
  done < <(jq -r '.platforms | to_entries[] | "\(.key) \(.value.npm)"' "$sources")

  if (( count == 0 )); then
    echo "opencode: no platform entries found in $sources" >&2
    return 1
  fi

  if ! tmp=$(mktemp nix/opencode/.sources.json.XXXXXX); then
    echo "opencode: cannot create a temporary file" >&2
    return 1
  fi
  if ! jq -n --arg version "$latest" --argjson platforms "$platforms" \
      '{version: $version, platforms: $platforms}' >"$tmp"; then
    rm -f "$tmp"
    echo "opencode: failed to render the new $sources" >&2
    return 1
  fi
  if ! mv "$tmp" "$sources"; then
    rm -f "$tmp"
    echo "opencode: failed to write $sources" >&2
    return 1
  fi
}

update_opencode_plugins() {
  # opencode "plugin" エントリ (<package>@<version>) のバージョン管理と実ファイルの導入先。
  # バージョンの真実の所在は opencode/opencode.jsonc の "plugin" エントリ
  # ("<package>@<version>" 形式) 一箇所。npm でインストール
  # (install 手法は npm/npx/pnpm 等の同等のものでよい)。
  local manifest=opencode/opencode.jsonc
  local config_dir=$HOME/.config/opencode
  local entry package current latest
  local tmp

  if [[ ! -f $manifest ]]; then
    echo "opencode-plugin: $manifest not found" >&2
    return 1
  fi

  # "plugin" に並ぶ "<package>@<version>" をすべて読む。
  # 誤パース防止のため、JSON 文字列リテラル単独行 (行頭が文字列開始) に限定する。
  local entries=()
  while IFS= read -r entry; do
    if [[ -n $entry ]]; then
      entries+=("$entry")
    fi
  done < <(
    grep -E '^[[:space:]]*"[^"]+",?[[:space:]]*$' "$manifest" \
      | grep -oE '"(@[^"@]+(/[^"@]+)?|[^"@]+)@[0-9]+\.[0-9]+\.[0-9]+"'
  )
  if (( ${#entries[@]} == 0 )); then
    echo "opencode-plugin: no \"<package>@<version>\" entry found in $manifest" >&2
    return 1
  fi

  # 1 パッケージの失敗は他への更新を止めない (末尾の return で総合結果を返す)。
  local status=0
  for entry in "${entries[@]}"; do
    package=${entry%@*}
    package=${package#\"}
    current=${entry##*@}
    current=${current%\"}

    if ! latest=$(curl -fsSL "https://registry.npmjs.org/$package/latest" \
        | jq -er '.version | select(test("^[0-9]+[.][0-9]+[.][0-9]+"))'); then
      echo "opencode-plugin: $package: cannot determine the latest version from the npm registry" >&2
      status=1
      continue
    fi

    if [[ $latest == "$current" ]]; then
      echo "opencode-plugin: $package: $current is already the latest release"
      continue
    fi
    if [[ $(printf '%s\n%s\n' "$current" "$latest" | sort -V | tail -n 1) != "$latest" ]]; then
      echo "opencode-plugin: $package: npm latest ($latest) is not newer than $current; skipping" >&2
      continue
    fi

    echo "opencode-plugin: $package: $current -> $latest"
    # --loglevel=error: 依存ツリー側の警告 (EBADENGINE / deprecated / install-scripts)
    # は更新の成否と無関係なノイズなので隠す。失敗は exit code で検知する。
    if ! npm install --prefix "$config_dir" "$package@$latest" --no-audit --no-fund --loglevel=error; then
      echo "opencode-plugin: $package: npm install failed" >&2
      status=1
      continue
    fi
    # npm は ^ を付けるので、厳密なバージョンに戻す
    if ! jq --arg v "$latest" --arg p "$package" \
        '.dependencies[$p] = $v' "$config_dir/package.json" >"$config_dir/package.json.new" \
        || ! mv "$config_dir/package.json.new" "$config_dir/package.json"; then
      echo "opencode-plugin: $package: failed to pin the version in $config_dir/package.json" >&2
      status=1
      continue
    fi

    # jsonc 内の "plugin" に並ぶ "<package>@<version>" のバージョン部分も同期する。
    # JSON 文字列リテラル単独行のみ置換し、コメント内の同形式を誤更新しない。
    # mktemp + mv で原子的に差し替える (update_opencode と同パターン)。
    if ! tmp=$(mktemp opencode/.opencode.jsonc.XXXXXX); then
      echo "opencode-plugin: $package: cannot create a temporary file" >&2
      status=1
      continue
    fi
    if ! sed "s|^\([[:space:]]*\"\)$package@[^\"]*|\1$package@$latest|" \
        "$manifest" > "$tmp" \
        || ! grep -q "\"$package@$latest\"" "$tmp"; then
      rm -f "$tmp"
      echo "opencode-plugin: $package: failed to update the version in $manifest" >&2
      status=1
      continue
    fi
    if ! mv "$tmp" "$manifest"; then
      rm -f "$tmp"
      echo "opencode-plugin: $package: failed to write $manifest" >&2
      status=1
      continue
    fi
  done

  return "$status"
}

# Resolve the repository root first so relative references
# (flake.lock, sources.json) always hit this repository, no
# matter where the app is invoked from.
if ! root=$(git rev-parse --show-toplevel 2>/dev/null) \
    || [[ ! -f $root/flake.nix || ! -f $root/nix/opencode/sources.json ]]; then
  echo "update: run from inside the dotfiles repository" >&2
  exit 1
fi
cd "$root" || exit 1

status=0

echo "Updating flake..."
nix flake update

if ! update_opencode; then
  echo "update: opencode version bump failed; continuing with Home Manager" >&2
  status=1
fi

if ! update_opencode_plugins; then
  echo "update: opencode plugin version bump failed; continuing with Home Manager" >&2
  status=1
fi

echo "Updating home-manager..."
if ! nix run .#home-manager -- switch --flake ".#takker-$FLAKE_SYSTEM"; then
  status=1
fi

if git status --porcelain -- flake.lock nix/opencode/sources.json opencode/opencode.jsonc | grep -q .; then
  echo "Changed files to review and commit:"
  git status --short -- flake.lock nix/opencode/sources.json opencode/opencode.jsonc
fi

if (( status != 0 )); then
  echo "Update finished with errors" >&2
  exit "$status"
fi
echo "Update complete!"

