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
