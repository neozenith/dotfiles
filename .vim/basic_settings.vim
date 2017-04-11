" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Settings related to plain Vim configuration
set encoding=utf-8
scriptencoding utf-8

set mouse=nicr               " Set mouse scroll events to nav cursor

" ---------------------------
" CODE FOLDING: 
" - Use :za in a method to toggle indent fold level
" - Use :zM to fold everything
" ---------------------------
set foldmethod=indent
set foldlevel=99
set foldnestmax=5       "deepest fold is 5 levels

