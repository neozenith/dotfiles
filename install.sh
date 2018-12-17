#! /bin/bash
# Auth: Josh Peak
# Desc: Install script for associated syntax checker tools

# Installation on Windows
# https://medium.com/@saaguero/setting-up-vim-in-windows-5401b1d58537#.a3huqnkx7


clear
###############################################################################
# HELPER FUNCTIONS:
###############################################################################

# Warn will echo the first argument to stderr
function warn() {
    echo "$1" >&2
}

# Die will warn the first argument and then exit
function die() {
    warn "$1"
    exit 1
}

# Confirm will prompt the user for a y/n response 
# that can be used for conditional execution
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
function install_mingw_dev_dependencies () {
  echo "Not yet implemented"

  # TODO: Auto add this to existing git bash ~/.bashrc if it isn't already in there
  # test -f ~/dotfiles/.bash_profile && . ~/dotfiles/.bash_profile
}

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
  $SUDO $PKG_MANAGER dist-upgrade -y
  
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

  # Show hidden files
  defaults write com.apple.finder AppleShowAllFiles YES
  # Use list view in all Finder windows by default
  # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`, `Nlsv`
  defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

  notice "XCode"
  # install xcode command line tools
  xcode-select --install

  notice "HomeBrew"
  # install hombrew
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  notice "Homebrew update and upgrade:"
  brew update
  brew upgrade
  brew doctor 
  brew prune

  # Git Tooling
  # brew install michaeldfallen/formula/git-radar
  brew install git --with-brewed-openssl --with-brewed-curl
  brew install nvim

  brew install bash-completion \
    pip-completion 

  brew install tree ctags fzf the_silver_searcher

  # Documentation
  # brew install graphviz doxygen

  # DevOps
  # brew install terraform ansible

  # NodeJS
  brew install node nvm
  # C, C++, C#, Objective-C
  brew install llvm
  # Golang
  brew install golang

  # Database Drivers
  brew install postgres \
    redis 

  notice "Python + Packages"
  # Python 3
  # pip comes with Python 3. Python 3 also installs "version-less" symlinks
  brew install python3
}

function install_os_independent_dev_dependencies () {
  notice "Python Packages"
  #Python

  if [[ -n `which pip3 2> /dev/null` ]]; then
    python3 -m pip3 install -r $SCRIPT_DIR/requirements.txt --upgrade 
    python3 -m pip3 install awscli --ignore-installed six --upgrade
    complete -C "$(which aws_completer)" aws # Bash AWS tool autocompleter
  else
    notice "pip3 not found"
  fi
  
  notice "NodeJS Packages"
  #JavaScript
  if [[ -n `which npm 2> /dev/null` ]]; then
    npm install -g \
      eslint \
      tslint \
      prettier \
      prettier-eslint \
      eslint-plugin-prettier \
      eslint-config-prettier \
      @neozenith/eslint-config \
      swaglint \
      express-generator \
      mocha \
      tern \
      webpack \
      neovim
    # sudo npm -g outdated
    # sudo npm -g update
  else
    notice "NPM not found"
  fi
  
}


###############################################################################
# Install Latest VIM from Source
###############################################################################
function build_vim () {
  cd ~
  show_dir
  SUDO=`which sudo 2> /dev/null`
  MAKE=`which make 2> /dev/null`

  echo -e "Install VIM from Source"
  if [ ! -d "./vim/.git" ]; then
    notice "Cloning a clean copy"
    $SUDO rm -rfv vim/
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
  echo "Installing to: $VIM_INSTALL_PREFIX"
  

  if [[ -n "$MAKE" ]]; then 
    $SUDO ./configure $VIM_INSTALL_PREFIX \
      --enable-pythoninterp \
      --enable-python3interp \
      --with-features=huge
    $SUDO $MAKE clean; $SUDO $MAKE; $SUDO $MAKE install
  else
    echo "make not found. Not building Vim"
  fi

  cd $SCRIPT_DIR
  show_dir
}


