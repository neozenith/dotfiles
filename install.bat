@echo off
:: Auth: Josh Peak
:: Desc: Install script for associated syntax checker tools

:: Installation on Windows
:: https://medium.com/@saaguero/setting-up-vim-in-windows-5401b1d58537#.a3huqnkx7


cls

rm -rfv %HOME%\_vimrc
:: rm -rfv %HOME%\vimfiles

cp -v .vimrc %HOME%\_vimrc
xcopy /s /I /Y .vim %HOME%\vimfiles

:: https://github.com/VundleVim/Vundle.vim/wiki/Vundle-for-Windows
git clone https://github.com/VundleVim/Vundle.vim.git %USERPROFILE%/vimfiles/bundle/Vundle.vim

vim +PluginInstall +PluginUpgrade +qall

:: WIP To be able to build YCM on Windows
:: Must be admin
:: choco install cmake 7zip -y
:: PATH=%PATH%;C:\Program Files\CMake\bin;

:: Install this
:: http://releases.llvm.org/3.9.1/LLVM-3.9.1-win64.exe
