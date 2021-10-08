sudo sed -i.bak -e "s/http:\/\/archive\.ubuntu\.com/http:\/\/jp\.archive\.ubuntu\.com/g" /etc/apt/sources.list
sudo apt update
sudo apt install language-pack-ja-base -y
sudo update-locale LANG=ja_JP.UTF8
sudo restart
sudo dpkg-reconfigure tzdata
sudo apt -y install manpages-ja manpages-ja-dev
