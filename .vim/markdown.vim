" Author: Josh Peak
" Date: 2017-APR-10
" Description: Settings related to Markdown Plugin Vim configuration
set encoding=utf-8
scriptencoding utf-8

" https://github.com/plasticboy/vim-markdown
"
let g:vim_markdown_toc_autofit = 1

set conceallevel=2 " https://github.com/plasticboy/vim-markdown#syntax-concealing

let g:vim_markdown_frontmatter = 1
let g:vim_markdown_json_frontmatter = 1

let g:vim_markdown_new_list_item_indent = 2

" These are helpful when editting Markdown wikis when navigating links
let g:vim_markdown_autowrite = 1
let g:vim_markdown_no_extensions_in_markdown = 1


