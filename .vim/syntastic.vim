" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Configuring the Lightline status line
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" Syntastic: Syntax/Linting Checker
" ---------------------------
let g:syntastic_aggregate_errors = 1
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1

" ---------------------------
" Syntax And Lint Checkers:
" ---------------------------

" Python:
let g:syntastic_python_checkers = ['pyflakes', 'pylint', 'python']

" Ruby:
let g:syntastic_ruby_checkers = ['rubocop']

" CPP:
let g:syntastic_cpp_checkers = ['gcc', 'clang_check', 'clang_tidy', 'cpplint']
let g:syntastic_cpp_cpplint_exec = 'cpplint'

" Web Dev:
" Each js project will need the following files:
" .eslintrc
" .jscsrc
" .jshintrc
" .tern-project
let g:syntastic_javascript_checkers = ['eslint', 'jscs']
au BufNewFile,BufRead *.ejs set filetype=html

map <c-f> :lclose<CR>

" Check On Write File:
augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost *.c,*.cpp,*.py,*.rb,*.js,*.css,*.ejs call s:syntastic()
augroup END


" Not maintained - Syntastic integration with Lightline
function! s:syntastic()
  SyntasticCheck
  "call lightline#update()
endfunction
