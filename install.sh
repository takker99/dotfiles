#!/usr/bin/env bash
set -euo pipefail

# Options:
#   --rootless   Force rootless install using nix-user-chroot (single-user in ~/.nix)
#   -h, --help   Show help
# Positional argument: DOTFILES_DIR
# Without --rootless, the multi-user (sudo) install is attempted and the script
# automatically falls back to rootless mode if it fails.
ROOTLESS="${ROOTLESS:-0}"
DOTFILES_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --rootless) ROOTLESS=1 ;;
    -h | --help)
      cat <<'USAGE'
Usage: install.sh [--rootless] [DOTFILES_DIR]

  --rootless     Force a rootless install using nix-user-chroot.
                 Nix lives in ~/.nix and interactive shells re-enter a user chroot.
                 Without this flag, the multi-user (sudo) install is tried first
                 and the script falls back to rootless automatically on failure.
  DOTFILES_DIR   Where to clone/read the dotfiles (default: ~/git/dotfiles)
                 Can also be set via the DOTFILES_DIR environment variable.
USAGE
      exit 0
      ;;
    --)
      shift
      [ $# -gt 0 ] && DOTFILES_ARG="$1"
      break
      ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) DOTFILES_ARG="$1" ;;
  esac
  shift
done

# DOTFILES_DIR can be overridden via an environment variable or the first argument
DOTFILES_DIR="${DOTFILES_ARG:-${DOTFILES_DIR:-${HOME}/git/dotfiles}}"

# bootstrap: if the repository has not been cloned yet, clone it and re-run install.sh
if [ ! -d "${DOTFILES_DIR}/.git" ]; then
  echo "Cloning dotfiles to ${DOTFILES_DIR}..."
  if ! command -v git >/dev/null 2>&1; then
    echo "git not found. Please install git first." >&2
    exit 1
  fi
  mkdir -p "$(dirname "${DOTFILES_DIR}")"
  git clone --branch develop https://github.com/takker99/dotfiles "${DOTFILES_DIR}"
  if [ "${ROOTLESS}" = "1" ]; then
    exec bash "${DOTFILES_DIR}/install.sh" --rootless "${DOTFILES_DIR}"
  else
    exec bash "${DOTFILES_DIR}/install.sh" "${DOTFILES_DIR}"
  fi
fi

case "$(uname -m)" in
  aarch64) SYS="aarch64-linux" ;;
  x86_64) SYS="x86_64-linux" ;;
  arm64) SYS="aarch64-darwin" ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
if [ "${ROOTLESS}" = "1" ] && [ "${SYS##*-}" = "darwin" ]; then
  echo "--rootless is only supported on Linux (nix-user-chroot does not support macOS)." >&2
  exit 1
fi
FLAKE_REF="${DOTFILES_DIR}#takker-${SYS}"
PROFILE="${HOME}/.profile"
BASHRC="${HOME}/.bashrc"
LOCAL_BIN="${HOME}/.local/bin"
USER_NAME="${USER:-$(id -un)}"

# Rootless (nix-user-chroot) settings
NIX_USER_CHROOT_VERSION="2.1.1"
NIX_ROOTLESS_PATH="${HOME}/.nix"
NIX_USER_CHROOT_BIN="${LOCAL_BIN}/nix-user-chroot"

# Run a command (single string) inside the nix user chroot.
# NIX_USER_CHROOT_ACTIVE prevents the ~/.bashrc re-entry snippet from recursing.
nix_user_chroot_exec() {
  env -u LD_LIBRARY_PATH NIX_USER_CHROOT_ACTIVE=1 \
    "${NIX_USER_CHROOT_BIN}" "${NIX_ROOTLESS_PATH}" bash -lc "$1"
}

download_nix_user_chroot() {
  if [ -x "${NIX_USER_CHROOT_BIN}" ]; then
    echo "nix-user-chroot is already installed at ${NIX_USER_CHROOT_BIN}."
    return
  fi
  case "$(uname -m)" in
    x86_64) nuc_arch="x86_64-unknown-linux-musl" ;;
    aarch64) nuc_arch="aarch64-unknown-linux-musl" ;;
    *) echo "Unsupported architecture for nix-user-chroot: $(uname -m)" >&2; exit 1 ;;
  esac
  local url="https://github.com/nix-community/nix-user-chroot/releases/download/${NIX_USER_CHROOT_VERSION}/nix-user-chroot-bin-${NIX_USER_CHROOT_VERSION}-${nuc_arch}"
  echo "Downloading nix-user-chroot from ${url}..."
  mkdir -p "${LOCAL_BIN}"
  curl -fL "${url}" -o "${NIX_USER_CHROOT_BIN}"
  chmod +x "${NIX_USER_CHROOT_BIN}"
}

