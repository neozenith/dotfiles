" https://scalameta.org/metals/docs/editors/vim.html#installing-cocnvim
au BufRead,BufNewFile *.sbt set filetype=scala
" Support jsonc
autocmd FileType json syntax match Comment +\/\/.\+$+


