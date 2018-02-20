# NeoZenith VIM dotFiles

## Brief

<img 
style="float: right;" 
alt="Vim Bonsai SVG Logo"
src="https://raw.githubusercontent.com/neozenith/vim-dotfiles/master/bonsai.svg?sanitize=true" />

This is not intended as a public example of *good* management of VIM dotFiles 
although I do make every attempt to apply best practices in maintaining this 
configuration purely for my own ease of use and reference. 

Like the Vim bonsai logo above it all starts with a seed and then you nurture 
and prune it for your own environment. Each person's Vim journey is different
for this reason.

----

## Samples

![Vim sample with file explorer][sample1]

![Vim sample with autocomplete][sample2]


[sample1]: https://raw.githubusercontent.com/neozenith/vim-dotfiles/master/screenshots/example1.png
[sample2]: https://raw.githubusercontent.com/neozenith/vim-dotfiles/master/screenshots/example2.png

----

## Installation

### OSX / Linux

```bash
cd ~
git clone https://github.com/neozenith/vim-dotfiles.git ~/nz-vim/
. nz-vim/install.sh
```

### Windows

Download latest gVim for CMDer to use that binary instead of bundled.
[Latest GVim][gvim-download]


```
cd %HOME%
git clone https://github.com/neozenith/vim-dotfiles.git nz-vim/
cd nz-vim
install.bat
```

[gvim-download]: https://github.com/vim/vim-win32-installer/releases

----

## Developing and Maintaining

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
   - Install Vim-Plug into `.vim/bundle/Plug.vim/autoload`
   - Start Vim to run `vim +PlugInstall +PlugUpdate +qall` to install 
   plugins managed by Plug.
   - *(Optional)* Build and install [YouCompleteMe][ycm]
 - Rerunning the *install.sh / install.bat* should shortcut the install
 and just update plugins.

Now that I'm working on making this cross platform and also able to feature
toggle, all additions will use GitFlow.

Safe to merge platform specific features to `develop`.

`rc/` branches should support target platforms.

`master` is safe on all target platforms and safely backs out where features
are not supported or time does not permit to download supporting systems.

----

## Cross Platform Testing

My setup is dual boot OSX and Windows native. Linux gets virtualised so I am
leveraging [Vagrant][vagrant] and [Virtual Box][vbox] to spin up Linux dev 
environments.

```bash
    
    #From this repository on windows or osx
    vagrant up
    vagrant ssh
    
    # Inside Guest VM
    . ~/nz-vim/install.sh

```

[vagrant]: https://www.vagrantup.com
[vbox]: https://www.virtualbox.org/

----
## Plugins
### Update Plugins

```
vim +PlugUpdate +qall
```

## Adding Plugins

See [Plug documentation][plug-docs]

[plug-docs]:  https://github.com/junegunn/vim-plug#example

----
## Resources and Training

These blogs have been hugely influential and informative in making the switch.

 - [VimCasts][vimcasts] - Video Tutorials
 - [Vim Adventures][vim-adventures] - Online game of Vim Tutor
 - [Thorsten Ball's Vim Resources][thorsten-ball-vim-resources]
 - [Vim Revisted][vim-revisited] - Good for explaining core navigation shortcuts
 - [Coming Home to Vim - Steve Losh][coming-home]
 - [Vim Text Objects: The Definitive Guide][text-objects]

[vimcasts]: http://vimcasts.org/
[vim-adventures]: https://vim-adventures.com/
[thorsten-ball-vim-resources]: https://thorstenball.com/blog/2012/07/09/vim-learning-resources/
[vim-revisited]: http://mislav.net/2011/12/vim-revisited/
[coming-home]: http://stevelosh.com/blog/2010/09/coming-home-to-vim/
[text-objects]: http://blog.carbonfive.com/2011/10/17/vim-text-objects-the-definitive-guide/

----

## Credits

 - [Tim Pope](https://github.com/tpope)
 - [Alessandro Pezzato](https://github.com/alepez)
 - [Thorsten Ball](https://github.com/mrnugget) 
 - [Mislav Marohnić](https://github.com/mislav)
 - [Steve Losh](https://bitbucket.org/sjl/)

Huge thanks for everything you have done for the VIM community.
