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

    # Set fish as default shell and user locale/timezone environment
    sessionVariables = {
      SHELL = "${pkgs.fish}/bin/fish";
      XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
      LANG = "ja_JP.UTF-8"; # set user LANG; system locale files may still require root
      TZ = "Asia/Tokyo"; # set timezone environment variable for user sessions
    };

    # pnpm v11 puts globally installed CLI bins here (PNPM_HOME/bin)
    sessionPath = [ "${config.home.homeDirectory}/.local/share/pnpm/bin" ];

    # home-manager generates hm-session-vars.fish with `set -gx __HM_SESS_VARS_SOURCED`,
    # which leaks the guard variable to child processes. When it is present in the
    # environment, fresh fish shells early-return in hm-session-vars.fish and never
    # apply sessionVariables/sessionPath. conf.d runs before config.fish, so unset
    # the guard there to make session vars apply on every shell start.
    file.".config/fish/conf.d/00-clear-hm-session-vars-guard.fish".text = ''
      set -e __HM_SESS_VARS_SOURCED
    '';

    packages = with pkgs; [
      git
      eza
      delta
      gh
      bat
      curl
      nixfmt
      nixd
      xsel
      poppler-utils
      uv
      cargo
      deno
      pnpm
      neovim # nightly
      opencode
      openscad-unstable # command name is openscad
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
