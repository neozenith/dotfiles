#! /bin/bash
# Install dependencies required to build new versions of Python from PyEnv
# https://www.samwestby.com/tutorials/rpi-pyenv
## PyEnv

[ ! -d $HOME/.pyenv/.git ] && git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
export PATH=$PATH:$HOME/.pyenv/bin/

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libgdbm-dev \
    lzma \
    lzma-dev \
    tcl-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    wget \
    curl \
    make \
    build-essential \
    openssl

python3 ~/dotfiles/rpi-scripts/latest_pyenv_versions.py
