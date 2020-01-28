"文字コードをUFT-8に設定
set encoding=utf-8
scriptencoding utf-8

" ウィンドウの縦幅
" set lines=55
" ウィンドウの横幅
" set columns=180
" カラースキーム
"autocmd ColorScheme * highlight Comment ctermfg=22 guifg=#008800
"autocmd ColorScheme * highlight Search term=reverse cterm=reverse ctermfg=166 gui=reverse guifg=#FF8C00
"c.f. https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=2ahUKEwiU9Lq2wf7mAhXSG6YKHcnJDTYQFjAAegQIBRAB&url=https%3A%2F%2Fgithub.com%2Fxaizek%2Fdotvim%2Fblob%2Fmaster%2Fftdetect%2Fxaml.vim&usg=AOvVaw3fFHYZwsk5d0Pe1r63IWXW
autocmd BufRead,BufNewFile *.xaml :set filetype=xml

" ダーク系のカラースキームを使う
set background=dark
syntax on

set termguicolors
