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

" Setup Runtime Path:
if has('win64') || has('win32') || has('win16')
  set rtp=$HOME/vimfiles/bundle/Vundle.vim
  call vundle#begin('$HOME/vimfiles/bundle/')
else
  set rtp+=~/.vim/bundle/Vundle.vim
  call vundle#begin()
endif

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

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
Plugin 'vim-scripts/The-NERD-tree'        " File Explorer
Plugin 'sjl/gundo.vim'                    " Undo History
Plugin 'nathanaelkane/vim-indent-guides'  " Visualise Indent Levels
Plugin 'kien/rainbow_parentheses.vim'     " Rainbow Color Parenthesis Nesting

" GIT Integerations
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-git'
Plugin 'airblade/vim-gitgutter' " Live Git Diff symbols in left gutter
" Note to self: Git Diff article explaining how to 3 way merge with Vim
" http://vimcasts.org/episodes/fugitive-vim-resolving-merge-conflicts-with-vimdiff/

" STATUS LINE

Plugin 'itchyny/lightline.vim'  " Status bar

" SYNTAX CHECKER + HIGHLIGHTING


Plugin 'sheerun/vim-polyglot'   " 100+ Syntax highlighters

Plugin 'scrooloose/syntastic'   " Syntax Check engine
Plugin 'Chiel92/vim-autoformat' " Autoformat XML, JSON etc with :Autoformat
Plugin 'evanmiller/nginx-vim-syntax'  " Syntax highlighting nginx configs

" MARKDOWN
" https://github.com/plasticboy/vim-markdown
" Some useful tools to make vim generate and maintain
" markdown documents. Useful when CMS tools expect markdown input.
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'

" CODE COMPLETION
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-endwise'
Plugin 'vim-scripts/dbext.vim'  " SQL Autocomplete and also SQL querying

if has('win64') || has('win32') || has('win16')
  " No YCM Support for now
else
  Plugin 'Valloric/YouCompleteMe' " Auto Complete Engine
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
Plugin 'tpope/vim-dispatch'     " Run build and test jobs asynchronously
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
Plugin 'octol/vim-cpp-enhanced-highlight' " smarter c++ highlight for c++11/14/17

" # RUBY DEV
Plugin 'vim-ruby/vim-ruby'
Plugin 'ngmy/vim-rubocop'       " Ruby Syntax and Style Checker
Plugin 'tpope/vim-rails' 
Plugin 'tpope/vim-bundler'
Plugin 'tpope/vim-rake'
Plugin 'reinh/vim-makegreen'

" # WEB DEV

" Emmet HTML tag expander
" type: html:5
" to expand: ctrl-y , 
Plugin 'mattn/emmet-vim'        " HTML/XML Tag Expander

Plugin 'gregsexton/matchtag'    " HTML/XML Matching Tag Highlighter
Plugin 'marijnh/tern_for_vim'   " JavaScript AutoComplete
Plugin 'elzr/vim-json'          " JSON Style Checker
Plugin 'ap/vim-css-color'       " Preview CSS colours with text highlighting
Plugin 'othree/html5.vim'       " HTML5 AutoComplete
Plugin 'othree/yajs.vim'        " YetAnotherJS syntax checker/highlighter

" # PYTHON DEV
Plugin 'fs111/pydoc.vim'
Plugin 'alfredodeza/pytest.vim'

" Patched Fonts:
" Must be last plugin to load
" https://github.com/ryanoasis/nerd-fonts/releases
" https://github.com/ryanoasis/nerd-fonts/releases/download/v1.0.0/Hack.zip (9Mb)
Plugin 'ryanoasis/vim-devicons' " Patched Fonts integrations

call vundle#end()
