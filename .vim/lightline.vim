" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Configuring the Lightline status line
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" LightLine: Status Line
" ---------------------------
" Patched Font:
" http://sourcefoundry.org/hack/
"
" Patched Font For DevIcons:
" https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Hack
" https://github.com/ryanoasis/nerd-fonts/archive/master.zip

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

