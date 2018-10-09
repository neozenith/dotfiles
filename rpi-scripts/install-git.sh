#! /usr/bin/bash

sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get upgrade -y
sudo apt-get install autoconf -y

cd ~
git clone https://github.com/git/git
cd git

make configure
./configure --prefix=/usr
make all
sudo make install
