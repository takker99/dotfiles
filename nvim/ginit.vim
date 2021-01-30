"文字コードをUFT-8に設定
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

set termguicolors
" ダーク系のカラースキームを使う
set background=dark
highlight! Normal ctermbg=NONE guibg=NONE
highlight! NonText ctermbg=NONE guibg=NONE
highlight! SpecialKey ctermbg=NONE guibg=NONE
highlight! EndOfBuffer ctermbg=NONE guibg=NONE
syntax on

