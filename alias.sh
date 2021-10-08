# settings of exa
if type exa > /dev/null 2>&1; then
  alias ls='exa --icons --color-scale --git'
  alias la='exa --icons --color-scale --git -la'
fi

# settings of bat
if type batcat > /dev/null 2>&1; then
  alias cat='BAT_THEME=zenburn batcat --paging=never'
fi
