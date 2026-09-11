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
automatically. Nix is installed as a single-user installation inside a user
chroot managed by [`nix-user-chroot`](https://github.com/nix-community/nix-user-chroot),
living entirely under `~/.nix`. Interactive bash shells automatically re-enter
the chroot, so `nix` and the Home Manager tools are available as usual.

```sh
curl -fsSL https://raw.githubusercontent.com/takker99/dotfiles/develop/install.sh | bash -s -- --rootless
# or, when running the script directly:
bash install.sh --rootless
```

This requires **unprivileged user namespaces**. Verify on the machine with:

```sh
unshare --user --pid echo YES   # should print YES
```

If namespaces are restricted (Ubuntu 23.10+ via AppArmor), ask an
administrator to run once:

```sh
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
# persist across reboots:
echo 'kernel.apparmor_restrict_unprivileged_userns=0' | sudo tee /etc/sysctl.d/99-userns.conf
```

The rootless installer downloads the `nix-user-chroot` static binary into
`~/.local/bin` and installs Nix into `~/.nix`. The system locale/timezone step
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
