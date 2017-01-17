" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Main entrypoint script for my vim configuration
"
set encoding=utf-8
scriptencoding utf-8

" Refactoring entry point vimrc
" Sub scripts can be found in the .vim/ folder

" Vundle Plugins:
runtime plugins.vim         

" Basic Settings: Tabs, Colors, Folding and anything that are plain Vim Settings 
runtime basic_settings.vim  

" GVim: Gui based settings
runtime gui.vim             

" Lightline: status bar configuration
runtime lightline.vim       

" Syntastic: - Linting and Syntax checker plugin configuration
runtime syntastic.vim       

" YouCompleteMe Autocomplete Engine:
runtime ycm.vim

" NERDTree File Navigation:
runtime nerdtree.vim

" Indent Guides:
runtime indentguides.vim

" RainbowParenthesis:
runtime rainbowparenthesis.vim

" Dev Javascript:
runtime dev_js.vim

" Dev Python:
runtime dev_py.vim
