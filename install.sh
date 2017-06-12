#! /usr/bin/bash
# Auth: Josh Wilson
# Desc: Install script for associated syntax checker tools

# Installation on Windows
# https://medium.com/@saaguero/setting-up-vim-in-windows-5401b1d58537#.a3huqnkx7


clear
###############################################################################
# HELPER FUNCTIONS:
###############################################################################

function warn() {
    echo "$1" >&2
}

function die() {
    warn "$1"
    exit 1
}

function confirm () {
  read -r -p "${1}? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      true
      ;;
    *)
      false
      ;;
  esac
}
function title(){
  echo -e "\033[32m===================="
  echo -e "$*"
  echo -e "====================\033[0m"
}
function notice(){
  echo -e "\033[35m$*\033[0m"
}
function pause(){
  echo -e "\033[33m"
  read -p "Press [Enter] to continue or Ctrl+C to Abort..."
  echo -e "\033[0m"
}
function show_dir () {
  echo -e "\033[94mWorking Directory:\033[0m\t $(pwd)"
}

###############################################################################
# Install Development Environment Tools
###############################################################################
function install_RHEL_dev_dependencies () {
  SUDO=`which sudo 2> /dev/null`
  HAS_YUM=`which yum 2> /dev/null`
  HAS_ZYPPER=`which zypper 2> /dev/null`
  HAS_APTGET=`which apt-get 2> /dev/null`

  PKG_MANAGER="rpm" # Centos: yum / SUSE: zypper / Ubuntu: apt-get
  if [[ -n "$HAS_YUM" ]]; then
    PKG_MANAGER="yum"
  elif [[ -n "$HAS_ZYPPER" ]]; then
    PKG_MANAGER="zypper"
  elif [[ -n "$HAS_APTGET" ]]; then
    PKG_MANAGER="apt-get"
  fi

  echo -e "PKG_MANAGER: $PKG_MANAGER"
  echo -e "HAS_YUM: $HAS_YUM"
  echo -e "HAS_ZYPPER: $HAS_ZYPPER"
  echo -e "HAS_APTGET: $HAS_APTGET"

  $SUDO $PKG_MANAGER update 
  $SUDO $PKG_MANAGER upgrade -y
  
  if [[ -n "$HAS_YUM" ]]; then
    # Add RHEL Node Repo
    $SUDO curl --silent --location https://rpm.nodesource.com/setup_7.x | bash -
    
    $SUDO $PKG_MANAGER install -y "Development Tools"
    $SUDO $PKG_MANAGER install -y cmake3 gcc-c++ make
    $SUDO $PKG_MANAGER install -y ncurses ncurses-devel
    $SUDO $PKG_MANAGER install -y clang clang-devel
    $SUDO $PKG_MANAGER install -y python python-devel
    $SUDO $PKG_MANAGER install -y ruby ruby-devel 
    $SUDO $PKG_MANAGER install -y nodejs npm
  fi
  
  if [[ -n "$HAS_APTGET" ]]; then
    $SUDO $PKG_MANAGER install -y build-essential checkinstall
    $SUDO $PKG_MANAGER install -y cmake
    $SUDO $PKG_MANAGER install -y libncurses5-dev libncursesw5-dev
    $SUDO $PKG_MANAGER install -y clang 
    $SUDO $PKG_MANAGER install -y clang clang-dev
    $SUDO $PKG_MANAGER install -y python python-dev
    $SUDO $PKG_MANAGER install -y ruby ruby-dev
    $SUDO $PKG_MANAGER install -y nodejs npm
  fi

}

function install_osx_dev_dependencies () {
  title "Installing Development Tools..."
  pause
  # install xcode command line tools
  xcode-select --install

  # install hombrew
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  notice "Homebrew update and upgrade:"
  brew update
  brew upgrade
  brew doctor

  # Git Radar / Git AutoComplete
  brew install michaeldfallen/formula/git-radar
  brew install git --with-brewed-openssl --with-brewed-curl git-flow
  
  brew install bash-completion \
    docker-completion \
    docker-compose-completion \
    docker-machine-completion \
    ruby-completion \
    gem-completion \
    bundler-completion \
    rake-completion \
    rails-completion \
    vagrant-completion \
    pip-completion 

  brew install ctags
  brew install colordiff

  # Documentation
  brew install plantuml graphviz doxygen

  # DevOps
  brew install terraform
  brew install ansible

  # C, C++, C#, Objective-C
  brew install llvm

  # Database Drivers
  brew install postgres \
    freetds \
    redis \
    influxdb \
    elasticsearch

  # Ruby
  brew install ruby ruby-build -y
  # brew install rbenv ruby-build
  # if which rbenv > /dev/null; then
  #   eval "$(rbenv init -)"
  # fi
  # rbenv install 2.4.0
  # rbenv global 2.4.0
  ruby -v
  notice "Installing Gems as SuperUser"
  sudo gem install bundler rails
  rbenv rehash

  # Python
  HAS_PIP=`which pip 2> /dev/null`
  if [[ -z "$HAS_PIP" ]];then # If it doesn't have pip yet
    curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py -o "get-pip.py"
    notice "Installing PIP and Packages as SuperUser"
    sudo python get-pip.py
  fi
  sudo pip install pip --upgrade # Get pip to manage pip
  sudo pip install -r $SCRIPT_DIR/requirements.txt --upgrade
  sudo pip install awscli --ignore-installed six
  complete -C "$(which aws_completer)" aws # Bash AWS tool autocompleter
}


