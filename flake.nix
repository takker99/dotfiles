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
    flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" ] (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        formatter = pkgs.nixfmt;
        packages.home-manager = home-manager.packages.${system}.default;
        packages.opencode = pkgs.callPackage ./nix/opencode/package.nix { };
        # https://zenn.dev/kawarimidoll/articles/0a4ec8bab8a8ba#%E6%9B%B4%E6%96%B0%E3%82%BF%E3%82%B9%E3%82%AF%E3%81%AE%E8%BF%BD%E5%8A%A0
        apps.update = {
          type = "app";
          program = toString (
            (pkgs.writeShellApplication {
              name = "update";
              runtimeInputs = [
                pkgs.coreutils
                pkgs.curl
                pkgs.git
                pkgs.gnugrep
                pkgs.gnused
                pkgs.jq
                pkgs.nodejs
              ];
              runtimeEnv.FLAKE_SYSTEM = system;
              text = builtins.readFile ./nix/update.sh;
            })
            + "/bin/update"
          );
          meta.description = "Update flake inputs, opencode, and re-apply Home Manager";
        };
        apps.setupLang = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "setup-lang" ''
              set -e
              sudo -v
              echo "Running system language/timezone setup..."
              if ! grep -q "jp.archive.ubuntu.com" /etc/apt/sources.list 2>/dev/null; then
                sudo sed -i.bak -e "s/http:\/\/archive\.ubuntu\.com/http:\/\/jp\.archive\.ubuntu\.com/g" /etc/apt/sources.list
              fi
              sudo apt update
              sudo apt -y install language-pack-ja-base
              sudo update-locale LANG=ja_JP.UTF8
              sudo timedatectl set-timezone Asia/Tokyo
              sudo apt -y install manpages-ja manpages-ja-dev
            ''
          );
          meta.description = "Configure system locale and timezone for Ubuntu";
        };
      }
    )
    // {
      homeConfigurations =
        let
          mkConfig =
            sys:
            home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${sys};
              extraSpecialArgs = { inherit inputs; };
              modules = [ ./nix/home-manager/default.nix ];
            };
        in
        builtins.listToAttrs (
          map
            (sys: {
              name = "takker-${sys}";
              value = mkConfig sys;
            })
            [
              "aarch64-linux"
              "x86_64-linux"
              "aarch64-darwin"
            ]
        );
    };
}
