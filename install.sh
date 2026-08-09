#!/usr/bin/env bash
set -euo pipefail

# DOTFILES_DIR can be overridden via an environment variable or the first argument
DOTFILES_DIR="${1:-${DOTFILES_DIR:-${HOME}/git/dotfiles}}"

# bootstrap: if the repository has not been cloned yet, clone it and re-run install.sh
if [ ! -d "${DOTFILES_DIR}/.git" ]; then
  echo "Cloning dotfiles to ${DOTFILES_DIR}..."
  if ! command -v git >/dev/null 2>&1; then
    echo "git not found. Please install git first." >&2
    exit 1
  fi
  mkdir -p "$(dirname "${DOTFILES_DIR}")"
  git clone --branch develop https://github.com/takker99/dotfiles "${DOTFILES_DIR}"
  exec bash "${DOTFILES_DIR}/install.sh" "${DOTFILES_DIR}"
fi

case "$(uname -m)" in
  aarch64) SYS="aarch64-linux" ;;
  x86_64) SYS="x86_64-linux" ;;
  arm64) SYS="aarch64-darwin" ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
FLAKE_REF="${DOTFILES_DIR}#takker-${SYS}"
PROFILE="${HOME}/.profile"
BASHRC="${HOME}/.bashrc"
LOCAL_BIN="${HOME}/.local/bin"
echo "== dotfiles install: start =="

# 1) Check for Nix and install it if missing (multi-user recommended)
if ! command -v nix >/dev/null 2>&1; then
  echo "Nix not found. Installing Nix with multi-user support (sudo required)..."
  curl -L https://nixos.org/nix/install | sh -s -- --daemon
  echo "Nix installation complete."
else
  echo "Nix is already installed."
fi

# 2) Source Nix profile so nix is available in the current shell
NIX_PROFILE_DIRS=(
  "/nix/var/nix/profiles/default"  # multi-user daemon install
  "${HOME}/.nix-profile"            # single-user or user profile
)
NIX_PATH_UPDATED=false
for nix_dir in "${NIX_PROFILE_DIRS[@]}"; do
  if [ -f "${nix_dir}/etc/profile.d/nix.sh" ]; then
    # shellcheck source=/dev/null
    . "${nix_dir}/etc/profile.d/nix.sh"
    NIX_PATH_UPDATED=true
  fi
done
if ! command -v nix >/dev/null 2>&1; then
  echo "nix is still not in PATH. Please restart your shell and re-run install.sh." >&2
  exit 1
fi

# 3) Add PATH and local bin to ~/.profile (idempotently)
mkdir -p "${LOCAL_BIN}"

NIX_PATH_LINE='export PATH="$HOME/.nix-profile/bin:$PATH"'
LOCALBIN_LINE='export PATH="$HOME/.local/bin:$PATH"'

grep -Fxq "$NIX_PATH_LINE" "${PROFILE}" 2>/dev/null || {
  printf "\n# Added by dotfiles/install.sh\n%s\n" "$NIX_PATH_LINE" >> "${PROFILE}"
  echo "-> Added Nix PATH to ${PROFILE}"
}

grep -Fxq "$LOCALBIN_LINE" "${PROFILE}" 2>/dev/null || {
  printf "%s\n" "$LOCALBIN_LINE" >> "${PROFILE}"
  echo "-> Added ~/.local/bin to ${PROFILE}"
}

# source again to ensure current shell has PATH updated
if [ -f "${PROFILE}" ]; then
  # shellcheck source=/dev/null
  . "${PROFILE}" || true
fi

# 4) Run home-manager explicitly (flake specified by absolute path)
echo "Applying home-manager (flake: ${FLAKE_REF})..."
# Ensure Nix experimental features (nix-command, flakes) are enabled for this user
NIX_CONF_DIR="${HOME}/.config/nix"
NIX_CONF_FILE="${NIX_CONF_DIR}/nix.conf"
mkdir -p "${NIX_CONF_DIR}"
if [ ! -f "${NIX_CONF_FILE}" ]; then
  printf "experimental-features = nix-command flakes\n" > "${NIX_CONF_FILE}"
  echo "-> Created ${NIX_CONF_FILE} and enabled experimental-features"
else
  # Add missing flags if needed
  if ! grep -q "nix-command" "${NIX_CONF_FILE}" || ! grep -q "flakes" "${NIX_CONF_FILE}"; then
    # Remove any existing experimental-features line and append the merged one
    grep -v "^experimental-features" "${NIX_CONF_FILE}" > "${NIX_CONF_FILE}.tmp" || true
    mv "${NIX_CONF_FILE}.tmp" "${NIX_CONF_FILE}"
    printf "experimental-features = nix-command flakes\n" >> "${NIX_CONF_FILE}"
    echo "-> Appended experimental-features to ${NIX_CONF_FILE}"
  fi
fi

# use nix run to ensure home-manager is available
nix run "${DOTFILES_DIR}#home-manager" -- switch --flake "${FLAKE_REF}"

# 5) Create wrapper scripts (to run flake operations from any directory)
cat > "${LOCAL_BIN}/dotfiles-update" <<EOF
#!/usr/bin/env bash
nix run ${DOTFILES_DIR}#update
EOF
chmod +x "${LOCAL_BIN}/dotfiles-update"

cat > "${LOCAL_BIN}/dotfiles-switch" <<EOF
#!/usr/bin/env bash
home-manager switch --flake ${DOTFILES_DIR}#takker-${SYS}
EOF
chmod +x "${LOCAL_BIN}/dotfiles-switch"

echo "-> wrapper scripts installed to ${LOCAL_BIN}: dotfiles-update, dotfiles-switch"

# 6) bashrc snippet: switch to fish only in interactive shells
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
  echo "-> Added exec fish snippet to ${BASHRC}"
else
  echo "-> exec fish snippet already present in ${BASHRC}"
fi

# 7) Set the system locale and timezone on Ubuntu
if grep -qi "^ID=ubuntu$" /etc/os-release 2>/dev/null; then
  echo "Ubuntu detected. Setting the system locale/timezone..."
  nix run "${DOTFILES_DIR}#setupLang"
fi

echo "== dotfiles install: done =="
