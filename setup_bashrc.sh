set -eu

catch () {
  echo "Some error have occurred. Terminate the installation."
}
trap catch ERR

cat << EOS >> ~/.bashrc

if [ -e ~/git/dotfiles/variables.sh ]; then
  . ~/git/dotfiles/variables.sh
fi
if [ -e ~/git/dotfiles/install_apps.sh ]; then
  bash ~/git/dotfiles/install_apps.sh
fi
if [ -e ~/git/dotfiles/alias.sh ]; then
  . ~/git/dotfiles/alias.sh
fi

if type "fish" > /dev/null 2>&1 ; then
  exec fish
fi
EOS

