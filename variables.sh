# see https://scrapbox.io/takker/variables.sh
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
