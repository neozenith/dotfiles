" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Settings related to plain Vim configuration
set encoding=utf-8
scriptencoding utf-8
set path+=**    " All file operations search recursively relative to
set mouse=nicr  " Set mouse scroll events to nav cursor

" ---------------------------
" CODE FOLDING:
" - Use :za in a method to toggle indent fold level
" - Use :zM to fold everything
" ---------------------------
" enable fold {{{
set foldmethod=indent
augroup fdm
  autocmd!
  autocmd FileType lua,go,c,cpp setlocal foldmethod=syntax
  autocmd FileType python       setlocal foldmethod=indent
  autocmd FileType vim          setlocal foldmethod=marker
augroup END
set foldlevel=1         " Fold increment (?)
set foldlevelstart=99
set foldnestmax=20       " deepest fold is 5 levels
" }}}

" ---------------
" Spell Checking:
" ---------------
au Filetype markdown   setlocal spell spelllang=en_us

" ---------------
" Markdown Setup:
" augroup markdown
  " au!
  " au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
" augroup END

" -----------------------
" Pseudo Command Palette:
" -----------------------
set wildmenu
set wildmode=longest:full,full " Vim Command list command completions and complete
