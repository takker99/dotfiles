#!/usr/bin/env bash
set -euo pipefail

# DOTFILES_DIR は環境変数か第1引数で上書きできる
DOTFILES_DIR="${1:-${DOTFILES_DIR:-${HOME}/git/dotfiles}}"

# bootstrap: リポジトリ未取得なら clone してから install.sh を再実行する
if [ ! -d "${DOTFILES_DIR}/.git" ]; then
  echo "dotfiles を ${DOTFILES_DIR} に clone します..."
  if ! command -v git >/dev/null 2>&1; then
    echo "git が見つかりません。先に git をインストールしてください" >&2
    exit 1
  fi
  mkdir -p "$(dirname "${DOTFILES_DIR}")"
  git clone --branch develop https://github.com/takker99/dotfiles "${DOTFILES_DIR}"
  exec bash "${DOTFILES_DIR}/install.sh" "${DOTFILES_DIR}"
fi

FLAKE_REF="${DOTFILES_DIR}#takker"
PROFILE="${HOME}/.profile"
BASHRC="${HOME}/.bashrc"
LOCAL_BIN="${HOME}/.local/bin"
NIX_PROFILE="${HOME}/.nix-profile"
echo "== dotfiles install: start =="

# 1) Nix インストール確認・インストール（multi-user 推奨）
if ! command -v nix >/dev/null 2>&1; then
  echo "Nix が見つかりません。Nix を multi-user でインストールします（sudo が必要）..."
  curl -L https://nixos.org/nix/install | sh -s -- --daemon
  echo "Nix インストール完了。シェル初期化を読み込みます..."
else
  echo "Nix は既にインストール済みです。"
fi

# 2) Nix プロファイル初期化（存在すれば source）
if [ -f "${NIX_PROFILE}/etc/profile.d/nix.sh" ]; then
  # shellcheck source=/dev/null
  . "${NIX_PROFILE}/etc/profile.d/nix.sh"
fi

# 3) ~/.profile に PATH と local bin を追加（冪等に）
mkdir -p "${LOCAL_BIN}"

NIX_PATH_LINE='export PATH="$HOME/.nix-profile/bin:$PATH"'
LOCALBIN_LINE='export PATH="$HOME/.local/bin:$PATH"'

grep -Fxq "$NIX_PATH_LINE" "${PROFILE}" 2>/dev/null || {
  printf "\n# Added by dotfiles/install.sh\n%s\n" "$NIX_PATH_LINE" >> "${PROFILE}"
  echo "-> ${PROFILE} に Nix PATH を追加しました"
}

grep -Fxq "$LOCALBIN_LINE" "${PROFILE}" 2>/dev/null || {
  printf "%s\n" "$LOCALBIN_LINE" >> "${PROFILE}"
  echo "-> ${PROFILE} に ~/.local/bin を追加しました"
}

# source again to ensure current shell has PATH updated
if [ -f "${PROFILE}" ]; then
  # shellcheck source=/dev/null
  . "${PROFILE}" || true
fi

# 4) home-manager を明示的に実行（フレークは絶対パスで指定）
echo "home-manager を適用します（flake: ${FLAKE_REF}）..."
# Ensure Nix experimental features (nix-command, flakes) are enabled for this user
NIX_CONF_DIR="${HOME}/.config/nix"
NIX_CONF_FILE="${NIX_CONF_DIR}/nix.conf"
mkdir -p "${NIX_CONF_DIR}"
if [ ! -f "${NIX_CONF_FILE}" ]; then
  printf "experimental-features = nix-command flakes\n" > "${NIX_CONF_FILE}"
  echo "-> ${NIX_CONF_FILE} を作成して experimental-features を有効化しました"
else
  # Add missing flags if needed
  if ! grep -q "nix-command" "${NIX_CONF_FILE}" || ! grep -q "flakes" "${NIX_CONF_FILE}"; then
    # Remove any existing experimental-features line and append the merged one
    grep -v "^experimental-features" "${NIX_CONF_FILE}" > "${NIX_CONF_FILE}.tmp" || true
    mv "${NIX_CONF_FILE}.tmp" "${NIX_CONF_FILE}"
    printf "experimental-features = nix-command flakes\n" >> "${NIX_CONF_FILE}"
    echo "-> ${NIX_CONF_FILE} に experimental-features を追記しました"
  fi
fi

# use nix run to ensure home-manager is available
nix run "${DOTFILES_DIR}#home-manager" -- switch --flake "${FLAKE_REF}"

# 5) wrapper スクリプト作成（どのディレクトリからでも flake 操作できるように）
cat > "${LOCAL_BIN}/dotfiles-update" <<EOF
#!/usr/bin/env bash
nix run ${DOTFILES_DIR}#update
EOF
chmod +x "${LOCAL_BIN}/dotfiles-update"

cat > "${LOCAL_BIN}/dotfiles-switch" <<EOF
#!/usr/bin/env bash
home-manager switch --flake ${DOTFILES_DIR}#takker
EOF
chmod +x "${LOCAL_BIN}/dotfiles-switch"

echo "-> wrapper scripts installed to ${LOCAL_BIN}: dotfiles-update, dotfiles-switch"

# 6) bashrc スニペット: interactive shell のみで fish に切り替える
BASHRC_MARK="# Added by dotfiles/install.sh: exec fish for interactive login"
BASHRC_SNIPPET='case "$-" in
  *i*)
    if [ -x "$HOME/.nix-profile/bin/fish" ] && [ -z "${FISH_VERSION:-}" ]; then
      exec "$HOME/.nix-profile/bin/fish"
    fi
    ;;
esac'

if ! grep -Fq "$BASHRC_MARK" "${BASHRC}" 2>/dev/null; then
  {
    printf "\n%s\n" "$BASHRC_MARK"
    printf "%s\n" "$BASHRC_SNIPPET"
  } >> "${BASHRC}"
  echo "-> ${BASHRC} に exec fish スニペットを追加しました"
else
  echo "-> ${BASHRC} に既に exec fish スニペットがあります"
fi

echo "== dotfiles install: done =="
