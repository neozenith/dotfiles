filetype off
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

"CODE FOLDING - Use :za in a method to toggle indent fold level
set foldmethod=indent
set foldlevel=99

"WINDOW SPLITTING - Use Ctrl+{h,j,k,l} to open a split in movement direction
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h

"GRAPHICAL UNDO TREE
map <leader>g :GundoToggle<CR>


"SYNTAX HIGHLIGHTING
set t_Co=256
set background=dark
syntax on                    " syntax highlighing
filetype on                  " try to detect filetypes
filetype plugin indent on    " enable loading indent file for filetype

" For everything else, use a tab width of 2 space chars.
set tabstop=2       " The width of a TAB is set to 2.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 2.
set shiftwidth=2    " Indents will have a width of 2.
set softtabstop=2   " Sets the number of columns for a TAB.
set expandtab       " Expand TABs to spaces.
" colorscheme wombat

" STRIP TRAILING WHITESPACE
" http://stackoverflow.com/a/1618401/622276
fun! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l, c)
endfun
autocmd FileType c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

" STATUS LINE - LIGHTLINE
set laststatus=2  " Forces 2 lines for status bar, otherwise was getting hidden
set noshowmode    " The second line showing the normal mode is hidden. Clean
set encoding=utf-8
scriptencoding utf-8
let g:lightline = {
  \ 'colorsheme': 'wombat',
  \ 'active': {
  \   'left': [ [ 'mode' ],
  \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ]
  \ },
  \ 'component_function': {
  \   'fugitive': 'FugitiveCheck'
  \ },
  \ 'separator': { 'left': "\u25B6", 'right': "\u25C0" },
  \ 'subseparator': { 'left': "|", 'right': "|" }
  \ }

function! FugitiveCheck()
    return exists('*fugitive#head') ? fugitive#head() : ''
endfunction

"FILE BROWSER - Use :n OR Ctrl+n
map <leader>n :NERDTreeToggle<CR>
map <C-n> :NERDTreeToggle<CR>


"PYTHON
"PyFlakes - highlights invalid syntax and unused imports
let g:pyflakes_use_quickfix = 0

"PEP8 Validation
let g:pep8_map='<leader>8'

"CODE COMPLETION
au FileType python set omnifunc=pythoncomplete#Complete
let g:SuperTabDefaultCompletionType = "context"


"RUBY
"RuboCop short cut
:command RRuboCop w|RuboCop --only Style
