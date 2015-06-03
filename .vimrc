set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" PATHOGEN LOAD PLUGINS
" ---------------------------
filetype off
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

" ---------------------------
" BASIC CONFIGURATION
" ---------------------------
set t_Co=256
set background=dark
set mouse=nicr               " Set mouse scroll events to nav cursor
syntax on                    " syntax highlighing
filetype on                  " try to detect filetypes
filetype plugin indent on    " enable loading indent file for filetype
colorscheme molokai
set colorcolumn=80        " Highlight 80 character limit
set scrolloff=999         " Keep the cursor centered in the screen
set showmatch             " Highlight matching braces
" set list                  " Show invisible characters
" Set the characters for the invisibles
" set listchars=eol:$,tab:~>,trail:~,extends:>,precedes:<
 " ---------------------------
" CODE FOLDING - Use :za in a method to toggle indent fold level
set foldmethod=indent
set foldlevel=99
" ---------------------------
" TABS (2 Spaces)
set tabstop=2       " The width of a TAB is set to 2.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 2.
set shiftwidth=2    " Indents will have a width of 2.
set softtabstop=2   " Sets the number of columns for a TAB.
set expandtab       " Expand TABs to spaces.

" ---------------------------
" STATUS LINE - LIGHTLINE
" ---------------------------
set laststatus=2  " Forces 2 lines for status bar, otherwise was getting hidden
set noshowmode    " The second line showing the normal mode is hidden. Clean
let g:lightline = {
  \ 'colorsheme': 'wombat',
  \ 'active': {
  \   'left': [ [ 'mode' ],
  \             [ 'fugitive', 'readonly', 'relativepath', 'filename', 'modified' ] ]
  \ },
  \ 'component_function': {
  \   'fugitive': 'FugitiveCheck'
  \ },
  \ 'separator': { 'left': "\u25B6", 'right': "\u25C0" },
  \ 'subseparator': { 'left': "|", 'right': "|" }
  \ }

fun! FugitiveCheck()
    return exists('*fugitive#head') ? fugitive#head() : ''
endfun

" ---------------------------
" NAVIGATION CONFIGURATION
" ---------------------------

" ---------------------------
" NERDTree - Use :n OR Ctrl+n
map <leader>n :NERDTreeToggle<CR>
map <C-n> :NERDTreeToggle<CR>
" ---------------------------
" WINDOW SPLITTING - Use Ctrl+{h,j,k,l} to open a split in movement direction
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h
" ---------------------------
" GRAPHICAL UNDO TREE
map <leader>g :GundoToggle<CR>


" ---------------------------
" PYTHON DEVELOPMENT
" ---------------------------
" PEP8 Validation
let g:pep8_map='<leader>8'


" ---------------------------
" RUBY DEVELOPMENT
" ---------------------------
" RuboCop Validator short cut. Saves buffer and runs style cop
:command RRuboCop w|RuboCop --only Style

" ---------------------------
" STRIP TRAILING WHITESPACE
" ---------------------------
" http://stackoverflow.com/a/1618401/622276
fun! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l, c)
endfun
autocmd FileType c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

