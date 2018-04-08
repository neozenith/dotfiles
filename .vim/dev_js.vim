" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Configuration specific to javascript development
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" Syntax: pangloss/vim-javascript
" ---------------------------
let g:javascript_plugin_jsdoc = 1
nnoremap <leader>jsd :<C-u>call JSDocAdd()<CR>


" ---------------------------
" Filetypes:
" ---------------------------
au BufNewFile,BufRead *.ejs set filetype=html
au BufNewFile,BufRead *.svg set filetype=html
au BufNewFile,BufRead *.jsx set filetype=javascript

" ---------------------------
" Javascript Development: Syntax/Linting Checker
" ---------------------------
" Inspired by this Stackoverflow answer
" http://stackoverflow.com/a/29819201/622276
function! JscsFix()
  "Save current cursor position"
  let l:winview = winsaveview()
  "Pipe the current buffer (%) through the jscs -x command"
  % ! jscs -x
  "Restore cursor position - this is needed as piping the file"
  "through jscs jumps the cursor to the top"
  call winrestview(l:winview)
endfunction
command! JscsFix :call JscsFix()

" ---------------------------
" YouCompleteMe: AutoComplete Engine Settings
" ---------------------------
" http://www.dotnetsurfers.com/blog/2016/02/08/using-vim-as-a-javascript-ide
" .tern-project -- This is for YouCompleteMe
