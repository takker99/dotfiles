if status is-interactive
  fish_vi_key_bindings
  
  # install fisher
  if not functions -q fisher
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    ln -sb ~/git/dotfiles/fish_plugins $__fish_config_dir/fish_plugins
    fisher
  end

  # abbrs
  if type exa > /dev/null 2>&1
    abbr -ag ls 'exa --icons --color-scale --git'
    abbr -ag la 'exa --icons --color-scale --git -la'
  end
  if type batcat > /dev/null 2>&1
    abbr -ag cat 'batcat --theme=ansi-dark --paging=never'
  end

end
