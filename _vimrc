set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" Plugins: Vundle
" ---------------------------
" {
  set nocompatible
  filetype off 
  set rtp+=$HOME/vimfiles/bundle/Vundle.vim
  call vundle#begin()

  " let Vundle manage Vundle, required
  Plugin 'VundleVim/Vundle.vim'

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
  Plugin 'vim-scripts/The-NERD-tree'        " File Explorer
  Plugin 'sjl/gundo.vim'                    " Undo History
  Plugin 'nathanaelkane/vim-indent-guides'  " Visualise Indent Levels
  Plugin 'kien/rainbow_parentheses.vim'     " Rainbow Color Parenthesis Nesting

  " GIT Integerations
  Plugin 'tpope/vim-fugitive'
  Plugin 'tpope/vim-git'
  Plugin 'airblade/vim-gitgutter' " Live Git Diff symbols in left gutter
  " Note to self: Git Diff article explaining how to 3 way merge with Vim
  " http://vimcasts.org/episodes/fugitive-vim-resolving-merge-conflicts-with-vimdiff/

  " STATUS LINE
  Plugin 'itchyny/lightline.vim'  " Status bar

  " SYNTAX CHECKER + HIGHLIGHTING
  Plugin 'scrooloose/syntastic'   " Syntax Check engine
  Plugin 'Chiel92/vim-autoformat' " Autoformat XML, JSON etc with :Autoformat
  Plugin 'evanmiller/nginx-vim-syntax'  " Syntax highlighting nginx configs

  " CODE COMPLETION
  Plugin 'tpope/vim-surround'
  Plugin 'tpope/vim-endwise'
  Plugin 'vim-scripts/dbext.vim'  " SQL Autocomplete and also SQL querying
  Plugin 'Valloric/YouCompleteMe' " Auto Complete Engine

  " C++ Dev
  " Ensure .ycm_extra_conf.py is filled out so compiler directives are set.
  " There is a default one in this repo that links to root user dir but it
  " should be copied into and configured per project. 
  " http://valloric.github.io/YouCompleteMe/#c-family-semantic-completion
  " https://jonasdevlieghere.com/a-better-youcompleteme-config/
  "
  "Plugin 'rdnetto/YCM-Generator' " Automatically generates YouCompleteMe configuration based on Makefile
  "
  " https://github.com/tpope/vim-dispatch
  Plugin 'tpope/vim-dispatch'     " Run build and test jobs asynchronously
  " 
  " https://github.com/alepez/vim-gtest
  " Plugin 'alepez/vim-gtest'       " Unit Testing Framework
  "
  " https://github.com/alepez/vim-llvmcov
  " Plugin 'alepez/vim-llvmcov'     " Code Covereage
  "
  " TODO: An elegant guide to refactoring as well as checking if files exist 
  " https://github.com/alepez/dotfiles/blob/master/vim/init.vim
  "
  Plugin 'octol/vim-cpp-enhanced-highlight' " smarter c++ highlight for c++11/14/17

  " # RUBY DEV
  Plugin 'vim-ruby/vim-ruby'
  Plugin 'ngmy/vim-rubocop'       " Ruby Syntax and Style Checker
  Plugin 'tpope/vim-rails' 
  Plugin 'tpope/vim-bundler'
  Plugin 'tpope/vim-rake'
  Plugin 'reinh/vim-makegreen'
  
  " # WEB DEV

  " Emmet HTML tag expander
  " type: html:5
  " to expand: ctrl-y , 
  Plugin 'mattn/emmet-vim'        " HTML/XML Tag Expander

  Plugin 'gregsexton/matchtag'    " HTML/XML Matching Tag Highlighter
  Plugin 'marijnh/tern_for_vim'   " JavaScript AutoComplete
  Plugin 'elzr/vim-json'          " JSON Style Checker
  Plugin 'ap/vim-css-color'       " Preview CSS colours with text highlighting
  Plugin 'othree/html5.vim'       " HTML5 AutoComplete
  Plugin 'othree/yajs.vim'        " YetAnotherJS syntax checker/highlighter
  
  " # PYTHON DEV
  Plugin 'fs111/pydoc.vim'
  Plugin 'alfredodeza/pytest.vim'
  
  " Patched Fonts:
  " Must be last plugin to load
  " https://github.com/ryanoasis/nerd-fonts (~2Gb)
  Plugin 'ryanoasis/vim-devicons' " Patched Fonts integrations

  call vundle#end()
