#! /usr/bin/bash

git submodule add http://github.com/tpope/vim-fugitive.git .vim/bundle/fugitive
git submodule add https://github.com/msanders/snipmate.vim.git .vim/bundle/snipmate
git submodule add https://github.com/tpope/vim-surround.git .vim/bundle/surround
git submodule add https://github.com/tpope/vim-git.git .vim/bundle/git
git submodule add https://github.com/ervandew/supertab.git .vim/bundle/supertab
git submodule add https://github.com/wincent/Command-T.git .vim/bundle/command-t
git submodule add https://github.com/mitechie/pyflakes-pathogen.git
git submodule add https://github.com/mileszs/ack.vim.git .vim/bundle/ack
git submodule add https://github.com/sjl/gundo.vim.git .vim/bundle/gundo
git submodule add https://github.com/fs111/pydoc.vim.git .vim/bundle/pydoc
git submodule add https://github.com/vim-scripts/pep8.git .vim/bundle/pep8
git submodule add https://github.com/alfredodeza/pytest.vim.git .vim/bundle/py.test
git submodule add https://github.com/reinh/vim-makegreen .vim/bundle/makegreen
git submodule add https://github.com/vim-scripts/The-NERD-tree.git .vim/bundle/nerdtree
git submodule add https://github.com/vim-ruby/vim-ruby.git .vim/bundle/vim-ruby
git submodule add https://github.com/ngmy/vim-rubocop.git .vim/bundle/vim-rubocop
git submodule add git://github.com/tpope/vim-rails.git .vim/bundle/vim-rails 
git submodule add git://github.com/tpope/vim-bundler.git .vim/bundle/vim-bundler
git submodule add https://github.com/tpope/vim-rake.git .vim/bundle/vim-rake
git submodule add https://github.com/tpope/vim-endwise.git .vim/bundle/vim-endwise
git submodule add https://github.com/elzr/vim-json.git .vim/bundle/vim-json
git submodule add https://github.com/itchyny/lightline.vim .vim/bundle/lightline.vim

git submodule init
git submodule update
git submodule foreach git submodule init
git submodule foreach git submodule update
