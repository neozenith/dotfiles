# NeoZenith VIM dotFiles

<a href="https://stackexchange.com/users/309684">
<img src="https://stackexchange.com/users/flair/309684.png" width="208" height="58" alt="profile for NeoZenith on Stack Exchange, a network of free, community-driven Q&amp;A sites" title="profile for NeoZenith on Stack Exchange, a network of free, community-driven Q&amp;A sites">
</a>

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Brief](#brief)
- [Samples](#samples)
- [Installation](#installation)
  - [OSX / Linux](#osx--linux)
  - [Windows](#windows)
- [Developing and Maintaining](#developing-and-maintaining)
- [Cross Platform Testing](#cross-platform-testing)
- [Plugins](#plugins)
  - [Update Plugins](#update-plugins)
- [Adding Plugins](#adding-plugins)
- [Resources and Training](#resources-and-training)
  - [Vim in 10 Seconds](#vim-in-10-seconds)
  - [Vim in 5 minute](#vim-in-5-minute)
    - [Modal Text Editting](#modal-text-editting)
    - [Copy and Pasting](#copy-and-pasting)
    - [Clipboards](#clipboards)
    - [Search and Replace](#search-and-replace)
    - [Movement](#movement)
    - [Portable Configuration](#portable-configuration)
  - [Vim in 30 minutes](#vim-in-30-minutes)
- [Credits](#credits)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Brief

This is not intended as a public example of *good* management of VIM dotFiles 
although I do make every attempt to apply best practices in maintaining this 
configuration purely for my own ease of use.

I would like to think it is mature enough now that it can teach others on 
their Vim journey and also show how far I am in my own exploration. 

Since starting I have managed to solve:
 - [AutoComplete Engine][ycm]
 - Auto linting dependent upon file extension
 - Feature toggle Vim features depending upon what version of Vim is available
 - Cross platform
  - Windows (CMDer/MinGW)
  - OSX iTerm2
  - Linux
    - Centos 7.2
    - OpenSUSE LEAP 42.2
 - Custom fonts and icons via [Nerd Fonts][nerd-fonts]

[ycm]: https://github.com/Valloric/YouCompleteMe
[nerd-fonts]: https://github.com/ryanoasis/nerd-fonts

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

### Vim in 10 Seconds

 - Press `i` to enter *Insert Mode*
    - This is now like a regular text editor
 - Press `ESC` to finish editting
 - Type `:wq` to save & exit
 - Type `:q` to exit
 - Type `:q!` to force exit without saving

### Vim in 5 minute

 - [Modal Text Editting](#modal-text-editting)
 - [Copy and Pasting](#copy-and-pasting)
 - [Clipboards](#clipboards)
 - [Search and Replace](#search-and-replace)
 - [Movement](#movement)
 - [Portable Configuration](#portable-configuration)

#### Modal Text Editting

Vim has 3 modes which logically scope the types of tasks you perfom text 
editting. This scoping allows shortcuts to have a context and forces you to
really think about the nature and types of tasks you perform editting text.

**Normal Mode**
 - If you hit `ESC` enough times you'll return to this mode
 - This is your main navigation and command input mode

**Insert Mode**
 - You enter this mode from *Normal Mode* by:
    - `i`nsert
    - `I`nsert at start of line
    - `A`ppend to end of line 
 - `ESC` to return to *Normal Mode*

**Visual Mode**
 - This mode selects text to perform operations. You enter by:
   - `v` - select character by character
   - `V` - select line by line

#### Copy and Pasting

 - `y`ank (copy) text selected
 - `Y`ank (copy) entire line selected
 - `p`aste after cursor
 - `P`aste before cursor
 - `x` (cut) text selected
 - `X` (cut) lines selected

#### Clipboards

Vim has it's own clipboard which is not connected to the system clipboard by
default. It has the concept of named buffers and the system clipboard is a 
specially named buffer to which you apply the above actions.

 - `"aY` - Yank current line to clipboard `"a`
 - `"ap` - Paste the contents of clipboard `"a` after the cursor
 - `"*Y` - Yank the current line into the system clipboard `"*`
 - `"*p` - Paste the contents of the system clipboard `"*` after the cursor

#### Search and Replace

From *Normal Mode*

 - `/search-phrase` will search forward for `search-phrase`
 - `n` will tab to the next search result
 - `?search-phrase` will search backwards
 - `N` will tab backwards for next search match
 - `:%s/old/new/g` - will replace `old` with `new` everywhere in document
   - `:%s/old/new/gc` - make each change require confirmation
   - `old` could be a Regex
   - The `s/old/new/g` syntax is the same as the `sed` unix tool.
 - From *Visual mode* make a selection then type `:` and it will have `:'<,'>`
 - Complete this to look like: `:'<,'>s/old/new/g` to search and replace all
   `old` for `new` in the selected region.

#### Movement

This is where Vim diverges from your normal text editors. You may be aware of
`Home` and `End` keys that take you to the start and end of a line. Or how on a 
Mac holding Alt + -> will jump word by word.

Vim can jump forward an backward:
 - Character by character (Arrow keys)
 - Word by word (`w` word forward, `b` word backward)
 - Sentence by sentence ( `)` sentence forward, `(` sentence backward)
 - Paragraph by paragraph ( `}` paragraph forward, `{` paragraph backward)
 - Heading or brackets ( `]]` section forward, `[[` section backward)
 - Matching parenthesis, bracket or brace (`%`)

Vim has an understanding of the text structures. See *knowing where you want 
to go* in [Vim Revisited][vim-revisited] for more details.

#### Portable Configuration

 - Vi first available in 1976
 - Vim first release 1991
 - Git first avilable 2005
 - Github first available 2008
 
As you can see from my configuration it is fully text based and really good
to version control. Vi is available on most Unix systems but has been replaced
by Vim in a lot of cases.

I can go to most systems and bring my own configuration, or gracefully fall 
back to a rich core set of commands. Also there is a low setup cost since *it
is already on a lot of systems*.

Since Github it has made sharing plugins and extensions much more
social and easily available.

This is why when a new language comes out you don't need a formal release of 
Vim but the developer community have plugins in a matter of days for syntax 
highlighting, code completion, etc.
 

### Vim in 30 minutes

There is a common misconception that Vim has a huge learning curve and takes
years to understand.

**WRONG**

Type `vimtutor` at the command line and work through the lessons. That's it!

What takes years is, shaping and crafting your editor to suit you as you 
personally evolve over the years. The reason Vim has lasted for so many years
is because it is so extensible it has evolved capabilities through plugins.


----

## Credits

 - [Tim Pope](https://github.com/tpope)
 - [Alessandro Pezzato](https://github.com/alepez)
 - [Thorsten Ball](https://github.com/mrnugget) 
 - [Mislav Marohnić](https://github.com/mislav)
 - [Steve Losh](https://bitbucket.org/sjl/)

Huge thanks for everything you have done for the VIM community.
