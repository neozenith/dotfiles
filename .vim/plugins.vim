" Author: Josh Peak
" Date: 2017-JAN-17
" Description: This is ONLY plugin loading and should not contain plugin
" configuration.
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" Plugins: Vundle
" ---------------------------
" {
set nocompatible
filetype off 

" TODO: https://github.com/junegunn/vim-plug

" Setup Runtime Path:
if has('win64') || has('win32') || has('win16')
  set rtp=$HOME/vimfiles/bundle/Plug.vim
  call plug#begin('$HOME/vimfiles/bundle/')
else
  set rtp+=~/.vim/bundle/Plug.vim
  call plug#begin()
endif

" let Vundle manage Vundle, required
" Plug 'VundleVim/Vundle.vim'

" -------------------
"  Compulsory Components of Any Dev Environment
"  1. Syntax Coloring / Nested Bracket Coloring
"  2. Code Folding
"  3. Jump to Definition
"  4. File Explorer
"  5. Tabbed Workspace
"  6. AutoComplete
"    i.   Key Words and closing symbols for target language
"    ii.  Project Methods, Symbols and Variables
"    iii. Framework Methods and Symbols
"  7. Auto Syntax Checking
"  8. Auto Style Checking
"  9. Auto Linting
"  10. Version Control Integration
"    i. Live Diff
"    ii. Live branch name and status
"  11. Search & Replace with RegEx
"  12. Highlight matching brackets
"  13. Undo History
"  14. Auto testing TODO
"    i. unit tests TODO
"    ii. code coverage coloring TODO
" -------------------

" INTERFACE
Plug 'vim-scripts/The-NERD-tree'        " File Explorer
Plug 'sjl/gundo.vim'                    " Undo History
Plug 'nathanaelkane/vim-indent-guides'  " Visualise Indent Levels
Plug 'kien/rainbow_parentheses.vim'     " Rainbow Color Parenthesis Nesting

" GIT Integerations
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'airblade/vim-gitgutter' " Live Git Diff symbols in left gutter
" Note to self: Git Diff article explaining how to 3 way merge with Vim
" http://vimcasts.org/episodes/fugitive-vim-resolving-merge-conflicts-with-vimdiff/

" STATUS LINE

Plug 'itchyny/lightline.vim'  " Status bar

" SYNTAX CHECKER + HIGHLIGHTING


Plug 'sheerun/vim-polyglot'   " 100+ Syntax highlighters

Plug 'scrooloose/syntastic'   " Syntax Check engine
Plug 'Chiel92/vim-autoformat' " Autoformat XML, JSON etc with :Autoformat
Plug 'evanmiller/nginx-vim-syntax'  " Syntax highlighting nginx configs

" MARKDOWN
" https://github.com/plasticboy/vim-markdown
" Some useful tools to make vim generate and maintain
" markdown documents. Useful when CMS tools expect markdown input.
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

" CODE COMPLETION
Plug 'tpope/vim-surround'
Plug 'tpope/vim-endwise'
Plug 'vim-scripts/dbext.vim'  " SQL Autocomplete and also SQL querying

if has('win64') || has('win32') || has('win16')
  " No YCM Support for now
else
  Plug 'Valloric/YouCompleteMe' " Auto Complete Engine
endif


" C++ Dev
" Ensure .ycm_extra_conf.py is filled out so compiler directives are set.
" There is a default one in this repo that links to root user dir but it
" should be copied into and configured per project. 
" http://valloric.github.io/YouCompleteMe/#c-family-semantic-completion
" https://jonasdevlieghere.com/a-better-youcompleteme-config/
"
"Plugin 'rdnetto/YCM-Generator' " Automatically generates YouCompleteMe configuration based on Makefile
"
" https://github.com/tpope/vim-dispatch
Plug 'tpope/vim-dispatch'     " Run build and test jobs asynchronously
" 
" https://github.com/alepez/vim-gtest
" Plugin 'alepez/vim-gtest'       " Unit Testing Framework
"
" https://github.com/alepez/vim-llvmcov
" Plugin 'alepez/vim-llvmcov'     " Code Covereage
"
" TODO: An elegant guide to refactoring as well as checking if files exist 
" https://github.com/alepez/dotfiles/blob/master/vim/init.vim
"
Plug 'octol/vim-cpp-enhanced-highlight' " smarter c++ highlight for c++11/14/17

" # RUBY DEV
Plug 'vim-ruby/vim-ruby'
Plug 'ngmy/vim-rubocop'       " Ruby Syntax and Style Checker
Plug 'tpope/vim-rails' 
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-rake'
Plug 'reinh/vim-makegreen'

" # WEB DEV

" Emmet HTML tag expander
" type: html:5
" to expand: ctrl-y , 
Plug 'mattn/emmet-vim'        " HTML/XML Tag Expander

Plug 'gregsexton/matchtag'    " HTML/XML Matching Tag Highlighter
Plug 'marijnh/tern_for_vim'   " JavaScript AutoComplete
Plug 'elzr/vim-json'          " JSON Style Checker
Plug 'ap/vim-css-color'       " Preview CSS colours with text highlighting
Plug 'othree/html5.vim'       " HTML5 AutoComplete
Plug 'othree/yajs.vim'        " YetAnotherJS syntax checker/highlighter

" # PYTHON DEV
Plug 'fs111/pydoc.vim'
Plug 'alfredodeza/pytest.vim'

" Patched Fonts:
" Must be last plugin to load
" https://github.com/ryanoasis/nerd-fonts/releases
" https://github.com/ryanoasis/nerd-fonts/releases/download/v1.0.0/Hack.zip (9Mb)
Plug 'ryanoasis/vim-devicons' " Patched Fonts integrations

call plug#end()
