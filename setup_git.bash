# see https://scrapbox.io/takker/setup_git.sh
set -eu

catch () {
  echo "Some error have occurred. Terminate the installation."
}
trap catch ERR

if !(type "gh" > /dev/null 2>&1); then
  (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y))
  sudo mkdir -p -m 755 /etc/apt/keyrings
  out=$(mktemp)
  wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg
  cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install gh -y
  gh auth login
  gh auth setup-git
  git config --global user.email "37929109+takker99@users.noreply.github.com" 
  git config --global user.name "takker99"
fi


if ! [ -d ~/git/dotfiles ]; then
  echo "Downloading takker99/dotfiles..."
  mkdir -p ~/git
  pushd ~/git
  gh repo clone takker99/dotfiles
  popd
fi

if [ -e ~/.gitconfig ]; then
  mv ~/.gitconfig ~/.gitconfig_old
fi
