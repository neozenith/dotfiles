" Author: Josh Peak
" Date: 2017-JAN-17
" Description: GUI Specific settings
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" GUI CONFIGURATION:
" ---------------------------
" {
" http://vim.wikia.com/wiki/Setting_the_font_in_the_GUI
  if has("gui_running")
    if has("gui_gtk2")
      set guifont=Sauce\ Code\ Pro\ Nerd\ Font\ Complete\ Mono:h14
    elseif has("gui_macvim")
      set guifont=Sauce\ Code\ Pro\ Nerd\ Font\ Complete\ Mono:h14
    elseif has("gui_win32")
      set guifont=Sauce\ Code\ Pro\ Nerd\ Font\ Complete\ Mono:h14:cANSI
      set guioptions-=L           " Prevents gVim moving from Aero Snapped Positions
    endif
  endif
" }
