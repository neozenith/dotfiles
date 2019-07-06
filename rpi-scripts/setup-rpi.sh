sudo apt-get update 
sudo apt-get upgrade -y
sudo apt-get install -y terminator tmux

[ ! -d $HOME/dotfiles/.git ] && git clone https://github.com/neozenith/dotfiles

RPISCRIPTS="$HOME/dotfiles/rpi-scripts"

cd ~
. $RPISCRIPTS/install-git.sh
cd ~
. $RPISCRIPTS/install-node.sh
cd ~
. $RPISCRIPTS/install-neovim.sh
cd ~
. $RPISCRIPTS/install-docker.sh
cd ~
