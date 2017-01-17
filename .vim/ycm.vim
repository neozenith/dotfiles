" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Configuring the YouCompleteMe Autocomplete engine
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" YouCompleteMe: AutoComplete Engine
" ---------------------------
"
" NOTE: This configuration looks like it autodisables YCM when it isn't
" supported
" https://github.com/alepez/dotfiles/blob/master/vim/vimrc/ycm.vim#L9-L14
" https://github.com/Valloric/YouCompleteMe/pull/2369
if !((v:version == 704 && has('patch143') || v:version > 704) && (has('python') || has('python3')))
  let g:loaded_youcompleteme = 1
endif

" Disable YCM: Uncomment loaded_youcompleteme to disable YCM when on a system that 
" does not allow YouCompleteMe plugin or have a new enough version of Vim
"
" let g:loaded_youcompleteme = 1

let g:ycm_key_detailed_diagnostics = ''
let g:ycm_key_invoke_completion = ''
let g:ycm_complete_in_strings=0
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_confirm_extra_conf = 0 " Not super safe but just assume the .ycm_extra_conf.py is safe
