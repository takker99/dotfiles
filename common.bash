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
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
export PATH=$HOME/.nodebrew/current/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH

# bat の設定
if type batcat > /dev/null 2>&1; then
    export BAT_THEME=OneHalfLight
    alias cat=batcat
fi

# yarnのinstall
if !(type yarn > /dev/null 2>&1); then
    echo "yarn isn't installed. Adding the repository of yarn..."
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update
    if type nvm > /dev/null 2>&1; then
        echo "nvm is found"
        sudo apt install --no-install-recommends yarn
    else
        sudo apt install yarn
    fi
fi

# dotnetをwindows環境のものに置き換える
alias dotnet='dotnet.exe'

# gitをhubに置き換える
if type hub > /dev/null 2>&1; then
    eval "$(hub alias -s)"
fi

# pyenvのpath設定
export PYENV_ROOT=$HOME/.pyenv
export PATH=$PYENV_ROOT/bin:$PATH
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
