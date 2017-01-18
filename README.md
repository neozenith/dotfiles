# NeoZenith VIM dotFiles

## Brief
This is not intended as a public example of *good* management of VIM dotFiles 
although I do make every attempt to apply best practices in maintaining this 
configuration purely for my own ease of use.

I have spent far too long curating my VIM configuration it was about time it 
got some version control and got backed up too. Making moving to other machines 
or even developing remotely easier.

## Installation
### Mac OSX
```
cd ~
git clone https://github.com/neozenith/vim-dotfiles.git ~/nz-vim/
. nz-vim/install.sh
```
### Windows
```
cd %HOME%
git clone https://github.com/neozenith/vim-dotfiles.git nz-vim/
cd nz-vim
install.bat
```

## Update Plugins
```
vim +PluginUpdate +qall
```

## Adding Plugins
See Vundle documentation.
https://github.com/VundleVim/Vundle.vim#quick-start

## Credits
- [Tim Pope](https://github.com/tpope)
- [Alessandro Pezzato](https://github.com/alepez)

Huge thanks for everything you have done for the VIM community.
