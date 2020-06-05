fish_vi_key_bindings

# fisherをinstallする
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    # fish plugin listをlinkさせる
    ln -s ~/git/dotfiles/fishfile $XDG_CONFIG_HOME/fish/fishfile
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# 共通 shell settings を読み込む
if test -f $HOME/git/dotfiles/common.bash
    bass source $HOME/git/dotfiles/common.bash
end
