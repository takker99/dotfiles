#!/usr/bin/env bash
set -euo pipefail

# Options:
#   --rootless   Force rootless install using nix-portable (store in ~/.nix-portable)
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

  --rootless     Force a rootless install using nix-portable.
                 Nix lives in ~/.nix-portable and interactive shells re-enter
                 the portable environment. Works without unprivileged user
                 namespaces (falls back to proot), so no sudo and no AppArmor
                 changes are required.
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
  echo "--rootless is only supported on Linux (nix-portable does not support macOS)." >&2
  exit 1
fi
FLAKE_REF="${DOTFILES_DIR}#takker-${SYS}"
PROFILE="${HOME}/.profile"
BASHRC="${HOME}/.bashrc"
LOCAL_BIN="${HOME}/.local/bin"

# Rootless (nix-portable) settings
NIX_PORTABLE_BIN="${LOCAL_BIN}/nix-portable"
NIX_PORTABLE_DIR="${HOME}/.nix-portable"

# Directory containing the other nix tools (nix-env, nix-store, ...) in the
# portable store. nix-portable only exposes `nix` itself, but Home Manager's
# activation script needs nix-env/nix-store.
nix_portable_nix_bin() {
  find "${NIX_PORTABLE_DIR}/nix/store" -maxdepth 3 -name nix-env -printf '%h\n' 2>/dev/null | head -n1
}

# Run the persistent static nix bundled with nix-portable (same args as `nix`).
# The store's bin directory is prepended so nix-env/nix-store are found by
# Home Manager's activation during `switch`.
np_nix() {
  local nix_bin_dir
  nix_bin_dir="$(nix_portable_nix_bin)"
  if [ -n "${nix_bin_dir}" ]; then
    env PATH="${nix_bin_dir}:${PATH}" "${NIX_PORTABLE_BIN}" nix "$@"
  else
    "${NIX_PORTABLE_BIN}" nix "$@"
  fi
}

download_nix_portable() {
  if [ -x "${NIX_PORTABLE_BIN}" ]; then
    echo "nix-portable is already installed at ${NIX_PORTABLE_BIN}."
    return
  fi
  case "$(uname -m)" in
    x86_64) np_arch="x86_64" ;;
    aarch64) np_arch="aarch64" ;;
    *) echo "Unsupported architecture for nix-portable: $(uname -m)" >&2; exit 1 ;;
  esac
  local url="https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-${np_arch}"
  echo "Downloading nix-portable from ${url}..."
  mkdir -p "${LOCAL_BIN}"
  curl -fL "${url}" -o "${NIX_PORTABLE_BIN}"
  chmod +x "${NIX_PORTABLE_BIN}"
}

