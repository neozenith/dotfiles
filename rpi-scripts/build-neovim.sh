#! /bin/bash
  # Defaults to building static library
  # cmake -Bbuild -H. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=./dist
  # cmake --build build --target install 

  # Reconfigure for shared library
  # cmake -Bbuild -H. -DBUILD_SHARED_LIBS=ON
  # cmake --build build --target install 

  # Reconfigure to skip building the binary
  # cmake -Bbuild -H. -DBUILD_LIB_ONLY=ON
  # cmake --build build --target install 

function title(){
  echo -e "\033[32m===================="
  echo -e "$*"
  echo -e "====================\033[0m"
}
function notice(){
  echo -e "\033[35m$*\033[0m"
}
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
  $SUDO rm -rfv $HOME/neovim/
  git clone https://github.com/neovim/neovim.git neovim/
else 
  cd neovim
  notice "Pulling latest changes"
  git pull origin master -vv
  cd ~
fi

cd ~/neovim
if [[ -n "$CMAKE" ]]; then 
  
  # rm -r build
  # make clean

  if [[ -n $BUNDLE_DEPS ]]; then
    # rm -rf .deps
    mkdir -pv .deps
    cmake -B.deps -Hthird-party -DCMAKE_BUILD_TYPE=Release
    cmake --build .deps --config Release 
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
  cmake -Bbuild -H. -DCMAKE_BUILD_TYPE=Release 
  cmake --build build --config Release
  sudo cmake --build build --target install 
else
  echo "cmake not found. Not building NeoVim"
fi

