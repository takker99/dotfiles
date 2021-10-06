set -eu

catch () {
  echo "Some error have occurred. Terminate the installation."
}
trap catch ERR

CODE=$(cat << EOS
sed -i.bak -e \
  "s/http:\/\/archive\.ubuntu\.com/http:\/\/jp\.archive\.ubuntu\.com/g" \
  /etc/apt/sources.list
echo Asia/Tokyo > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata
EOS
)
sudo sh -c "${CODE}"
unset CODE

if [[!(type "nvim" > /dev/null 2>&1) \
  || !(type "batcat" > /dev/null 2>&1) \
  || !(type "unzip" > /dev/null 2>&1) \
  || !(type "fish" > /dev/null 2>&1) \
  || !(type "clang" > /dev/null 2>&1) \
  || !(type "xsel" > /dev/null 2>&1) \
]]; then
  echo "Install some apps...";
  sudo add-apt-repository ppa:fish-shell/release-3
  sudo apt-get update
  sudo apt-get install neovim bat unzip fish clang build-essential x11-apps x11-utils x11-xserver-utils dbus-x11 -y
  echo "Successfully installed."
fi
    
if [[ !(-d ~/git/dotfiles) ]]; then
  echo "Downloading takker99/dotfiles..."
  mkdir -p git
  git clone https://github.com/takker99/dotfiles.git

  SSH_GITHUB_NAME="~/.ssh/id_github_takker99"
  
  # 秘密鍵の中身を取り出す
  copyKey() {
    KEY=$(cat "${SSH_GITHUB_NAME}.pub")
    if type "clip.exe" > /dev/null 2>&1; then
      clip.exe "${KEY}"
    else
      xsel "${KEY}"
    fi
  }
  
  if [[ !(-e ${SSH_GITHUB_NAME}) || !(-e "${SSH_GITHUB_NAME}.pub")]]; then
    echo "SSH keys for GitHub aren't found. Creating SSH keys..."
    ssh-keygen -t ed25519 -C "37929109+takker99@users.noreply.github.com" -f  -P "" -N ""
    copyKey
    echo "Copied the SSH public key to your clipboard. Please register it at https://github.com/settings/ssh/new";
    select i in Registered CopyAgain
    do
      case $i in
        Registered) break;;
        CopyAgain)  copyKey;;
        *)          echo "Either \"Registered\" or \"CopyAgain\" can be selected.";;
      esac
    done
  fi
  
  if [[ !(-e ~/.ssh/config) ]]; then
    ln -s ~/git/dotfiles/ssh/config ~/.ssh/config
  fi
  
  ssh -T github

  ln -sb ~/git/dotfiles/.gitconfig ~/.gitconfig
  
  git remote set-url origin git@github.com:takker99/dotfiles.git
fi

. ~/git/dotfiles/.bashrc
 
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
if !(type "deno" > /dev/null 2>&1); then
  echo "`deno` is not installed. Install deno..."
  curl -fsSL https://deno.land/x/install/install.sh | sh
  echo "Successfully installed deno."
fi

# required to install npm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm 
if !(type "nvm" > /dev/null 2>&1); then
  echo "`nvm` is not installed. Install nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  echo "Successfully installed nvm."
fi

# required to install npm
if !(type "node" > /dev/null 2>&1); then
  echo "Node.js is not installed. Install Node.js..."
  nvm install node
  eval "cat <<< \"current Node version: $(node --version)\""
  eval "cat <<< \"current npm version: $(npm --version)\""
  echo "Successfully installed node and npm."
fi

if !(type "yarn" > /dev/null 2>&1); then
  echo "`yarn` is not installed. Install yarn..."
  npm install -g yarn
  # use yarn V2
  yarn set version berry
  echo "Successfully installed yarn."
fi

if !(type "cargo" > /dev/null 2>&1); then
  echo "Rust compile tools is not installed. Install rustup and cargo..."
  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
  echo "Successfully installed rustup."
fi
export PATH="$HOME/.cargo/bin:$PATH"

if !(type "exa" > /dev/null 2>&1); then
  echo "exa is not installed. Install exa..."
  cargo install exa
  echo "Successfully installed exa."
fi

exec fish
