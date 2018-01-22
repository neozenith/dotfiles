" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Configuring the Lightline status line
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" LightLine: Status Line
" ---------------------------
"
" Patched Font For DevIcons:
" https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Hack
" https://github.com/ryanoasis/nerd-fonts/archive/master.zip

set laststatus=2	" Forces 2 lines for status bar, otherwise was getting hidden
set noshowmode		" The second line showing the normal mode is hidden. Clean
let g:lightline = {
	\ 'colorsheme': 'wombat',
	\ 'active': {
	\		'left': [
	\			[ 'mode' ],
	\			[ 'fugitive', 'readonly', 'relativepath', 'modified' ]
	\		],
	\		'right': [
	\			['linter_errors', 'linter_warnings', 'linter_ok'],
	\			['lineinfo', 'percent'],
	\			['fileformat', 'fileencoding', 'filetype']
	\		]
	\ },
	\ 'component_function': {
	\		'fugitive': 'FugitiveCheck',
	\		'filetype': 'DevIconsFiletype',
	\		'fileformat': 'DevIconsFileformat'
	\ },
	\ 'component': {
	\		'readonly': '%{&readonly?"\ue0a2":""}',
	\ },
	\ 'separator': { 'left': "", 'right': "" },
	\ 'subseparator': { 'left': "|", 'right': "|" }
	\ }

" ---------------------------
" ALE Lightline Status:
" ---------------------------
" {
let g:lightline.component_expand = {
			\		'linter_warnings': 'lightline#ale#warnings',
			\		'linter_errors': 'lightline#ale#errors',
			\		'linter_ok': 'lightline#ale#ok',
			\ }

let g:lightline.component_type = {
			\			'linter_ok': 'left',
			\			'linter_warnings': 'warning',
			\			'linter_errors': 'error',
			\ }

" Adding foreign unicode characters
" <c-v>U<8-digit hex code>
" Also see the code points for patch NerdFont fonts: https://github.com/ryanoasis/nerd-fonts#glyph-sets
" https://stackoverflow.com/a/9119790/622276
let g:lightline#ale#indicator_warnings = "\uf071"
let g:lightline#ale#indicator_errors = "\uf00d"
let g:lightline#ale#indicator_ok = "\uf00c"

" }

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

