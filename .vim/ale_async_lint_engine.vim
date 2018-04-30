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
let g:ale_linters = {
\		'typescript': ['tslint'],
\		'javascript': ['eslint'],
\		'python': ['pyflakes', 'pylint', 'python'],
\		'ruby': ['rubocop'],
\		'cpp': ['cpplint', 'clang_check', 'clang_tidy']
\}

" https://prettier.io/docs/en/vim.html#ale-configuration
let g:ale_fixers = {}
let g:ale_fixers['javascript'] = ['eslint']
let g:ale_fixers['typescript'] = ['eslint']
let g:ale_fix_on_save = 1
let g:ale_javascript_prettier_use_local_config = 1


" Do not lint or fix minified files.
let g:ale_pattern_options = {
\ '\.min\.js$': {'ale_linters': [], 'ale_fixers': []},
\ '\.min\.css$': {'ale_linters': [], 'ale_fixers': []},
\}
" If you configure g:ale_pattern_options outside of vimrc, you need this.
let g:ale_pattern_options_enabled = 1

let g:ale_lint_on_text_changed = 'never'								" Only on enter and save should ALE trigger
" let g:ale_echo_msg_format = '[%linter%][%severity%] %s'	" Set log format
let g:ale_sign_error = "\uf00d"													" Set gutter symbol
let g:ale_sign_warning = "\uf071"
