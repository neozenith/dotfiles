" Author: Josh Peak
" Date: 2017-JAN-17
" Description: GUI Specific settings
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" GUI CONFIGURATION:
" ---------------------------
" {
  if has("gui_running")
    if has("gui_gtk2")
      set guifont=Hack:h10
    elseif has("gui_macvim")
      set guifont=Hack:h10
    elseif has("gui_win32")
      set guifont=Hack:h10:cANSI
      set guioptions-=L           " Prevents gVim moving from Aero Snapped Positions
    endif
  endif
" }
