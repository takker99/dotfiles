" An example for a vimrc file.
"
" To use it, copy it to
"     for Unix:     $HOME/.config/nvim/init.vim
"     for Windows:  %LOCALAPPDATA%\nvim\init.vim
"
"文字コードをUFT-8に設定
set encoding=utf-8
scriptencoding utf-8

echom 'This is the remote init.vim.'

let s:script_path = expand('<sfile>:p:h')
execute "source ". s:script_path. '/userautoload/init/basic.vim'
execute "source ". s:script_path. '/userautoload/init/mapping.vim'
execute "source ". s:script_path. '/userautoload/init/plugins.vim'
execute "source ". s:script_path. '/userautoload/init/color.vim'
" runtime! userautoload/init/color.vim
" runtime! $HOME/git/dotfiles/nvim/init.vim
