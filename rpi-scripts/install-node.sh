#! /bin/bash
__WDIR=$(pwd)
export ARCH=`uname -m`
# TODO: Get latest version by curl scraping this URL
# https://nodejs.org/en/download/current/

CURRENT_URL="https://nodejs.org/en/download/current/"
LTS_URL="https://nodejs.org/en/download/"
DOWNLOAD_URL=$LTS_URL
NODE_DL=`curl -s $DOWNLOAD_URL | grep -E 'v[0-9][0-9]' | grep "$ARCH"`
NODE_PREFIX=$HOME/opt/node
echo $NODE_DL

# TODO: get sed regex working consistently across platforms
export NODE_VERSION=`curl -s $DOWNLOAD_URL | grep -E 'v[0-9][0-9]' | grep "$ARCH" | sed -r s/.*\(v[0-9]+\.[0-9]+.[0-9]+\).*/\\1/g | head -1`

echo $NODE_VERSION

# https://pimylifeup.com/raspberry-pi-nodejs/

which node
node --version
which npm
npm --version


cd $__WDIR
