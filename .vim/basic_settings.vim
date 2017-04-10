" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Settings related to plain Vim configuration
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" BASIC CONFIGURATION:
" ---------------------------
set t_Co=256
set background=dark
set mouse=nicr               " Set mouse scroll events to nav cursor
syntax on                    " syntax highlighing
filetype on                  " try to detect filetypes
filetype plugin on
filetype plugin indent on    " enable loading indent file for filetype

if has('win64') || has('win32') || has('win16')
  " Windows CMDer 256 color fixes
  " http://stackoverflow.com/a/14434531 
  set term=xterm
  set t_Co=256
  let &t_AB="\e[48;5;%dm" 
  let &t_AF="\e[38;5;%dm"
   
  " Windows CMDer Backspace Fix
  " https://github.com/Maximus5/ConEmu/issues/641
  inoremap <Char-0x07F> <BS>
  nnoremap <Char-0x07F> <BS>
  "colorscheme solarized
else
  colorscheme xoria256
endif

let &t_ZH="\e[3m"             "Italicise Comments
let &t_ZR="\e[23m"
highlight Comment cterm=italic gui=italic

set number                " Line numbers are helpful
set colorcolumn=80        " Highlight 80 character limit
set scrolloff=999          " Keep the cursor centered in the screen
set showmatch             " Highlight matching braces
set backspace=indent,eol,start  "Allow backspace in insert mode
" set list                  " Show invisible characters
" Set the characters for the invisibles
" http://stackoverflow.com/a/29787362/622276
" Needs to be Vim 7.4.710+
if ((v:version == 704 && has('patch710') || v:version > 704) )
  set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<,space:␣
else
  set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
endif

set ignorecase " case insensitive
set smartcase  " use case if any caps used 
set incsearch  " show match as search proceeds
set hlsearch   " search highlighting

" ---------------------------
" CODE FOLDING: 
" - Use :za in a method to toggle indent fold level
" - Use :zM to fold everything
" ---------------------------
set foldmethod=indent
set foldlevel=99
set foldnestmax=5       "deepest fold is 5 levels

" ---------------------------
" TABS: (2 Spaces)
" http://vi.stackexchange.com/a/4546/6958
" ---------------------------
let s:tabwidth=2
set tabstop=2      " The width of a TAB is set to 2.
                  " Still it is a \t. It is just that
                  " Vim will interpret it to be having
                  " a width of 2.
set shiftwidth=2   " Indents will have a width of 2.
set softtabstop=2  " Sets the number of columns for a TAB.
au Filetype * let &l:tabstop = s:tabwidth
au Filetype * let &l:shiftwidth = s:tabwidth
au Filetype * let &l:softtabstop = s:tabwidth
set expandtab       " Expand TABs to spaces.
set shiftround      " Round indent to multiple of 'shiftwidth'
set autoindent      " Copy indent from current line, over to the new line

" ---------------------------
" NO BACKUP FILES:
" ---------------------------
set noswapfile
set nobackup
set nowb

" ---------------------------
"  Allow Uppercase: :w :q :wq 
" ---------------------------
command! -bang -range=% -complete=file -nargs=* W <line1>,<line2>write<bang> <args>
command! -bang Q quit<bang>

" ---------------------------
" Autoformat: Indent, Trim Trailing Whitespace
" ---------------------------
" http://stackoverflow.com/a/1618401/622276
fun! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l, c)
endfun
autocmd FileType c,cpp,javascript,java,php,ruby,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
