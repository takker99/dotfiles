{
  inputs,
  config,
  pkgs,
  ...
}:
let
  username = "takker";
in
{
  nixpkgs = {
    overlays = [ inputs.neovim-nightly-overlay.overlays.default ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = username;
    homeDirectory = "/home/${username}";

    shell.enableFishIntegration = true;

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";

    # Set fish as default shell
    sessionVariables = {
      SHELL = "${pkgs.fish}/bin/fish";
    };

    packages = with pkgs; [
      git
      eza
      delta
      gh
      bat
      curl
      nixfmt-rfc-style
      nixd
      xsel
      poppler-utils
      uv
      cargo
      deno
      pnpm
      neovim # nightly
    ];

    file.".commit_template".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/dotfiles/.commit_template";
  };

  programs = {
    home-manager.enable = true;

    fish = {
      enable = true;
      shellAbbrs = {
        cat = "bat";
        ls = "eza";
        la = "eza -la";
      };
      shellInit = ''
        if status is-interactive
          fish_vi_key_bindings

          # install fisher
          if not functions -q fisher
            curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
            ln -sb ~/git/dotfiles/fish_plugins $__fish_config_dir/fish_plugins
            fisher
          end

        end
      '';
    };

    bat = {
      enable = true;
      config = {
        theme = "GitHub";
        pager = "never";
        italic-text = "always";
      };
    };
    eza = {
      enable = true;
      icons = "auto";
      git = true;
      colors = "auto";
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "takker99";
          email = "37929109+takker99@users.noreply.github.com";
        };
        core = {
          ignorecase = false;
        };
        rebase = {
          autosquash = true;
          autostash = true;
        };
        merge.conflictstyle = "diff3";
        fetch.prune = true;
        color.ui = true;
        help.autocorrect = 1;
      };

    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
        syntax-theme = "GitHub";
      };
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "https";

        prompt = "enabled";

        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
      };
    };
  };

}
