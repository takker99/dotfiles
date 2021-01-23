" memo
" - <silent>を使うと、コマンドラインにコマンドが出力されないようになる。
"   e.g
"   - nnoremap <silent>sb :b#<CR>
"   →一番下のラインには何も表示されない。
"   - nnoremap sb :b#<CR>
"   →一番下のラインには :b# が表示されない。
"
"文字コードをUFT-8に設定
set encoding=utf-8
scriptencoding utf-8

" let s:script_path = expand('<sfile>:p')
" echom '[debug]enter ' . s:script_path

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

" <C-l>にハイライト消去・ファイル変更適用効果を追加
nnoremap <C-l> :nohlsearch<CR>:checktime<CR><Esc><C-l>
nnoremap <Esc><Esc> :nohlsearch<CR>
" 検索で使う規定の正規表現を Very Magic にする
nmap / /\v

" jj で insert mode を抜ける
inoremap jj <ESC>

" WSLかどうかを判定する
" cf.https://moyapro.com/2018/03/21/detect-wsl/
function! s:isWsl()
    return filereadable('/proc/sys/fs/binfmt_misc/WSLInterop')
endfunction

" insert mode を抜けるときIMEをオフにする
" cf.https://moyapro.com/2018/04/02/disable-ime-on-wsl-vim/
if s:isWsl() && executable('AutoHotkeyU64.exe')
    augroup insertLeave
        autocmd!
        autocmd InsertLeave * :call system('AutoHotkeyU64.exe "C:/linux_home/git/dotfiles/nvim/userautoload/init/ImDisable.ahk"')
    augroup END
endif

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

" 行を移動
nnoremap <C-k> :m-2<cr>==
nnoremap <C-j> :m+<cr>==
" 複数行を移動
xnoremap <C-k> :m-2<cr>gv=gv
xnoremap <C-j> :m'>+<cr>gv=gvk

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

"押しにくい$及び^をリマッピング
nmap H ^
nmap L $
vmap H ^
vmap L $

" Enterで行ジャンプ
" cf. http://deris.hatenablog.jp/entry/2013/05/02/192415
nnoremap <Enter> G

" vp doesn't replace paste buffer
" cf. http://deris.hatenablog.jp/entry/2013/05/02/192415
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction
function! s:Repl()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
nmap <silent> <expr> p <sid>Repl()

" ウィンドウ関連
" c.f. https://qiita.com/tekkoc/items/98adcadfa4bdc8b5a6ca
" c.f. http://ivxi.hatenablog.com/entry/2013/05/23/163825
nnoremap s <Nop>
nnoremap s= <C-w>=
nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
nnoremap <silent>sd :bd<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>
nnoremap <silent>st :tabnew<CR>
nnoremap <silent>sx :tabclose<CR>
nnoremap <M-l> gt
nnoremap <M-h> gT
" function key 関連

" cf.
" 相対行番号表示の切り替え
nnoremap <F12> :set relativenumber!<CR>
" コマンドラインモードで %% を入力すると現在編集中のファイルのフォルダのパスが展開されるようにする
cnoremap %% <C-R>=expand('%:p:h').'/'<cr>

" コマンドライン補完の選択キー
set wildcharm=<TAB>
cnoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
cnoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"


" terminal の設定

" 新しいタブでターミナルを起動
nnoremap @t :tabe<CR>:terminal<CR>
" Ctrl + q でターミナルを終了
tnoremap <C-q> <C-\><C-n>:q<CR>
" ESC or jj でターミナルモードからノーマルモードへ
tnoremap <ESC> <C-\><C-n>
tnoremap jj <C-\><C-n>

" オートコンパイルする
" augroup setAutoCompile
"     autocmd!
"     autocmd BufWritePost *.tex  | :!latexmk -lualatex %
"     " autocmd BufWritePost *.c | :!gcc %:p
"     " autocmd BufWritePost *.R | :!R -f %:p
" augroup END
