" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Configuring the comment toggling plugin
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" NERDCommenter:
" - Use <leader>c<space>
" ---------------------------

" https://github.com/scrooloose/nerdcommenter#default-mappings


" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
