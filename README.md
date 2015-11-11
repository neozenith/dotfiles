# NeoZenith VIM dotFiles

## Brief
This is not intended as a public example of *good* management of VIM dotFiles although I do make every attempt to apply best practices in maintaining this configuration purely for my own ease of use.

I have spent far too long curating my VIM configuration it was about time it got some version control and got backed up too. Making moving to other machines or even developing remotely easier.

## Installation
```
cd ~
git clone --recursive git@github.com:neozenith/vim.git ~/neozenith-vim
ln -s neozenith-vim/.vimrc ~/.vimrc
ln -s neozenith-vim/.vim ~/.vim
```

## Update Plugins
```
. ~/neozenith-vim/updatebundles.sh
```

## Adding Plugins
```
cd ~/neozenith-vim
git submodule add https://github.com/developer/repository.git .vim/bundle/repository
git submodule init
git submodule update
```
Then you should update the `addbundles.sh` to include the `git submodule add` command you used above just in case a clean up is required. I know the `.gitmodules` should perform this task but redundancy is good.


## Credits
Tim Pope https://github.com/tpope

Huge thanks for everything you have done for the VIM community.
