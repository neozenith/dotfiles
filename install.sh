#! /usr/bin/bash
# Auth: Josh Wilson
# Desc: Install script for associated syntax checker tools 

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
  echo -e "\033[94mSymLinking new files..."
  ln -sfv $SCRIPT_DIR/.vimrc ~/.vimrc  
  ln -sfv $SCRIPT_DIR/.vim ~/.vim
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

function install_plugin_dependencies () {
  # TODO Make this work for environments other than OSX
  
  #HomeBrew
  brew install cmake npm --upgrade

  #Python

  #Ruby
  sudo gem install rubocop

  #JavaScript
  npm install -g \
    jshint \
    jscs \
    eslint \
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
  echo -e "=============================================\033[92m"
  which vim
  vim --version
  echo -e "\033[0m============================================="

  confirm "Build latest Vim from Source" && build_vim
  
  confirm "Install .vimrc files" && symlink_vimrc
  
  confirm "Install Vim vundle plugins" && vim_plugins
  
}

main_installer

