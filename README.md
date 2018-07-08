# NeoZenith Vim dotFiles

## Brief

<img 
  align="right"
  alt="Vim Bonsai SVG Logo"
  src="https://cdn.rawgit.com/neozenith/vim-dotfiles/2bf070a3/images/vim-bonsai.svg" 
/>

This is not intended as a public example of *good* management of VIM dotFiles 
although I do make every attempt to apply best practices in maintaining this 
configuration purely for my own ease of use and reference. 

Like the Vim bonsai logo, it all starts with a seed and then you nurture 
and prune it for your own environment. Each person's Vim journey is different
for this reason.

----

## Highlights

 - **Font**: [Sauce Code Pro][sauce-code-pro] [(Download link)][sauce-code-pro-download]
 - **Plugin Manager**: [Vim Plug `junegunn/vim-plug`][vim-plug]
   - Use any github repo slug to reference a plugin and it downloads in parallel. Quickest setup.
 - **Autocomplete**: [YouCompleteMe `Valloric/YouCompleteMe`][ycm]
   - Hooks into Vim's autocomplete API and depending upon filetype, it asynchronously uses the right parsing engine to reference the best autocomplete and even load documentation for function specs.
 - **Linting Engine**: [ALE (Async Linting Engine) `w0rp/ale`][ale]
   - I used to use [Syntastic][syntastic] for years but linting takes time and syntastic would lock up Vim. [ALE][ale] will dispatch async jobs so I can save and eventually it'll let me know whats up. 
   - Really good when paired with the following to have a cool status bar summary of failed lints:
     - [Lightline `itchyny/lightline.vim`][lightline]
     - [Lightline-ALE `maximbaz/lightline-ale`][lightline-ale]
 - **File Management / Git**:
   - [NerdTree `scrooloose/nerdtree`][nerdtree]
   - [Vim-DevIcons `ryanoasis/vim-devicons`][vim-devicons]
   - [NerdTree Git Plugin `Xuyuanp/nerdtree-git-plugin`][nerdtree-git]
   - [Git Gutter `airblade/vim-gitgutter`][git-gutter]

[sauce-code-pro]: https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/SourceCodePro
[sauce-code-pro-download]: https://github.com/ryanoasis/nerd-fonts/releases/download/v1.2.0/SourceCodePro.zip
[vim-plug]: https://github.com/junegunn/vim-plug
[ycm]: https://github.com/Valloric/YouCompleteMe 
[ale]: https://github.com/w0rp/ale
[syntastic]: https://github.com/vim-syntastic/syntastic
[lightline]: https://github.com/itchyny/lightline.vim
[lightline-ale]: https://github.com/maximbaz/lightline-ale
[nerdtree]: https://github.com/scrooloose/nerdtree
[vim-devicons]: https://github.com/ryanoasis/vim-devicons
[nerdtree-git]: https://github.com/Xuyuanp/nerdtree-git-plugin
[git-gutter]: https://github.com/airblade/vim-gitgutter

----

## Screenshots

![Vim sample with file explorer][sample1]

![Vim sample with autocomplete][sample2]


[sample1]: https://raw.githubusercontent.com/neozenith/vim-dotfiles/master/images/example1.png
[sample2]: https://raw.githubusercontent.com/neozenith/vim-dotfiles/master/images/example2.png

----

## Git Bash Prompt 

![Screenshot of Git Prompt][gitprompt]

Inspired by the beautiful piece of bash scripting that is [Git Radar](https://github.com/michaeldfallen/git-radar) 
yet having been in companies where due to their git security setup it made git-radar unusable.

So I have built out a basic version of `git-radar`. This version does not run 
git fetch automatically in the background so you will need to run that manually.

[gitprompt]: https://raw.githubusercontent.com/neozenith/vim-dotfiles/master/images/git-prompt.png

If you want it without my complete dotfiles setup then: 

Download [`bash-scripts/function_parse_git_prompt.sh`](https://github.com/neozenith/vim-dotfiles/blob/master/bash-scripts/function_parse_git_prompt.sh)
to your home directory 

```bash
curl -o $HOME/function_parse_git_prompt.sh https://github.com/neozenith/vim-dotfiles/blob/master/bash-scripts/function_parse_git_prompt.sh
```

and add the following to your `.bash_profile` or `.bashrc`.

```bash
source $HOME/function_parse_git_prompt.sh
export PS1="\e[0;32m\w\e[m"
export PS1="$PS1 \$(parse_git_prompt)"
export PS1="$PS1\nλ "
```

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

 **nvim/init.vim**
  - This file should not change but will get symlinked to `~/.config/nvim/init.vim`
  - This file will `source ~/.vimrc` and match existing plugin configuration.

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
