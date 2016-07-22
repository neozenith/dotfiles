set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" Plugins: Vundle
" ---------------------------
" {
  function! BuildYCM(info)
    " info is a dictionary with 3 fields
    " - name:   name of the plugin
    " - status: 'installed', 'updated', or 'unchanged'
    " - force:  set on PlugInstall! or PlugUpdate!
    if a:info.status == 'installed' || a:info.force
      !./install.py
    endif
  endfunction

  set nocompatible
  filetype off 
  call plug#begin()

  " -------------------
  "  Compulsory Components of Any Dev Environment
  "  1. Syntax Coloring / Nested Bracket Coloring
  "  2. Code Folding
  "  3. Jump to Definition
  "  4. File Explorer
  "  5. Tabbed Workspace
  "  6. AutoComplete
  "    i.   Key Words and closing symbols for target language
  "    ii.  Project Methods, Symbols and Variables
  "    iii. Framework Methods and Symbols
  "  7. Auto Syntax Checking
  "  8. Auto Style Checking
  "  9. Auto Linting
  "  10. Version Control Integration
  "    i. Live Diff
  "    ii. Live branch name and status
  "  11. Search & Replace with RegEx
  "  12. Highlight matching brackets
  "  13. Undo History
  "  14. Auto testing TODO
  "    i. unit tests TODO
  "    ii. code coverage coloring TODO
  " -------------------

  " INTERFACE
  Plug 'vim-scripts/The-NERD-tree'        " File Explorer
  Plug 'sjl/gundo.vim'                    " Undo History
  Plug 'nathanaelkane/vim-indent-guides'  " Visualise Indent Levels
  Plug 'kien/rainbow_parentheses.vim'     " Rainbow Color Parenthesis Nesting
  
  " GIT Integerations
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-git'
  Plug 'airblade/vim-gitgutter' " Live Git Diff symbols in left gutter
  
  " STATUS LINE
  Plug 'itchyny/lightline.vim'  " Status bar
  
  " SYNTAX CHECKER
  Plug 'scrooloose/syntastic'   " Syntax Check engine
  
  " CODE COMPLETION
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-endwise'
  Plug 'vim-scripts/dbext.vim'  " SQL Autocomplete and also SQL querying

  Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
  "Plug 'Valloric/YouCompleteMe' " Auto Complete Engine

  " # RUBY DEV
  Plug 'vim-ruby/vim-ruby'
  Plug 'ngmy/vim-rubocop'       " Ruby Syntax and Style Checker
  Plug 'tpope/vim-rails' 
  Plug 'tpope/vim-bundler'
  Plug 'tpope/vim-rake'
  Plug 'reinh/vim-makegreen'
  
  " # WEB DEV

  " Emmet HTML tag expander
  " type: html:5
  " to expand: ctrl-y , 
  Plug 'mattn/emmet-vim'        " HTML/XML Tag Expander

  Plug 'gregsexton/matchtag'    " HTML/XML Matching Tag Highlighter
  Plug 'marijnh/tern_for_vim'   " JavaScript AutoComplete
  Plug 'elzr/vim-json'          " JSON Style Checker
  Plug 'ap/vim-css-color'       " Preview CSS colours with text highlighting
  Plug 'othree/html5.vim'       " HTML5 AutoComplete
  
  " # PYTHON DEV
  Plug 'fs111/pydoc.vim'
  Plug 'vim-scripts/pep8'
  Plug 'alfredodeza/pytest.vim'
  
  call plug#end()
" }

" ---------------------------
" BASIC CONFIGURATION:
" ---------------------------
" {
  set t_Co=256
  set background=dark
  set mouse=nicr               " Set mouse scroll events to nav cursor
  syntax on                    " syntax highlighing
  filetype on                  " try to detect filetypes
  filetype plugin on
  filetype plugin indent on    " enable loading indent file for filetype
  colorscheme molokai
  set number                " Line numbers are helpful
  set colorcolumn=80        " Highlight 80 character limit
  set scrolloff=999          " Keep the cursor centered in the screen
  set showmatch             " Highlight matching braces
  set backspace=indent,eol,start  "Allow backspace in insert mode
  " set list                  " Show invisible characters
  " Set the characters for the invisibles
  " set listchars=eol:$,tab:~>,trail:~,extends:>,precedes:<
  :set ignorecase " case insensitive
  :set smartcase  " use case if any caps used 
  :set incsearch  " show match as search proceeds
  :set hlsearch   " search highlighting
  " ---------------------------
  " CODE FOLDING - Use :za in a method to toggle indent fold level
  set foldmethod=indent
  set foldlevel=99
  set foldnestmax=5       "deepest fold is 5 levels
  " ---------------------------
  " TABS (2 Spaces)
  " http://vi.stackexchange.com/a/4546/6958
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
  " NO BACKUP FILES 
  set noswapfile
  set nobackup
  set nowb

  " ---------------------------
  "  Allow Uppercase :w :q :wq 
  command! -bang -range=% -complete=file -nargs=* W <line1>,<line2>write<bang> <args>
  command! -bang Q quit<bang>
  
  " ---------------------------
  " Pretty Formatting
  " http://stackoverflow.com/questions/26214156/how-to-auto-format-json-on-save-in-vim
  "
  " autocmd FileType json autocmd BufWritePre <buffer> %!python -m json.tool
  " :%!python -m json.tool
  "
  " autocmd FileType xml autocmd BufWritePre <buffer> %!tidy -xml -q -l
  " autocmd FileType json autocmd BufWritePre <buffer> %!python -m json.tool 2>/dev/null || echo <buffer>
  " autocmd FileType json autocmd BufWritePre <buffer> %!python -m json.tool

  " :%!tidy -xml -q -l