" }

" ---------------------------
" BASIC CONFIGURATION:
" ---------------------------
" {
  " Windows CMDer 256 color fixes
  " http://stackoverflow.com/a/14434531 
  set term=xterm
  set t_Co=256
  let &t_AB="\e[48;5;%dm" 
  let &t_AF="\e[38;5;%dm"
  colorscheme xoria256
  
  set background=dark
  set mouse=nicr               " Set mouse scroll events to nav cursor
  syntax on                    " syntax highlighing
  filetype on                  " try to detect filetypes
  filetype plugin on
  filetype plugin indent on    " enable loading indent file for filetype
  "colorscheme molokai
  
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
  :set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<,space:␣
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

" }

" ---------------------------
" GUI CONFIGURATION:
" ---------------------------
" {
  if has("gui_running")
    if has("gui_gtk2")
      set guifont=Hack:h10
    elseif has("gui_macvim")
      set guifont=Hack:h10
    elseif has("gui_win32")
      set guifont=Hack:h10:cANSI
      set guioptions-=L           " Prevents gVim moving from Aero Snapped Positions
    endif
  endif
" }

" ---------------------------
" Autoformat: Indent, Trim Trailing Whitespace
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
  
  " au BufWritePre * :Autoformat
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
    \   'fugitive': 'FugitiveCheck',
    \   'filetype': 'DevIconsFiletype',
    \   'fileformat': 'DevIconsFileformat'
    \ },
    \ 'component': {
    \   'readonly': '%{&readonly?"\ue0a2":""}',
    \ },
    \ 'separator': { 'left': "", 'right': "" },
    \ 'subseparator': { 'left': "|", 'right': "|" }
    \ }

  function! DevIconsFiletype()
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
  endfunction

  function! DevIconsFileformat()
    return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
  endfunction

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
  let g:syntastic_cpp_checkers = ['gcc', 'clang_check', 'clang_tidy']

  " Each js project will need the following files:
  " .eslintrc
  " .jscsrc
  " .jshintrc
  " .tern-project
  let g:syntastic_javascript_checkers = ['eslint', 'jscs']
  au BufNewFile,BufRead *.ejs set filetype=html

  map <c-f> :lclose<CR>
" }

" ---------------------------
" Javascript Development: Syntax/Linting Checker
" ---------------------------
" {
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
" }

" ---------------------------
" YouCompleteMe: AutoComplete Engine
" ---------------------------
" {
  " Uncomment loaded_youcompleteme to disable YCM when on a system that 
  " does not allow YouCompleteMe plugin or have a new enough version of Vim
  "
  " NOTE: This configuration looks like it autodisables YCM when it isn't
  " supported
  " https://github.com/alepez/dotfiles/blob/master/vim/vimrc/ycm.vim#L9-L14
  " https://github.com/Valloric/YouCompleteMe/pull/2369
  if !((v:version == 704 && has('patch143') || v:version > 704) && (has('python') || has('python3')))
    let g:loaded_youcompleteme = 1
  endif

  " let g:loaded_youcompleteme = 1
  let g:ycm_key_detailed_diagnostics = ''
  let g:ycm_key_invoke_completion = ''
  let g:ycm_complete_in_strings=0
  let g:ycm_autoclose_preview_window_after_insertion = 1
  let g:ycm_confirm_extra_conf = 0 " Not super safe but just assume the .ycm_extra_conf.py is safe

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
  let NERDTreeQuitOnOpen = 1
  
  " DevIcons addon to NERDTree
  let g:webdevicons_enable_nerdtree = 1
  " Force extra padding in NERDTree so that the filetype icons line up vertically 
  let g:WebDevIconsNerdTreeGitPluginForceVAlign = 1

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
