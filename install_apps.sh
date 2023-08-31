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
  || !(type "nkf" > /dev/null 2>&1) \
  || !(type "xsel" > /dev/null 2>&1); then
  echo "Install some apps...";
  sudo add-apt-repository ppa:neovim-ppa/unstable
  sudo apt-get update
  sudo apt-get install neovim bat unzip clang build-essential x11-apps x11-utils x11-xserver-utils dbus-x11 ffmpeg poppler-utils python3-pip nkf -y
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
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  NODE_MAJOR=20
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
  sudo apt-get update
  sudo apt-get install nodejs -y

  mkdir -p ~/.npm-global
  npm config set prefix '~/.npm-global'
  echo "Successfully installed node. Setting corepack..."
  corepack enable npm yarn pnpm --install-directory ~/.npm-global/bin
  corepack prepare npm@latest --activate
  corepack prepare pnpm@latest --activate
  corepack prepare yarn@stable --activate
  echo "Successfully set Corepack."
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
