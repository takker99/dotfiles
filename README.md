My dotfiles, managed primarily with Nix Home Manager.

## How to use

- Enter the environment with the flake defined in `flake.nix`
- Run the Home Manager configuration for `takker`
- Use the update app from the flake when you want to refresh inputs and reapply the profile

If you want the exact command sequence, check the flake outputs in `flake.nix` and the Home Manager module in `nix/home-manager/default.nix`.

## Frequently used nix commands

- Build or enter the local development environment:
	- `nix develop`
- Update flake inputs and re-apply Home Manager in one go:
	- `nix run .#update`
- Refresh only the flake lock file:
	- `nix flake update`
- Re-apply the Home Manager configuration manually:
	- `home-manager switch --flake .#takker`
- Remove unreachable Nix store paths and free disk space:
	- `nix-collect-garbage -d`
	- `nix store gc`
- Optimize the Nix store contents:
	- `nix store optimise`
