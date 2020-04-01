# bash及びfish共通設定

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias vim='env NVIM_LISTEN_ADDRESS=/tmp/nvimsocket nvim'
export EDITOR=vim
export GIT_EDITOR=vim
export CC=clang
export CXX=clang++
export XDG_CONFIG_HOME=$HOME/.config
export PATH="$HOME/.local/bin:$PATH"
export LD_LIBRARY_PATH=$HOME/.local/lib/:$LD_LIBRARY_PATH
export DISPLAY=:0.0
export PATH=$HOME/.nodebrew/current/bin:$PATH

# gitをhubに置き換える
eval "$(hub alias -s)"

# pyenvのpath設定
export PYENV_ROOT=$HOME/.pyenv
export PATH=$PYENV_ROOT/bin:$PATH
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
