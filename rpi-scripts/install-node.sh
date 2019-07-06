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


if [ -n "$1" ] ; then 
  export NODE_VERSION=$1
else
  # just hardcode latest LTS version as a default
  export NODE_VERSION=v10.16.0
fi


export NODE_DIST="node-$NODE_VERSION-linux-$ARCH"
echo $NODE_VERSION
echo $NODE_DIST
cd $HOME

# Download if the file is not already downloaded
if [[ ! -e "$NODE_DIST.tar.xz" ]]; then
  wget "https://nodejs.org/dist/$NODE_VERSION/$NODE_DIST.tar.xz"
fi

# Only attempt extract and install if the file made it
if [[ -e "$NODE_DIST.tar.xz" ]]; then
  tar -xvf "$NODE_DIST.tar.xz" 
  cd "$HOME/$NODE_DIST"
  mkdir -pv $NODE_PREFIX 
  [ -n "$(pwd | grep node 2> /dev/null)" ] && cp -Rv * $NODE_PREFIX
fi


if [[ -z $(cat ~/.bashrc | grep "$NODE_PREFIX" 2> /dev/null) ]]; then 
  echo "Adding the following to your .bashrc"
  echo "[[ -z \"\$(echo \$PATH | grep \"$NODE_PREFIX\")\" ]] && export PATH=$NODE_PREFIX:\$PATH"
  echo "[[ -z \"\$(echo \$PATH | grep \"$NODE_PREFIX\")\" ]] && export PATH=$NODE_PREFIX:\$PATH" >> $HOME/.bashrc
  source $HOME/.bashrc
fi

which node
node --version
which npm
npm --version
cd $__WDIR
