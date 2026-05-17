My dotfiles, managed primarily with Nix Home Manager.

## How to use

### Initial setup

- Enter the Nix development environment:
	- `nix develop`
- Apply the Home Manager configuration for `takker`:
	- `home-manager switch --flake .#takker`

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
