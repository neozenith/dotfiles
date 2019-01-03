#! /bin/bash


function show_dir () {
  echo -e "\033[94mWorking Directory:\033[0m\t $(pwd)"
}

cd ~
show_dir

SUDO=`which sudo 2> /dev/null`
MAKE=`which make 2> /dev/null`
CMAKE=`which cmake 2> /dev/null`
BUNDLE_DEPS=1

# Build Dependencies
sudo apt-get install -y \
  gettext \
  libtool libtool-bin \
  autoconf automake \
  cmake \
  g++ \
  pkg-config \
  unzip

# Using ninja on RPi3B+ uses all cores for too long and overheats.
# sudo apt-get install -y ninja-build 

echo -e "Install NeoVim from Source"
if [ ! -d "$HOME/neovim/.git" ]; then
  notice "Cloning a clean copy"
  $SUDO rm -rfv neovim/
  git clone https://github.com/neovim/neovim.git neovim/
else 
  cd neovim
  notice "Pulling latest changes"
  git pull origin master -vv
  cd ~
fi

cd ~/neovim
if [[ -n "$CMAKE" ]]; then 
  
  rm -r build
  make clean

  if [[ -n $BUNDLE_DEPS ]]; then
    rm -rf .deps
    mkdir -pv .deps
    cd .deps
    cmake ../third-party -DCMAKE_BUILD_TYPE=Release
    make
    cd ..
  else
    # Bundle Dependencies
    # https://github.com/neovim/neovim/wiki/Building-Neovim#build-prerequisites
    sudo apt install -y \
      gperf \
      libluajit-5.1-dev \
      libunibilium-dev \
      libmsgpack-dev \
      libtermkey-dev \
      libvterm-dev \
      libjemalloc-dev
  fi

  mkdir -pv build
  cmake .. -DCMAKE_BUILD_TYPE=Release
  make
  sudo make install
  # make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local/neovim" CMAKE_BUILD_TYPE=Release
  # make install
else
  echo "cmake not found. Not building NeoVim"
fi