check_user_namespaces() {
  if command -v unshare >/dev/null 2>&1; then
    if unshare --user --pid echo YES 2>/dev/null | grep -q YES; then
      return 0
    fi
    return 1
  fi
  if [ -r /proc/sys/kernel/unprivileged_userns_clone ] &&
    [ "$(cat /proc/sys/kernel/unprivileged_userns_clone)" = "1" ]; then
    return 0
  fi
  return 1
}

install_nix_rootless() {
  download_nix_user_chroot

  if ! check_user_namespaces; then
    cat >&2 <<'EOF'
ERROR: unprivileged user namespaces are disabled, so nix-user-chroot cannot work.

Ask an administrator to enable them once. On Ubuntu 23.10+:
  sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
  # to persist across reboots:
  echo 'kernel.apparmor_restrict_unprivileged_userns=0' | sudo tee /etc/sysctl.d/99-userns.conf

Then re-run: bash install.sh --rootless
EOF
    exit 1
  fi

  mkdir -p "${NIX_ROOTLESS_PATH}"
  chmod 0755 "${NIX_ROOTLESS_PATH}"

  if [ -L "${HOME}/.nix-profile" ] || [ -e "${NIX_ROOTLESS_PATH}/var/nix/profiles" ]; then
    echo "Nix is already installed in the user chroot."
    return
  fi

  echo "Installing Nix (single-user) inside the user chroot..."
  nix_user_chroot_exec 'curl -L https://nixos.org/nix/install | sh -s -- --no-daemon'
}

# 1) Check for Nix and install it if missing.
#    Without --rootless, try the multi-user (sudo) install first and
#    automatically fall back to rootless mode if that is not possible.
if [ "${ROOTLESS}" = "1" ]; then
  install_nix_rootless
elif command -v nix >/dev/null 2>&1; then
  echo "Nix is already installed."
else
  echo "Nix not found. Installing Nix with multi-user support (sudo required)..."
  if curl -L https://nixos.org/nix/install | sh -s -- --daemon; then
    echo "Nix installation complete."
  else
    echo "Multi-user installation failed; falling back to rootless mode." >&2
    if [ "${SYS##*-}" != "linux" ]; then
      echo "Rootless mode is only supported on Linux. Aborting." >&2
      exit 1
    fi
    ROOTLESS=1
    install_nix_rootless
  fi
fi

if [ "${ROOTLESS}" = "1" ]; then
  echo "== dotfiles install: start (rootless mode) =="
else
  echo "== dotfiles install: start =="
fi

