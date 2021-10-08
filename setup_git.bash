# see https://scrapbox.io/takker/setup_git.sh
set -eu

catch () {
  echo "Some error have occurred. Terminate the installation."
}
trap catch ERR

GITHUB_NAME="takker99"
GITHUB_EMAIL="37929109+takker99@users.noreply.github.com"
SSH_GITHUB_NAME="id_github_$GITHUB_NAME"
SSH_GITHUB_PATH="$HOME/.ssh/$SSH_GITHUB_NAME"
SSH_CONFIG_PATH="$HOME/.ssh/config"

if ! [ -e "${SSH_GITHUB_PATH}" ] || ! [ -e "${SSH_GITHUB_PATH}.pub" ]; then
  echo "SSH keys for GitHub aren't found. Creating SSH keys..."
  
  # 秘密鍵の中身を取り出す
  copyKey() {
    KEY=$(cat "${SSH_GITHUB_PATH}.pub")
    if type "clip.exe" > /dev/null 2>&1; then
      echo $KEY | clip.exe
    else
      echo $KEY | xsel
    fi
  }
  
  mkdir -p ~/.ssh
  ssh-keygen -t ed25519 -C $GITHUB_EMAIL -f $SSH_GITHUB_PATH -P "" -N ""
  copyKey
  echo "Copied the SSH public key to your clipboard. Please register it at https://github.com/settings/ssh/new"
  select i in Registered CopyAgain
  do
    case $i in
      Registered) break ;;
      CopyAgain)  echo "Copied again. Please register it" ; copyKey ;;
      *)          echo "$REPLY is an invalid value. Either \"1\" or \"2\" can be selected." ;;
    esac
  done
fi

if ! [ -e $SSH_CONFIG_PATH ]; then
  cat << EOS >> $SSH_CONFIG_PATH
Host github github.com
  User git
  IdentityFile $SSH_GITHUB_PATH
  HostName github.com
EOS
  
  ssh github || :
fi

if ! [ -d ~/git/dotfiles ]; then
  echo "Downloading takker99/dotfiles..."
  mkdir -p ~/git
  pushd ~/git
  git clone git@github.com:takker99/dotfiles.git
  popd
fi

if [ -e ~/.gitconfig ]; then
  mv ~/.gitconfig ~/.gitconfig_old
fi

cat << EOS > ~/.gitconfig
[user]
	email = $GITHUB_EMAIL
	name = $GITHUB_NAME

[gui]
	encoding = utf-8

[core]
	editor = nvim
	filemode = false
	quotepath = false

[grep]
	lineNumber = true

[alias]


[commit]
	template = ~/git/dotfiles/.commit_template

EOS
