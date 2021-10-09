set -eu

catch () {
  echo "Some error have occurred. Terminate the installation."
}
trap catch ERR
 
if !(type "nvim" > /dev/null 2>&1) \
  || !(type "batcat" > /dev/null 2>&1) \
  || !(type "unzip" > /dev/null 2>&1) \
  || !(type "clang" > /dev/null 2>&1) \
  || !(type "pdftoppm" > /dev/null 2>&1) \
  || !(type "pip" > /dev/null 2>&1) \
  || !(type "xsel" > /dev/null 2>&1); then
  echo "Install some apps...";
  sudo apt-get update
  sudo apt-get install neovim bat unzip clang build-essential x11-apps x11-utils x11-xserver-utils dbus-x11 ffmpeg poppler-utils python3-pip -y
  pip install --upgrade pynvim
  echo "Successfully installed."
fi

if !(type "fish" > /dev/null 2>&1); then
  echo "fish shell is not installed. Install fish..."
  sudo add-apt-repository ppa:fish-shell/release-3
  sudo apt-get update
  sudo apt-get install fish
  echo "Successfully installed fish."
fi
if ! [ -L ~/.config/fish/config.fish ]; then
  echo "Replace \"~/.config/fish/config.fish\" to \"~/git/dotfiles/config.fish\""
  mkdir -p ~/.config/fish
  ln -sbv ~/git/dotfiles/config.fish ~/.config/fish/config.fish
  echo "Replaced."
fi

if ! [ -e ~/.config/nvim/init.vim ]; then
  mkdir -p ~/.config/nvim
  echo 'source $HOME/git/dotfiles/nvim/init.vim' > ~/.config/nvim/init.vim
fi

if !(type "deno" > /dev/null 2>&1); then
  echo "deno is not installed. Install deno..."
  curl -fsSL https://deno.land/x/install/install.sh | sh
  echo "Successfully installed deno."
fi

if !(type "node" > /dev/null 2>&1); then
  echo "Node.js is not installed. Install Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt install nodejs
  
  mkdir -p ~/.npm-global
  npm config set prefix '~/.npm-global'
  echo "Successfully installed node and npm."
fi
if !(type "yarn" > /dev/null 2>&1); then
  echo "yarn is not installed. Install yarn..."
  npm install -g yarn
  # use yarn V2
  yarn set version berry
  echo "Successfully installed yarn."
fi

if !(type "cargo" > /dev/null 2>&1); then
  echo "Rust compile tools is not installed. Install rustup and cargo..."
  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
  echo "Successfully installed Rust compile tools."
fi

if !(type "exa" > /dev/null 2>&1); then
  echo "exa is not installed. Install exa..."
  cargo install exa
  echo "Successfully installed exa."
fi
