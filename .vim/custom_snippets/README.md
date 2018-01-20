# Snippets

This folder represents my own snippets that I am collecting and cherry picking 
from others.

## Snippet Engines

I am using the [UltiSnips](https://github.com/SirVer/ultisnips) snippet engine 
since it requires vim with Python and I already have a strong requirement for
python in other tools I am using.

I should in theory have [SnipMate](https://github.com/garbas/vim-snipmate) as
a backup option since it is pure VimL and if I want to port my config in a 
way that gracefully degrades to a version of vim where python support isn't 
available. That would mean maintaining two copies of my snippets. So for now, no.

## Folder structure

Each folder in this folder has to be the exact name as would be identified by the
`ftdetect` plugins of vim. Based on the filetype detected `YouCompleteMe` and
`UltiSnips` work in tandem to suggest only the snippets for that filetype.

All files in the filetype folder ending in `*.snippet` get loaded

