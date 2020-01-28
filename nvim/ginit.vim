"文字コードをUFT-8に設定
set encoding=utf-8
scriptencoding utf-8

GuiFont! Consolas:h11

" ウィンドウの縦幅
" set lines=55
" ウィンドウの横幅
" set columns=180
" カラースキーム
autocmd ColorScheme * highlight Comment ctermfg=22 guifg=#008800
autocmd ColorScheme * highlight Search term=reverse cterm=reverse ctermfg=166 gui=reverse guifg=#FF8C00
if has('multi_byte_ime')
    autocmd ColorScheme * highlight Cursor guifg=NONE guibg=Green
    autocmd ColorScheme * highlight CursorIM guifg=NONE guibg=Purple
endif
colorscheme molokai

" ダーク系のカラースキームを使う
set background=dark
syntax on

set termguicolors