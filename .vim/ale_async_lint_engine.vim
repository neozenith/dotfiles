" Author: Josh Peak
" Date: 2018-JAN-17
" Description: Async Linting Engine, so when a file is openned or saved it
" triggers. But this should not synchronously lock whilst all linters run before
" saving. All the save to occur but still gather and report linting metrics.
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" ALE Async Linting Engine:
" ---------------------------
" {
" let g:ale_emit_conflict_warnings = 0	" Prevent conflict with Syntastic
" }

" " Python:
" let g:syntastic_python_checkers = ['pyflakes', 'pylint', 'python']
"
" " Ruby:
" let g:syntastic_ruby_checkers = ['rubocop']
"
" " CPP:
" let g:syntastic_cpp_checkers = ['cpplint', 'gcc', 'clang_check', 'clang_tidy']
" let g:syntastic_cpp_cpplint_exec = 'cpplint'
