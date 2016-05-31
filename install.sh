#! /usr/bin/bash
# Auth: Josh Wilson
# Desc: Install script for associated syntax checker tools 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
START_DIR="$(pwd)"

cd ~
echo "$(pwd)"

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
  echo "$(pwd)"

  echo -e "Install VIM from Source"
  sudo rm -rfv vim/
  git clone git@github.com:vim/vim.git vim/
  cd vim/src
  echo "$(pwd)"
  ./configure --prefix=/usr/local/ \
    --enable-rubyinterp \
    --enable-pythoninterp \
    --with-features=huge
  sudo make; sudo make install
  
  cd $SCRIPT_DIR
  echo "$(pwd)"
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
  echo "$(pwd)"

  cd .vim/bundle/YouCompleteMe
  ./install.py --tern-completer 
  
  cd $SCRIPT_DIR
  echo "$(pwd)"
}

function main_installer () {
  echo -e "============================================="
  which vim
  vim --version
  echo -e "============================================="

  confirm "Build latest Vim from Source" && build_vim
  
  confirm "Install .vimrc files" && symlink_vimrc
  
  confirm "Install Vim vundle plugins" && vim_plugins
  
}

main_installer

