" Author: Josh Peak
" Date: 2017-JAN-17
" Description: Configuration for RainbowParenthesis plugin auto highlighting 
set encoding=utf-8
scriptencoding utf-8

" ---------------------------
" RainbowParenthesis:
" ---------------------------
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
