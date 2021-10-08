if status is-interactive
  fish_vi_key_bindings
  
  # install fisher
  if not functions -q fisher
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    ln -sb ~/git/dotfiles/fish_plugins $__fish_config_dir/fish_plugins
    fisher
  end
end
