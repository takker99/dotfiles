set -eu

catch () {
  echo "Some error have occurred. Terminate the installation."
}
trap catch ERR
 
if !(type "nvim" > /dev/null 2>&1) \
  || !(type "batcat" > /dev/null 2>&1) \
  || !(type "unzip" > /dev/null 2>&1) \
  || !(type "fish" > /dev/null 2>&1) \
  || !(type "clang" > /dev/null 2>&1) \
  || !(type "pdftoppm" > /dev/null 2>&1) \
  || !(type "xsel" > /dev/null 2>&1); then
  echo "Install some apps...";
  sudo add-apt-repository ppa:fish-shell/release-3
  sudo apt-get update
  sudo apt-get install neovim bat unzip fish clang build-essential x11-apps x11-utils x11-xserver-utils dbus-x11 ffmpeg poppler-utils -y
  echo "Successfully installed."
fi

if !(type "deno" > /dev/null 2>&1); then
  echo "`deno` is not installed. Install deno..."
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
  echo "`yarn` is not installed. Install yarn..."
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
