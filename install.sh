#! /usr/bin/bash
# Auth: Josh Wilson
# Desc: Install script for associated syntax checker tools 

#HomeBrew
brew install vim --upgrade
BREW_VIM="$(brew list vim | grep -e \"/vim\")"
echo -e "$BREW_VIM"


#alias vim="$BREW_VIM"
brew install npm
brew install cmake

#Python

#Ruby
sudo gem install rubocop

#JavaScript
npm install -g jshint
npm install -g jscs

# Vundle
if [ ! -d ".vim/bundle/Vundle.vim/.git" ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git .vim/bundle/Vundle.vim
fi
# Install Plugins
vim +PluginInstall +qall
cd .vim/bundle/YouCompleteMe
./install.py --tern-completer
cd ../../..