###############################################################################
# Install Latest VIM from Source
###############################################################################
function build_vim () {
  cd ~
  show_dir

  echo -e "Install VIM from Source"
  if [ ! -d "./vim/.git" ]; then
    notice "Cloning a clean copy"
    sudo rm -rfv vim/
    git clone https://github.com/vim/vim.git vim/
  else 
    cd vim
    notice "Pulling latest changes"
    git pull origin master -vv
    cd ~
  fi

  cd vim/src
  show_dir
  if [[ $OSTYPE == darwin* ]]; then
    VIM_INSTALL_PREFIX="--prefix=/usr/local/"
  else
    VIM_INSTALL_PREFIX="--prefix=/usr/"
  fi
  
  SUDO=`which sudo 2> /dev/null`
  MAKE=`which make 2> /dev/null`

  if [[ -n "$MAKE" ]]; then 
    $SUDO ./configure $VIM_INSTALL_PREFIX \
      --enable-rubyinterp \
      --enable-pythoninterp \
      --with-features=huge
    $SUDO $MAKE; $SUDO $MAKE install
  fi

  cd $SCRIPT_DIR
  show_dir
}


###############################################################################
# Install VIMRC:
###############################################################################
function symlink_vimrc () {
  echo -e "\033[91mDeleting existing files..."
  rm -rfv ~/.vim
  rm -rfv ~/.vimrc
  rm -rfv ~/.jscsrc
  rm -rfv ~/.tern-project
  rm -rfv ~/.ycm_extra_conf.py
  echo -e "\033[94mSymLinking new files..."
  ln -sfv $SCRIPT_DIR/.vimrc ~/.vimrc
  ln -sfv $SCRIPT_DIR/.vim ~/.vim
  ln -sfv $SCRIPT_DIR/.jscsrc ~/.jscsrc                       # JSCS Lint Base Settings
  ln -sfv $SCRIPT_DIR/.tern-project ~/.tern-project           # YCM JS Base Settings
  ln -sfv $SCRIPT_DIR/.ycm_extra_conf.py ~/.ycm_extra_conf.py # YCM C++ Base Settings
  # Display symlinks
  ls -laFG ~ | grep -E "\->" | grep -E "\.vim"
  echo -e "\033[0m"
}


###############################################################################
# Install VIM Plugin Dependencies
###############################################################################
function install_RHEL_plugin_dependencies () {
  echo "Nothing to do here"
}

function install_osx_plugin_dependencies () {
  # TODO Make this work for environments other than OSX

  #HomeBrew
  brew install cmake npm --upgrade

  #Python

  #Ruby
  notice "Installing Gems as SuperUser"
  sudo gem install rubocop

  #JavaScript
  npm install -g \
    jshint \
    jscs \
    eslint \
    js-beautify \
    express-generator \
    mocha \
    webpack \
    doctoc
}


###############################################################################
# Install VIM Plugins
###############################################################################
function vim_plugins () {

  if [[ $OSTYPE == darwin* ]]; then
    install_osx_plugin_dependencies
  else
    notice "Plugin dependencies not defined for non OSX platforms yet."
    install_RHEL_plugin_dependencies
  fi

  # Check if Plug is already installed
  if [ ! -d ".vim/bundle/Plug.vim/autoload/.git" ]; then
    git clone https://github.com/junegunn/vim-plug.git .vim/bundle/Plug.vim/autoload
  fi
  # Install Plugins
  vim +PlugInstall +PlugUpdate +qall

  # If YCM plugin installed ask to build
  if [ -d ".vim/plugged/YouCompleteMe/.git" ]; then
    confirm "Build YouCompleteMe Autocomplete engine" && build_ycm
  fi
}

function build_ycm () {
  # Build Autocomplete
  cd $SCRIPT_DIR
  show_dir

  cd .vim/plugged/YouCompleteMe
  show_dir
  ./install.py --tern-completer --clang-completer --system-libclang

  cd $SCRIPT_DIR
  show_dir
}


###############################################################################
# INIT:
###############################################################################
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
START_DIR="$(pwd)"

cd ~
show_dir


###############################################################################
# Main Entry Point
###############################################################################
function main_installer () {
  
  ###############################
  # Install Dev Environment Tools
  ###############################
  if [[ $OSTYPE == darwin* ]]; then
    confirm "Install OSX development tools" && install_osx_dev_dependencies
  else
    confirm "Install RHEL development tools" && install_RHEL_dev_dependencies
  fi

  ##############################
  # Build Latest VIM From Source
  ##############################
  echo -e "=============================================\033[92m"
  which vim
  vim --version
  echo -e "\033[0m============================================="
  curl https://github.com/vim/vim/releases | grep tag/v

  confirm "Build latest Vim from Source" && build_vim

  ###############
  # Install VIMRC
  ###############
  confirm "Install .vimrc files" && symlink_vimrc

  ####################
  #Install VIM Plugins
  ####################
  confirm "Install Vim plugins" && vim_plugins

}

main_installer

