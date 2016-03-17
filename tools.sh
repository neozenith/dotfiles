#! /usr/bin/bash
# Auth: Josh Wilson
# Desc: Install script for associated syntax checker tools 

#HomeBrew
brew install npm

#Python

#Ruby
gem install rubocop

#JavaScript
npm install -g jshint
npm install -g jscs

# Vundle
if [ ! -d ".vim/bundle/Vundle.vim/.git" ]; then
  git submodule add https://github.com/VundleVim/Vundle.vim.git .vim/bundle/Vundle.vim
else
  git submodule update
fi
# Install Plugins
vim +PluginInstall +qall
