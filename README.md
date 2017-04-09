# NeoZenith VIM dotFiles

<a href="https://stackexchange.com/users/309684">
<img src="https://stackexchange.com/users/flair/309684.png" width="208" height="58" alt="profile for NeoZenith on Stack Exchange, a network of free, community-driven Q&amp;A sites" title="profile for NeoZenith on Stack Exchange, a network of free, community-driven Q&amp;A sites">
</a>

## Brief

This is not intended as a public example of *good* management of VIM dotFiles 
although I do make every attempt to apply best practices in maintaining this 
configuration purely for my own ease of use.

I would like to think it is mature enough now that it can teach others on 
their Vim journey and also show how far I am in my own exploration. 

Since starting I have managed to solve:
 - [AutoComplete Engine](https://github.com/Valloric/YouCompleteMe)
 - Auto linting dependent upon file extension
 - Feature toggle Vim features depending upon what version of Vim is available
 - Cross platform
  - Windows (CMDer/MinGW)
  - OSX iTerm2
  - Linux
    - Centos 7.2
    - OpenSUSE LEAP 42.2
 - Custom fonts and icons via [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)

----

## Samples

![Vim sample with file explorer][sample1]

![Vim sample with autocomplete][sample2]


[sample1]: https://raw.githubusercontent.com/neozenith/vim-dotfiles/master/screenshots/example1.png
[sample2]: https://raw.githubusercontent.com/neozenith/vim-dotfiles/master/screenshots/example2.png

----

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

----

## Developing / Maintaining

**.vimrc**
 - The key entry file for vim configuration. 
 - This should only source vim scripts for features and commenting 
 out one shouldn't affect others. 

**.vim/mysubcript.vim**
 - Supporting files are located in `.vim/` and are *sourced* using the `runtime` 
path.

**install.sh / install.bat**
 - These have 5-7 goals:
   - Install supporting tools like Ruby / Python / CMake / Node
   - *(Optional)* Install and build latest Vim from Source
   - Install `.vimrc`
   - Install `.vim/` and associated `.vim/*.vim` scripts.
   - Install Vundle into `.vim/bundle/Vundle`
   - Start Vim to run `vim +PluginInstall +PluginUpdate +qall` to install 
   plugins managed by Vundle.
   - *(Optional)* Build and install [YouCompleteMe](https://github.com/Valloric/YouCompleteMe)
 - Rerunning the *install.sh / install.bat* should shortcut the install
 and just update plugins.

Now that I'm working on making this cross platform and also able to feature
toggle, all additions will use GitFlow.

Safe to merge platform specific features to `develop`.

`rc/` branches should support target platforms.

`master` is safe on all target platforms and safely backs out where features
are not supported or time does not permit to download supporting systems.

----
## Plugins
### Update Plugins

```
vim +PluginUpdate +qall
```

## Adding Plugins

See [Vundle documentation](https://github.com/VundleVim/Vundle.vim#quick-start)

----
## Resources and Training

 - [VimCasts](http://vimcasts.org/) - Video Tutorials
 - [Vim Adventures](https://vim-adventures.com/) - Online game of Vim Tutor
 - [Thorsten Ball's Vim Resources](https://thorstenball.com/blog/2012/07/09/vim-learning-resources/)

----

## Credits

 - [Tim Pope](https://github.com/tpope)
 - [Alessandro Pezzato](https://github.com/alepez)
 - [Thorsten Ball](https://github.com/mrnugget) 

Huge thanks for everything you have done for the VIM community.
