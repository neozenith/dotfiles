" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Main entrypoint script for my vim configuration
"
set encoding=utf-8
scriptencoding utf-8

" Refactoring entry point vimrc
" Sub scripts can be found in the .vim/ folder

" TODO:
" Make better use of vim plugins paths
" https://vimways.org/2018/from-vimrc-to-vim/
" https://vimways.org/2018/runtime-hackery/
"
" Make cross platform support cleaner
" https://vimways.org/2018/make-your-setup-truly-cross-platform/


" ---------------------------
" Vi Compatible Settings: Tabs, Colors, Folding and anything that are plain Vi Settings
" ---------------------------
runtime vi_compatible_settings.vim
runtime indent_text_object.vim
" ---------------------------
" Vim Basic Settings: Tabs, Colors, Folding and anything that are plain Vim Settings
" ---------------------------
if !has('compatible')
  runtime basic_settings.vim
endif


" ---------------------------
"  PLUGINS: Plugin dependent settings
" ---------------------------
if !has('compatible')
  " Plugins:
  runtime plugins.vim
  runtime filetype_defs.vim

  " Lightline: status bar configuration
  runtime lightline.vim

  " ALE Async Linting Engine: - Linting and Syntax checker plugin configuration
  runtime ale_async_lint_engine.vim
  runtime ultisnips.vim

  " NERDTree File Navigation:
  runtime nerdtree.vim
  " NERDCommenter:
  runtime nerdcommenter.vim

  " Indent Guides:
  runtime indentguides.vim

  " RainbowParenthesis:
  runtime rainbowparenthesis.vim

  runtime dev_js.vim
  runtime dev_py.vim
  runtime dev_scala.vim
  runtime arduino.vim

  " Markdown Document Editting:
  runtime markdown.vim

  " GVim: Gui based settings
  runtime gui.vim
endif



