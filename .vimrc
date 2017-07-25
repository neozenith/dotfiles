" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Main entrypoint script for my vim configuration
"
set encoding=utf-8
scriptencoding utf-8

" Refactoring entry point vimrc
" Sub scripts can be found in the .vim/ folder

" Plugins:
if !has('compatible')
  runtime plugins.vim  
endif

" Vi Compatible Settings: Tabs, Colors, Folding and anything that are plain Vi Settings 
runtime vi_compatible_settings.vim  

" Vim Basic Settings: Tabs, Colors, Folding and anything that are plain Vim Settings 
if !has('compatible')
  runtime basic_settings.vim  
endif

" GVim: Gui based settings
runtime gui.vim             

" Lightline: status bar configuration
runtime lightline.vim       

" Syntastic: - Linting and Syntax checker plugin configuration
if !has('compatible')
  runtime syntastic.vim       
endif

" YouCompleteMe Autocomplete Engine:
runtime ycm.vim

" NERDTree File Navigation:
runtime nerdtree.vim

" NERDCommenter:
runtime nerdcommenter.vim

" Indent Guides:
runtime indentguides.vim

" RainbowParenthesis:
runtime rainbowparenthesis.vim

" Markdown Document Editting:
runtime markdown.vim

" Dev Javascript:
if !has('compatible')
  runtime dev_js.vim
endif

" Dev Python:
runtime dev_py.vim
