#! /bin/bash

#
# https://www.reddit.com/r/neovim/comments/4r9kwa/change_vim_and_vi_command_to_nvim/

# If NeoVim installed
if [[ -n "`which nvim 2> /dev/null`" ]]; then
  alias vim="nvim"
  alias vi="nvim"
  alias vimdiff="nvim -d"
  export EDITOR=nvim
fi
