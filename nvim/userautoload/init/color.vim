"文字コードをUFT-8に設定
set encoding=utf-8
scriptencoding utf-8

" let s:script_path = expand('<sfile>:p')
" echom '[debug]enter ' . s:script_path

" ウィンドウの縦幅
" set lines=55
" ウィンドウの横幅
" set columns=180
" カラースキーム
"autocmd ColorScheme * highlight Search term=reverse cterm=reverse ctermfg=166 gui=reverse guifg=#FF8C00

"cf. https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=2ahUKEwiU9Lq2wf7mAhXSG6YKHcnJDTYQFjAAegQIBRAB&url=https%3A%2F%2Fgithub.com%2Fxaizek%2Fdotvim%2Fblob%2Fmaster%2Fftdetect%2Fxaml.vim&usg=AOvVaw3fFHYZwsk5d0Pe1r63IWXW
autocmd BufRead,BufNewFile *.xaml :set filetype=xml

" JSONでコメントがhighlightされるようにする
autocmd FileType json syntax match Comment +\/\/.\+$+

let g:markdown_fenced_languages = [
\  'coffee',
\  'css',
\  'erb=eruby',
\  'javascript',
\  'js=javascript',
\  'json=javascript',
\  'ruby',
\  'sass',
\  'xml',
\  'vim',
\  'help'
\]

"全角スペースをハイライト表示
function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=reverse ctermfg=DarkMagenta gui=reverse guifg=DarkMagenta
endfunction

if has('syntax')
    augroup ZenkakuSpace
        autocmd!
        autocmd ColorScheme       * call ZenkakuSpace()
        autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
    augroup END
    call ZenkakuSpace()
endif

" 入力補完を半透明にする
set pumblend=20

syntax enable
colorscheme solarized8_dark_low
set background=dark

" Floating Window の色設定
highlight! NormalFloat ctermbg=NONE guibg=#505050
set winblend=20

" 無色透明にする
highlight! Normal ctermbg=NONE guibg=NONE
highlight! NonText ctermbg=NONE guibg=NONE
highlight! CursorLineNr ctermbg=NONE guibg=NONE
highlight! LineNr ctermbg=NONE guibg=NONE
highlight! CursorLine ctermbg=NONE guibg=NONE
highlight! SpecialKey ctermbg=NONE guibg=NONE
highlight! EndOfBuffer ctermbg=NONE guibg=NONE
highlight! Folded ctermbg=NONE guibg=NONE
highlight! FoldColumn ctermbg=NONE guibg=NONE
highlight! DiffAdd ctermbg=NONE guibg=NONE
highlight! DiffChange ctermbg=NONE guibg=NONE
highlight! DiffDelete ctermbg=NONE guibg=NONE

" Comment を緑色にして見やすくする
highlight! Comment ctermfg=22 guifg=#3DB680

" cterm ではなく gui の色を使用する
set termguicolors