install_nix_rootless() {
  download_nix_portable

  if [ -x "${NIX_PORTABLE_DIR}/bin/nix" ]; then
    echo "nix-portable environment is already initialized."
    return
  fi

  echo "Initializing nix-portable (first run downloads the portable store)..."
  # The first invocation bootstraps ~/.nix-portable and selects a runtime.
  # Retry a few times because proot can hit a transient error during bootstrap.
  local attempt
  for attempt in 1 2 3; do
    if "${NIX_PORTABLE_BIN}" nix --version; then
      break
    fi
    if [ "${attempt}" = "3" ]; then
      echo "nix-portable bootstrap failed after ${attempt} attempts." >&2
      exit 1
    fi
    echo "nix-portable bootstrap failed (attempt ${attempt}); retrying..." >&2
    sleep 2
  done
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

# In rootless mode, expose the static nix bundled with nix-portable (and the
# other nix tools) inside the portable environment. NIX_CONF_DIR is provided by
# nix-portable itself.
if [ "${ROOTLESS}" = "1" ]; then
  NP_PATH_LINE='export PATH="$HOME/.nix-portable/bin:$PATH"'
  grep -Fxq "$NP_PATH_LINE" "${PROFILE}" 2>/dev/null || {
    printf "%s\n" "$NP_PATH_LINE" >>"${PROFILE}"
    echo "-> Added nix-portable bin to ${PROFILE}"
  }
  # nix-env/nix-store live in a versioned store path; add it via a glob so it
  # keeps working after nix-portable upgrades.
  NP_NIX_BIN_LINE='for _np_nix_bin in "$HOME"/.nix-portable/nix/store/*-nix-*/bin; do [ -d "$_np_nix_bin" ] && PATH="$_np_nix_bin:$PATH"; done; unset _np_nix_bin; export PATH'
  grep -Fxq "$NP_NIX_BIN_LINE" "${PROFILE}" 2>/dev/null || {
    printf "%s\n" "$NP_NIX_BIN_LINE" >>"${PROFILE}"
    echo "-> Added nix-portable nix tools to ${PROFILE}"
  }
fi

# source again to ensure current shell has PATH updated
if [ -f "${PROFILE}" ]; then
  # shellcheck source=/dev/null
  . "${PROFILE}" || true
fi

# 4) Enable Nix experimental features (nix-command, flakes)
# nix-portable ships its own nix.conf (NIX_CONF_DIR), so only configure nix
# directly for the multi-user install.
if [ "${ROOTLESS}" != "1" ]; then
  NIX_CONF_DIR="${HOME}/.config/nix"
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
fi

# 5) Run home-manager explicitly (flake specified by absolute path)
echo "Applying home-manager (flake: ${FLAKE_REF})..."
if [ "${ROOTLESS}" = "1" ]; then
  np_nix run "${DOTFILES_DIR}#home-manager" -- switch --flake "${FLAKE_REF}"
else
  nix run "${DOTFILES_DIR}#home-manager" -- switch --flake "${FLAKE_REF}"
fi

# In rootless mode `home-manager switch` does not create ~/.nix-profile, which
# the fish snippet and PATH additions rely on. Point it at the Home Manager
# profile's home-path so the bundled tools (fish, etc.) are reachable.
if [ "${ROOTLESS}" = "1" ] && { [ ! -e "${HOME}/.nix-profile" ] || [ -L "${HOME}/.nix-profile" ]; }; then
  ln -sfn "${HOME}/.local/state/nix/profiles/home-manager/home-path" "${HOME}/.nix-profile"
  echo "-> Linked ~/.nix-profile to the Home Manager profile"
fi

# 6) Create wrapper scripts (to run flake operations from any directory)
if [ "${ROOTLESS}" = "1" ]; then
  cat >"${LOCAL_BIN}/dotfiles-update" <<EOF
#!/usr/bin/env bash
set -euo pipefail
if [ -n "\${NIX_PORTABLE_ACTIVE:-}" ]; then
  exec nix run ${DOTFILES_DIR}#update
fi
exec env NIX_PORTABLE_ACTIVE=1 \\
  "\${HOME}/.local/bin/nix-portable" nix run ${DOTFILES_DIR}#update
EOF
  chmod +x "${LOCAL_BIN}/dotfiles-update"

  cat >"${LOCAL_BIN}/dotfiles-switch" <<EOF
#!/usr/bin/env bash
set -euo pipefail
if [ -n "\${NIX_PORTABLE_ACTIVE:-}" ]; then
  exec nix run ${DOTFILES_DIR}#home-manager -- switch --flake ${DOTFILES_DIR}#takker-${SYS}
fi
exec env NIX_PORTABLE_ACTIVE=1 \\
  "\${HOME}/.local/bin/nix-portable" nix run ${DOTFILES_DIR}#home-manager -- switch --flake ${DOTFILES_DIR}#takker-${SYS}
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

# 7) bashrc snippet: re-enter the nix-portable environment (rootless only)
if [ "${ROOTLESS}" = "1" ]; then
  CHROOT_MARK="# Added by dotfiles/install.sh (rootless): enter nix-portable environment"
  CHROOT_SNIPPET='case "$-" in
  *i*)
    if [ -z "${NIX_PORTABLE_ACTIVE:-}" ] && [ -x "$HOME/.local/bin/nix-portable" ] && [ -d "$HOME/.nix-portable" ]; then
      export NIX_PORTABLE_ACTIVE=1
      exec "$HOME/.local/bin/nix-portable" debug /bin/bash -l
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
    echo "-> Prepended rootless nix-portable snippet to ${BASHRC}"
  else
    echo "-> rootless nix-portable snippet already present in ${BASHRC}"
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