###############################################################################
# Install VIMRC:
###############################################################################
function setup_dotfiles() {
  
  LINK_ACTION="ln -sfv"
  if [[ $OSTYPE == msys* ]]; then
    LINK_ACTION="cp -vr"
  fi

  echo -e "\033[91mDeleting existing files..."
  rm -rfv ~/.vim
  rm -rfv ~/.vimrc
  rm -rfv ~/.config/nvim
  rm -rfv ~/.prettierrc.yml
  rm -rfv ~/.eslintrc.json
  rm -rfv ~/.tern-project
  rm -rfv ~/.ycm_extra_conf.py
  
  
  echo -e "\033[94mLinking new files..."
  if [[ $OSTYPE == msys* ]]; then
    $LINK_ACTION $SCRIPT_DIR/.vimrc_link ~/.vimrc
  else
    $LINK_ACTION $SCRIPT_DIR/.vimrc ~/.vimrc
    $LINK_ACTION $SCRIPT_DIR/.vim ~/.vim
  fi

  $LINK_ACTION $SCRIPT_DIR/nvim ~/.config/nvim
  $LINK_ACTION $SCRIPT_DIR/.prettierrc.yml ~/.prettierrc.yml       # Prettier JS Formatter Base Settings
  $LINK_ACTION $SCRIPT_DIR/.eslintrc.json ~/.eslintrc.json         # ESLint Base Settings
  $LINK_ACTION $SCRIPT_DIR/.tern-project ~/.tern-project           # YCM JS Base Settings
  $LINK_ACTION $SCRIPT_DIR/.ycm_extra_conf.py ~/.ycm_extra_conf.py # YCM C++ Base Settings
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

function install_mingw_plugin_dependencies () {
  echo "Nothing to do here"
}

function install_osx_plugin_dependencies () {

  notice "HomeBrew Packages"
  #HomeBrew
  brew install ninja cmake node 

  #Python
  
  #Ruby
  notice "Installing Gems as SuperUser"
  # sudo gem install rubocop
}

function install_os_independent_plugin_dependencies () {

  notice "No os-independent plugin depenencies"
}


###############################################################################
# Install VIM Plugins
###############################################################################
function vim_plugins () {

  if [[ $OSTYPE == darwin* ]]; then
    install_osx_plugin_dependencies
  elif [[ $OSTYPE == msys* ]]; then
    install_mingw_plugin_dependencies
  else
    notice "Plugin dependencies not defined for non OSX platforms yet."
    install_RHEL_plugin_dependencies
  fi
  
  install_os_independent_plugin_dependencies

  # TODO: Resolve this and .vim/plugins.vim
  # Check if Plug is already installed
  if [ ! -d "dotfiles/.vim/autoload/vim-plug/.git" ]; then
    git clone https://github.com/junegunn/vim-plug.git dotfiles/.vim/autoload/vim-plug
  fi

  # Install Plugins
  vim +PlugInstall +PlugUpdate +qall

}

function tool_check() {

  notice "Tools"
  TOOL_LIST="
    git 
    node 
    npm 
    python 
    pip 
    python3 
    pip3 
    ruby
    brew
    cmake
    ninja
    clang
    gcc
    vim 
    nvim
    rustc
    cargo
"

  for tool in $TOOL_LIST; do
    notice "${tool}"
    echo -e "`which $tool 2> /dev/null`"
    [[ -n `which ${tool} 2> /dev/null` ]] && ${tool} --version 2>&1 | head -n 1
  done
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
  
  tool_check

  ###############################
  # Install Dev Environment Tools
  ###############################
  title "OS Detected: $OSTYPE"

  if [[ $OSTYPE == darwin* ]]; then
    confirm "Install OSX development tools" && install_osx_dev_dependencies
  elif [[ $OSTYPE == msys* ]]; then
    confirm "Install Windows Git Bash (MinGW) development tools" && install_mingw_dev_dependencies
  else
    confirm "Install RHEL development tools" && install_RHEL_dev_dependencies
  fi

  confirm "Install OS Independent development tools" && install_os_independent_dev_dependencies

  ##############################
  # Build Latest VIM From Source
  ##############################
  echo -e "=============================================\033[92m"
  which vim
  vim --version
  echo -e "\033[0m============================================="

  if [[ $OSTYPE == darwin* ]]; then
    # NOTE: To strip out characters the left side regex must wild match the parts
    # You want removed and the () capture groups preserve what you want to keep
    curl -s https://github.com/vim/vim/releases | grep tag/v | sed -E 's/.*v([0-9]*)\.([0-9]*)\.([0-9]*).*/\1\.\2\.\3/'
    confirm "Build latest Vim from Source" && build_vim
  else
    notice "$OSTYPE not yet supported building latest Vim from source."
  fi

  ##################
  # Install Dotfiles
  ##################
  confirm "Setup dotfiles files" && setup_dotfiles

  ####################
  #Install VIM Plugins
  ####################
  confirm "Install Vim plugins" && vim_plugins

  
  tool_check
}

main_installer

