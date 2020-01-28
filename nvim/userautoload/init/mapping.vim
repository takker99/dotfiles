"文字コードをUFT-8に設定
set encoding=utf-8
scriptencoding utf-8

" <Leader> を<Space> にする
let mapleader = "\<Space>"

" Don't use Ex mode, use Q for formatting
noremap Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" 折り返し時に表示行単位での移動できるようにする
nnoremap k   gk
nnoremap j   gj
vnoremap k   gk
vnoremap j   gj
nnoremap gk  k
nnoremap gj  j
vnoremap gk  k
vnoremap gj  j

" ESC連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>
" 検索で使う規定の正規表現を Very Magic にする
nmap / /\v

" insert mode を抜けるときIMEをオフにする
inoremap <C-[> <C-[>:set iminsert=0<CR>

" 誤動作すると困るキーを無効にする
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>

" 矢印キーを無効にする
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>

inoremap <C-h> <Nop>

inoremap <C-k> <Up>
inoremap <C-j> <Down>
inoremap <C-h> <Left>
inoremap <C-l> <Right>

" Yでカーソル位置から行末までヤンクする
nnoremap Y y$

" x,Xでカーソル文字を削除する際レジスタを汚さない
nnoremap x "_x
vnoremap x "_x
nnoremap X "_X
vnoremap X "_X

" s,Sでカーソル文字を削除する際レジスタを汚さない設定
nnoremap s "_s
vnoremap s "_s
nnoremap S "_S
vnoremap S "_S

" c.f. http://vimblog.hatenablog.com/entry/vimrc_key_mapping_examples

" ビジュアルモードで < > キーによるインデント後にビジュアルモードが解除されないようにする
vnoremap < <gv
vnoremap > >gv

" n, N キーで「次の（前の）検索候補」を画面の中心に表示する
nnoremap n nzz
nnoremap N Nzz

" 数字のインクリメント/デクリメント
nnoremap + <C-a>
nnoremap - <C-x>

" ウィンドウ関連
" c.f. https://qiita.com/tekkoc/items/98adcadfa4bdc8b5a6ca
" c.f. http://ivxi.hatenablog.com/entry/2013/05/23/163825
nnoremap s <Nop>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
nnoremap sH <C-w>H
nnoremap sr <C-w>r
nnoremap s= <C-w>=
nnoremap sw <C-w>w
nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
nnoremap <silent>sp :bprevious<CR>
nnoremap <silent>sn :bnext<CR>
nnoremap <silent>sb :b#<CR>
nnoremap <silent>sd :bd<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>

" コマンドラインモードで %% を入力すると現在編集中のファイルのフォルダのパスが展開されるようにする
cnoremap %% <C-R>=expand('%:p:h').'/'<cr>

" terminal の設定

" 新しいタブでターミナルを起動
nnoremap @t :tabe<CR>:terminal<CR>
" Ctrl + q でターミナルを終了
tnoremap <C-q> <C-\><C-n>:q<CR>
" ESCでターミナルモードからノーマルモードへ
tnoremap <ESC> <C-\><C-n>

" オートコンパイルする
" augroup setAutoCompile
"     autocmd!
"     autocmd BufWritePost *.tex  | :!latexmk -lualatex %
"     " autocmd BufWritePost *.c | :!gcc %:p
"     " autocmd BufWritePost *.R | :!R -f %:p
" augroup END
