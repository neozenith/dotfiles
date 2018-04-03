" Author: Josh Peak
" Date: 2018-APR-01
" Description: Configuration specific to Arduino development
set encoding=utf-8
scriptencoding utf-8

" https://github.com/stevearc/vim-arduino
"
nnoremap <buffer> <leader>am :ArduinoVerify<CR>
nnoremap <buffer> <leader>au :ArduinoUpload<CR>
nnoremap <buffer> <leader>ad :ArduinoUploadAndSerial<CR>
nnoremap <buffer> <leader>ab :ArduinoChooseBoard<CR>
nnoremap <buffer> <leader>ap :ArduinoChooseProgrammer<CR>

