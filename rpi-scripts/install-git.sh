#! /usr/bin/bash
# https://www.manniwood.com/2016_07_03/compile_git_from_source.html
sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get upgrade -y
sudo apt-get install -y autoconf \
    build-essential flex bison \
    libreadline6-dev zlib1g-dev \
    libnl1 libssl-dev libnl-dev \
    libssl-dev \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    tcl tk \
    tcl-dev gettext \
    asciidoc \
    docbook2x

cd ~
git clone https://github.com/git/git
cd git

make configure
./configure --prefix=/usr/local
make all doc info
make install install-doc install-html install-info
