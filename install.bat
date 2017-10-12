@echo off
:: Auth: Josh Peak
:: Desc: Install script for associated syntax checker tools

:: Installation on Windows
:: https://medium.com/@saaguero/setting-up-vim-in-windows-5401b1d58537#.a3huqnkx7


:: DEPENDENCIES
::
:: PYTHON
:: https://www.python.org/downloads/
:: https://www.python.org/ftp/python/3.6.2/python-3.6.2.exe
::
:: CLANG
:: http://releases.llvm.org/download.html
:: http://releases.llvm.org/4.0.1/LLVM-4.0.1-win64.exe
::

call chocolatey.bat

cls

rm -rfv %HOME%\.vimrc
rm -rfv %HOME%\.vim
rm -rfv %HOME%\_vimrc
:: rm -rfv %HOME%\vimfiles

cp -v .vimrc %HOME%\_vimrc

:: JSCS Lint Base Settings
cp -v .jscsrc %HOME%\.jscsrc                       

:: YCM JS Base Settings
cp -v .tern-project %HOME%\.tern-project           

:: YCM C++ Base Settings
cp -v .ycm_extra_conf.py %HOME%\.ycm_extra_conf.py 

cp -v .gitconfig %HOME%\.gitconfig 

xcopy /f /s /I /Y .vim %HOME%\vimfiles

:: https://github.com/VundleVim/Vundle.vim/wiki/Vundle-for-Windows
IF EXIST "%HOME%\vimfiles\bundle\Plug.vim\.git" GOTO NO_CLONE_PLUG

git clone https://github.com/junegunn/vim-plug.git %HOME%\vimfiles\bundle\Plug.vim\autoload

:NO_CLONE_PLUG

vim +PlugInstall +PlugUpdate +qall


