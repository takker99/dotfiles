{
  description = "My dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      neovim-nightly-overlay,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        formatter = pkgs.nixfmt;
        # https://zenn.dev/kawarimidoll/articles/0a4ec8bab8a8ba#%E6%9B%B4%E6%96%B0%E3%82%BF%E3%82%B9%E3%82%AF%E3%81%AE%E8%BF%BD%E5%8A%A0
        apps.update = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "update-script" ''
              set -e
              echo "Updating flake..."
              nix flake update
              echo "Updating home-manager..."
              nix run home-manager/master -- switch --flake .#takker
              echo "Update complete!"
            ''
          );
        };
        apps.setupLang = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "setup-lang" ''
              set -e
              # This script requires root to modify system files. Run with sudo to apply.
              echo "Running system language/timezone setup..."
              sudo sed -i.bak -e "s/http:\/\/archive\.ubuntu\.com/http:\/\/jp\.archive\.ubuntu\.com/g" /etc/apt/sources.list
              sudo apt update
              sudo apt -y install language-pack-ja-base
              sudo update-locale LANG=ja_JP.UTF8
              cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
              sudo apt -y install manpages-ja manpages-ja-dev
            ''
          );
        };
        legacyPackages = {
          inherit (pkgs) home-manager;
          homeConfigurations.takker = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs;
            extraSpecialArgs = { inherit inputs; };
            modules = [ ./nix/home-manager/default.nix ];
          };
        };
      }
    );
}