# 2) Source Nix profile so nix is available in the current shell (multi-user only)
if [ "${ROOTLESS}" != "1" ]; then
  NIX_PROFILE_DIRS=(
    "/nix/var/nix/profiles/default" # multi-user daemon install
    "${HOME}/.nix-profile"          # single-user or user profile
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
fi

# 3) Add PATH and local bin to ~/.profile (idempotently)
mkdir -p "${LOCAL_BIN}"

NIX_PATH_LINE='export PATH="$HOME/.nix-profile/bin:$PATH"'
LOCALBIN_LINE='export PATH="$HOME/.local/bin:$PATH"'

grep -Fxq "$NIX_PATH_LINE" "${PROFILE}" 2>/dev/null || {
  printf "\n# Added by dotfiles/install.sh\n%s\n" "$NIX_PATH_LINE" >>"${PROFILE}"
  echo "-> Added Nix PATH to ${PROFILE}"
}

grep -Fxq "$LOCALBIN_LINE" "${PROFILE}" 2>/dev/null || {
  printf "%s\n" "$LOCALBIN_LINE" >>"${PROFILE}"
  echo "-> Added ~/.local/bin to ${PROFILE}"
}

# source again to ensure current shell has PATH updated
if [ -f "${PROFILE}" ]; then
  # shellcheck source=/dev/null
  . "${PROFILE}" || true
fi

# 4) Enable Nix experimental features (nix-command, flakes)
if [ "${ROOTLESS}" = "1" ]; then
  NIX_CONF_DIR="${NIX_ROOTLESS_PATH}/etc/nix"
else
  NIX_CONF_DIR="${HOME}/.config/nix"
fi
NIX_CONF_FILE="${NIX_CONF_DIR}/nix.conf"
mkdir -p "${NIX_CONF_DIR}"
if [ ! -f "${NIX_CONF_FILE}" ]; then
  printf "experimental-features = nix-command flakes\n" >"${NIX_CONF_FILE}"
  echo "-> Created ${NIX_CONF_FILE} and enabled experimental-features"
else
  # Add missing flags if needed
  if ! grep -q "nix-command" "${NIX_CONF_FILE}" || ! grep -q "flakes" "${NIX_CONF_FILE}"; then
    # Remove any existing experimental-features line and append the merged one
    grep -v "^experimental-features" "${NIX_CONF_FILE}" >"${NIX_CONF_FILE}.tmp" || true
    mv "${NIX_CONF_FILE}.tmp" "${NIX_CONF_FILE}"
    printf "experimental-features = nix-command flakes\n" >>"${NIX_CONF_FILE}"
    echo "-> Appended experimental-features to ${NIX_CONF_FILE}"
  fi
fi

# 5) Run home-manager explicitly (flake specified by absolute path)
echo "Applying home-manager (flake: ${FLAKE_REF})..."
if [ "${ROOTLESS}" = "1" ]; then
  nix_user_chroot_exec "nix run \"${DOTFILES_DIR}#home-manager\" -- switch --flake \"${FLAKE_REF}\""
else
  nix run "${DOTFILES_DIR}#home-manager" -- switch --flake "${FLAKE_REF}"
fi

# 6) Create wrapper scripts (to run flake operations from any directory)
if [ "${ROOTLESS}" = "1" ]; then
  cat >"${LOCAL_BIN}/dotfiles-update" <<EOF
#!/usr/bin/env bash
set -euo pipefail
if [ -n "\${NIX_USER_CHROOT_ACTIVE:-}" ]; then
  exec nix run ${DOTFILES_DIR}#update
fi
exec env -u LD_LIBRARY_PATH NIX_USER_CHROOT_ACTIVE=1 \\
  "\${HOME}/.local/bin/nix-user-chroot" "\${HOME}/.nix" \\
  bash -lc 'nix run ${DOTFILES_DIR}#update'
EOF
  chmod +x "${LOCAL_BIN}/dotfiles-update"

  cat >"${LOCAL_BIN}/dotfiles-switch" <<EOF
#!/usr/bin/env bash
set -euo pipefail
if [ -n "\${NIX_USER_CHROOT_ACTIVE:-}" ]; then
  exec home-manager switch --flake ${DOTFILES_DIR}#takker-${SYS}
fi
exec env -u LD_LIBRARY_PATH NIX_USER_CHROOT_ACTIVE=1 \\
  "\${HOME}/.local/bin/nix-user-chroot" "\${HOME}/.nix" \\
  bash -lc 'home-manager switch --flake ${DOTFILES_DIR}#takker-${SYS}'
EOF
  chmod +x "${LOCAL_BIN}/dotfiles-switch"
else
  cat >"${LOCAL_BIN}/dotfiles-update" <<EOF
#!/usr/bin/env bash
nix run ${DOTFILES_DIR}#update
EOF
  chmod +x "${LOCAL_BIN}/dotfiles-update"

  cat >"${LOCAL_BIN}/dotfiles-switch" <<EOF
#!/usr/bin/env bash
home-manager switch --flake ${DOTFILES_DIR}#takker-${SYS}
EOF
  chmod +x "${LOCAL_BIN}/dotfiles-switch"
fi

echo "-> wrapper scripts installed to ${LOCAL_BIN}: dotfiles-update, dotfiles-switch"

# 7) bashrc snippet: re-enter the nix user chroot (rootless only)
if [ "${ROOTLESS}" = "1" ]; then
  CHROOT_MARK="# Added by dotfiles/install.sh (rootless): enter nix user chroot"
  CHROOT_SNIPPET='case "$-" in
  *i*)
    if [ -z "${NIX_USER_CHROOT_ACTIVE:-}" ] && [ -x "$HOME/.local/bin/nix-user-chroot" ] && [ -d "$HOME/.nix" ]; then
      export NIX_USER_CHROOT_ACTIVE=1
      exec env -u LD_LIBRARY_PATH "$HOME/.local/bin/nix-user-chroot" "$HOME/.nix" bash -l
    fi
    ;;
esac'

  if ! grep -Fq "${CHROOT_MARK}" "${BASHRC}" 2>/dev/null; then
    [ -f "${BASHRC}" ] || : >"${BASHRC}"
    tmp_bashrc="$(mktemp)"
    {
      printf '%s\n' "${CHROOT_MARK}"
      printf '%s\n' "${CHROOT_SNIPPET}"
      cat "${BASHRC}"
    } >"${tmp_bashrc}"
    mv "${tmp_bashrc}" "${BASHRC}"
    echo "-> Prepended rootless chroot snippet to ${BASHRC}"
  else
    echo "-> rootless chroot snippet already present in ${BASHRC}"
  fi
fi

# 8) bashrc snippet: switch to fish only in interactive shells
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
  } >>"${BASHRC}"
  echo "-> Added exec fish snippet to ${BASHRC}"
else
  echo "-> exec fish snippet already present in ${BASHRC}"
fi

# 9) Set the system locale and timezone on Ubuntu (requires sudo)
if [ "${ROOTLESS}" = "1" ]; then
  echo "-> Skipping system locale/timezone setup (needs sudo). Run 'nix run ${DOTFILES_DIR}#setupLang' as root if required."
elif grep -qi "^ID=ubuntu$" /etc/os-release 2>/dev/null; then
  echo "Ubuntu detected. Setting the system locale/timezone..."
  nix run "${DOTFILES_DIR}#setupLang"
fi

echo "== dotfiles install: done =="
