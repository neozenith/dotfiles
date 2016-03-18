#! /usr/bin/bash
# Auth: Josh Wilson
# Desc: Install script for associated syntax checker tools 

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ~
echo "$(pwd)"

rm -rfv ~/.vim
rm -rfv ~/.vimrc
ln -sfv $DIR/.vimrc ~/.vimrc  
ln -sfv $DIR/.vim ~/.vim
ls -laFG ~ | grep -E "\->" | grep -E "\.vim"

cd $DIR
echo "$(pwd)"


#HomeBrew
brew install vim cmake npm --upgrade
BREW_VIM="$(brew list vim | grep -e \"/vim\")"
echo -e "$BREW_VIM"

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
./install.py 
cd $DIR
echo "$(pwd)"
