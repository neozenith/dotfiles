#! /bin/bash
export ARCH=`uname -m`
# TODO: Get latest version by curl scraping this URL
# https://nodejs.org/en/download/current/
export NODE_VERSION=`curl -s https://nodejs.org/en/download/current/ | grep -E 'v[0-9][0-9]' | sed -r s/.*\(v[0-9]+\.[0-9]+.[0-9]+\).*/\\1/g | head -1`
export NODE_DIST="node-$NODE_VERSION-linux-$ARCH"
cd $HOME
wget "https://nodejs.org/dist/$NODE_VERSION/$NODE_DIST.tar.xz"
tar -xvf "$NODE_DIST.tar.xz" 
cd "$HOME/$NODE_DIST"
[ -n "$(pwd | grep node 2> /dev/null)" ] && sudo cp -Rv * /usr/local
which node
node --version
which npm
npm --version
