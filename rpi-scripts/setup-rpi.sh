#! /usr/bin/bash
sudo apt-get update 
sudo apt-get upgrade -y
sudo apt-get install -y terminator tmux zsh
sudo apt-get install -y realvnc-vnc-server realvnc-vnc-viewer
sudo apt-get install -y git neovim

[ ! -d $HOME/dotfiles/.git ] && git clone https://github.com/neozenith/dotfiles

RPISCRIPTS="$HOME/dotfiles/rpi-scripts"
# cd ~
# . $RPISCRIPTS/build-git.sh
# cd ~
# . $RPISCRIPTS/install-node.sh
# cd ~
# . $RPISCRIPTS/build-neovim.sh
# cd ~
# . $RPISCRIPTS/install-docker.sh
cd ~