" }

" ---------------------------
" Trim Trailing Whitespace:
" ---------------------------
" {
  " http://stackoverflow.com/a/1618401/622276
  fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
  endfun
  autocmd FileType c,cpp,javascript,java,php,ruby,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
" }

" ---------------------------
" LightLine: Status Line
" ---------------------------
" {
  " Patched Font:
  " http://sourcefoundry.org/hack/

  set laststatus=2  " Forces 2 lines for status bar, otherwise was getting hidden
  set noshowmode    " The second line showing the normal mode is hidden. Clean
  let g:lightline = {
    \ 'colorsheme': 'wombat',
    \ 'active': {
    \   'left': [ [ 'mode' ],
    \             [ 'fugitive', 'readonly', 'relativepath', 'modified' ] ],
    \   'right': [ ['lineinfo', 'percent'], ['fileformat', 'fileencoding', 'filetype'] ]
    \ },
    \ 'component_function': {
    \   'fugitive': 'FugitiveCheck'
    \ },
    \ 'component': {
    \   'readonly': '%{&readonly?"\ue0a2":""}',
    \ },
    \ 'separator': { 'left': "", 'right': "" },
    \ 'subseparator': { 'left': "|", 'right': "|" }
    \ }


  function! FugitiveCheck()
    if exists("*fugitive#head")
      let _ = fugitive#head()
      return strlen(_) ? "\ue0a0:"._ : ''
    endif
    return ''
  endfunction

  augroup AutoSyntastic
    autocmd!
    autocmd BufWritePost *.c,*.cpp,*.py,*.rb,*.js,*.css,*.ejs call s:syntastic()
  augroup END
  function! s:syntastic()
    SyntasticCheck
    "call lightline#update()
  endfunction
" }

" ---------------------------
" Syntastic: Syntax/Linting Checker
" ---------------------------
" {
  let g:syntastic_aggregate_errors = 1
  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list = 1
  let g:syntastic_check_on_open = 1
  let g:syntastic_check_on_wq = 1

  " Checkers
  let g:syntastic_python_checkers = ['pyflakes', 'pylint', 'python']
  let g:syntastic_ruby_checkers = ['rubocop']

  " Each js project will need the following files:
  " .eslintrc
  " .jscsrc
  " .jshintrc
  " .tern-project
  let g:syntastic_javascript_checkers = ['eslint', 'jscs', 'jshint']
  au BufNewFile,BufRead *.ejs set filetype=html

  map <c-f> :lclose<CR>
" }

" ---------------------------
" YouCompleteMe: AutoComplete Engine
" ---------------------------
" {
  " Uncomment loaded_youcomplteme to disable YCM when on a system that 
  " does not allow YouCompleteMe plugin or have a new enough version of Vim
  "
  " let g:loaded_youcompleteme = 1
  let g:ycm_key_detailed_diagnostics = ''
  let g:ycm_key_invoke_completion = ''
  let g:ycm_complete_in_strings=0
  let g:ycm_autoclose_preview_window_after_insertion = 1
" }

" ---------------------------
" IndentGuides:
" ---------------------------
" {
  let g:indent_guides_start_level = 2
  let g:indent_guides_auto_colors = 0
  let g:indent_guides_guide_size = 1
  hi IndentGuidesOdd  ctermbg=black
  hi IndentGuidesEven ctermbg=darkgrey
" }

" ---------------------------
" RainbowParenthesis:
" ---------------------------
" {
  au VimEnter * RainbowParenthesesToggle
  au Syntax * RainbowParenthesesLoadRound
  au Syntax * RainbowParenthesesLoadSquare
  au Syntax * RainbowParenthesesLoadBraces
" }

" ---------------------------
" Navigation Config:
" ---------------------------
" {
  " ---------------------------
  " NERDTree - Use :n OR Ctrl+n
  map <leader>n :NERDTreeToggle<CR>
  map <C-n> :NERDTreeToggle<CR>
  let NERDTreeShowHidden=1

  " ---------------------------
  " GRAPHICAL UNDO TREE
  map <leader>g :GundoToggle<CR>
" }

" ---------------------------
" Python Development:
" ---------------------------
" {
  autocmd FileType python set omnifunc=pythoncomplete#Complete
" }
