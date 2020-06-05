# bash及びfish共通設定

alias ls='exa --icons --color-scale --git'
alias la='ls -Gla'
alias vim='NVIM_LISTEN_ADDRESS=/tmp/nvimsocket nvim'
export EDITOR=vim
export GIT_EDITOR=vim
export CC=clang
export CXX=clang++
export XDG_CONFIG_HOME=$HOME/.config
export PATH="$HOME/.local/bin:$PATH"
export LD_LIBRARY_PATH=$HOME/.local/lib/:$LD_LIBRARY_PATH
export DISPLAY=:0.0
export PATH=$HOME/.nodebrew/current/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH

# bat の設定
export BAT_THEME=OneHalfLight
alias cat=batcat

# dotnetをwindows環境のものに置き換える
alias dotnet='dotnet.exe'

# gitをhubに置き換える
eval "$(hub alias -s)"

# pyenvのpath設定
export PYENV_ROOT=$HOME/.pyenv
export PATH=$PYENV_ROOT/bin:$PATH
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
