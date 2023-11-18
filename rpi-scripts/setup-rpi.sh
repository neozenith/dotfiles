#! /usr/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
START_DIR="$(pwd)"

sudo apt-get update 
sudo apt-get upgrade -y
sudo apt-get install -y terminator tmux zsh
sudo apt-get install -y realvnc-vnc-server realvnc-vnc-viewer
sudo apt-get install -y git neovim
sudo chsh -s /bin/zsh $USER

[ ! -d $HOME/dotfiles/.git ] && git clone https://github.com/neozenith/dotfiles

RPISCRIPTS="$HOME/dotfiles/rpi-scripts"

cd ~
. $RPISCRIPTS/install-node.sh
cd ~
. $RPISCRIPTS/install-pyenv.sh

cd $START_DIR
