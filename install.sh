#! /usr/bin/bash
# Auth: Josh Wilson
# Desc: Install script for associated syntax checker tools

# Installation on Windows
# https://medium.com/@saaguero/setting-up-vim-in-windows-5401b1d58537#.a3huqnkx7


clear

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

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
START_DIR="$(pwd)"

cd ~
show_dir

function symlink_vimrc () {
  echo -e "\033[91mDeleting existing files..."
  rm -rfv ~/.vim
  rm -rfv ~/.vimrc
  rm -rfv ~/.jscsrc
  rm -rfv ~/.tern-project
  echo -e "\033[94mSymLinking new files..."
  ln -sfv $SCRIPT_DIR/.vimrc ~/.vimrc
  ln -sfv $SCRIPT_DIR/.vim ~/.vim
  ln -sfv $SCRIPT_DIR/.jscsrc ~/.jscsrc
  ln -sfv $SCRIPT_DIR/.tern-project ~/.tern-project
  # Display synmlinks
  ls -laFG ~ | grep -E "\->" | grep -E "\.vim"
  echo -e "\033[0m"
}

function build_vim () {
  cd ~
  show_dir

  echo -e "Install VIM from Source"
  sudo rm -rf vim/
  git clone git@github.com:vim/vim.git vim/

  cd vim/src
  show_dir
  ./configure --prefix=/usr/local/ \
    --enable-rubyinterp \
    --enable-pythoninterp \
    --with-features=huge
  sudo make; sudo make install

  cd $SCRIPT_DIR
  show_dir
}

###############################################################################
function install_dev_dependencies () {
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
  brew install git
  brew install bash-completion
  brew install ctags

  # C, C++, C#, Objective-C
  brew install llvm

  # Database Drivers
  brew install postgres
  brew install freetds
  brew install redis

  # Ruby
  brew install rbenv ruby-build
  if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
  rbenv install 2.2.0
  rbenv global 2.2.0
  ruby -v
  notice "Installing Gems as SuperUser"
  sudo gem install bundler rails
  rbenv rehash

  # Python
  curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py -o "get-pip.py"
  notice "Installing PIP and Packages as SuperUser"
  sudo python get-pip.py
  sudo pip install --upgrade awscli boto awsebcli
}

function install_plugin_dependencies () {
  # TODO Make this work for environments other than OSX

  #HomeBrew
  brew install cmake npm --upgrade

  #Python

  #Ruby
  notice "Installing Gems as SuperUser"
  sudo gem install rubocop

  #JavaScript
  npm install -g \
    grunt-cli \
    yo \
    jshint \
    jscs \
    eslint \
    js-beautify \
    express-generator \
    mocha
}

# Vundle
function vim_plugins () {

  install_plugin_dependencies

  # Check if Vundle is already installed
  if [ ! -d ".vim/bundle/Vundle.vim/.git" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git .vim/bundle/Vundle.vim
  fi
  # Install Plugins
  vim +PluginInstall +qall

  confirm "Build YouCompleteMe Autocomplete engine" && build_ycm
}

function build_ycm () {
  # Build Autocomplete
  cd $SCRIPT_DIR
  show_dir

  cd .vim/bundle/YouCompleteMe
  show_dir
  ./install.py --tern-completer

  cd $SCRIPT_DIR
  show_dir
}

function main_installer () {
  confirm "Install development tools" && install_dev_dependencies

  echo -e "=============================================\033[92m"
  which vim
  vim --version
  echo -e "\033[0m============================================="

  confirm "Build latest Vim from Source" && build_vim

  confirm "Install .vimrc files" && symlink_vimrc

  confirm "Install Vim vundle plugins" && vim_plugins

}

main_installer

