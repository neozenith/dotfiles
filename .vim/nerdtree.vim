" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Configuring the file navigation plugins. NERDTree inparticular
" but also GUndo as well.
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" NERDTree:
" - Use :n OR Ctrl+n
" ---------------------------
map <leader>n :NERDTreeToggle<CR>
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen = 1

" DevIcons Addon To NERDTree:
let g:webdevicons_enable_nerdtree = 1
" Force extra padding in NERDTree so that the filetype icons line up vertically 
let g:WebDevIconsNerdTreeGitPluginForceVAlign = 1

" ---------------------------
" GRAPHICAL UNDO TREE:
" ---------------------------
map <leader>g :GundoToggle<CR>
