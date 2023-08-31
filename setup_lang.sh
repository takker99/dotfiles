sudo sed -i.bak -e "s/http:\/\/archive\.ubuntu\.com/http:\/\/jp\.archive\.ubuntu\.com/g" /etc/apt/sources.list
sudo apt update
sudo apt -y install language-pack-ja-base
sudo update-locale LANG=ja_JP.UTF8
cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
sudo apt -y install manpages-ja manpages-ja-dev
