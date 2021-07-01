#! /bin/bash

#
# https://www.reddit.com/r/neovim/comments/4r9kwa/change_vim_and_vi_command_to_nvim/

# If NeoVim installed
if [[ "$OSTYPE" != "msys" ]]; then
  if [[ -n "`which nvim 2> /dev/null`" ]]; then
    WINPTY=""
    # if [[ -n "`which winpty 2> /dev/null`" ]]; then
    #   WINPTY="winpty"
    # fi
    alias vim="$WINPTY nvim"
    alias vi="$WINPTY nvim"
    alias vimdiff="$WINPTY nvim -d"
    export EDITOR=nvim
  fi
fi
