My dotfiles, managed primarily with Nix Home Manager.

## How to use

### Installation on a new machine (one-liner)

Clones the repo to `~/git/dotfiles` if missing, then runs the installer:

```sh
curl -fsSL https://raw.githubusercontent.com/takker99/dotfiles/develop/install.sh | bash
```

Install into a different directory:

```sh
DOTFILES_DIR="$HOME/src/dotfiles" curl -fsSL https://raw.githubusercontent.com/takker99/dotfiles/develop/install.sh | bash
# or when running the script directly:
bash install.sh "$HOME/src/dotfiles"
```

Requires `git` and `curl` on the machine.

If the machine has no `sudo`, the default install automatically falls back to
rootless mode (see below). Pass `--rootless` to force rootless mode even where
`sudo` is available.

### Rootless installation (no sudo)

On a machine where you do not have `sudo` (e.g. a lab workstation), pass
`--rootless`, or just run the default installer and let it fall back
automatically. Nix is provided by
[`nix-portable`](https://github.com/DavHau/nix-portable), which keeps a
self-contained store under `~/.nix-portable` and virtualizes `/nix` with
`proot`. Interactive bash shells automatically re-enter that environment, so
`nix` and the Home Manager tools are available as usual.

```sh
curl -fsSL https://raw.githubusercontent.com/takker99/dotfiles/develop/install.sh | bash -s -- --rootless
# or, when running the script directly:
bash install.sh --rootless
```

No unprivileged user namespaces are required, so this also works on Ubuntu
24.04 where AppArmor restricts them (`kernel.apparmor_restrict_unprivileged_userns=1`).
`nix-portable` uses `proot` (ptrace-based) when namespaces are unavailable.

The installer downloads the `nix-portable` binary into `~/.local/bin` and
initializes the store under `~/.nix-portable`. The system locale/timezone step
(`setupLang`) is skipped because it needs root.

### System language and timezone (Ubuntu only)

After installation, configure the system locale and timezone:

```sh
nix run .#setupLang
```

### Git authentication (to push changes)

The install itself needs no authentication (the repo is public). To commit and push changes back to GitHub, authenticate once per machine:

- Recommended: `gh auth login` then `gh auth setup-git`
- Or add an SSH key and switch the remote:
  `git remote set-url origin git@github.com:takker99/dotfiles.git`
- Or use a PAT via a credential helper

### Daily commands

- Update flake inputs and re-apply Home Manager in one go:
	- `nix run .#update`
- Refresh only the flake lock file:
	- `nix flake update`
- Remove unreachable Nix store paths and free disk space:
	- `nix store gc`
- Optimize the Nix store contents:
	- `nix store optimise`

If you want the exact command sequence, check the flake outputs in `flake.nix` and the Home Manager module in `nix/home-manager/default.nix`.
