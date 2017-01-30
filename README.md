# NeoZenith VIM dotFiles

## Brief
This is not intended as a public example of *good* management of VIM dotFiles 
although I do make every attempt to apply best practices in maintaining this 
configuration purely for my own ease of use.

Since starting I have managed to solve:
 - [AutoComplete Engine](https://github.com/Valloric/YouCompleteMe)
 - Auto linting dependent upon file extension
 - Feature toggle Vim features depending upon what version of Vim is available
 - Cross platform
  - Windows (CMDer)
  - OSX iTerm2
  - Linux
    - Centos 7.2
    - OpenSUSE LEAP 42.2
 - Custom fonts and icons via [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)


## Samples

![Vim sample with file explorer][sample1]

![Vim sample with autocomplete][sample2]


[sample1]: https://raw.githubusercontent.com/neozenith/vim-dotfiles/master/screenshots/example1.png
[sample2]: https://raw.githubusercontent.com/neozenith/vim-dotfiles/master/screenshots/example2.png

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
