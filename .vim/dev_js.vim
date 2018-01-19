" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Configuration specific to javascript development
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" Filetypes:
" ---------------------------
au BufNewFile,BufRead *.ejs set filetype=html
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
" ESLint: Linting/Parsing/Fixing
" ---------------------------
set autoread

" autofix with eslint
function! SyntasticCheckHook(errors)
  checktime
endfunction

function! PrettyFile()
  if &filetype=="javascript"
    if exists('g:loaded_Beautifier')
      call JsBeautify()
    endif
    if exists('g:loaded_ESLintFix')
      call ESLintFix()
    endif
  end
endfunction

command! ESLintFix :call ESLintFix()
command! PrettyJS :call PrettyFile()

" ---------------------------
" Syntastic: Javascript Specific Syntax and Linter checking
" ---------------------------
" Each js project will need the following files:
" .eslintrc
" .jscsrc
let g:syntastic_javascript_checkers = ['eslint', 'jscs']
" let g:syntastic_javascript_eslint_args = ['--fix']

" Check On Write File:
augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost *.js,*.css,*.ejs,*.jsx call SyntasticCheck()
augroup END


" ---------------------------
" YouCompleteMe: AutoComplete Engine Settings
" ---------------------------
" http://www.dotnetsurfers.com/blog/2016/02/08/using-vim-as-a-javascript-ide
" .tern-project -- This is for YouCompleteMe
