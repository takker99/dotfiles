" memo
" - Using <silent> prevents the command from being printed on the command line.
"   e.g
"   - nnoremap <silent>sb :b#<CR>
"   -> nothing is shown on the bottom line.
"   - nnoremap sb :b#<CR>
"   -> :b# is not shown on the bottom line.
"
" Set character encoding to UTF-8
scriptencoding utf-8

" let s:script_path = expand('<sfile>:p')
" echom '[debug]enter ' . s:script_path

" Set <Leader> to <Space>
let mapleader = "\<Space>"

" Don't use Ex mode, use Q for formatting
noremap Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Move by display line when wrapped
nnoremap k   gk
nnoremap j   gj
vnoremap k   gk
vnoremap j   gj
nnoremap gk  k
nnoremap gj  j
vnoremap gk  k
" Add highlight clearing and file change reload to <C-l>
nnoremap <C-l> :nohlsearch<CR>:checktime<CR><Esc><C-l>
nnoremap <Esc><Esc> :nohlsearch<CR>
" Use Very Magic regex for search by default
nmap / /\v

" Leave insert mode with jj
inoremap jj <ESC>

" Detect whether running under WSL
" cf.https://moyapro.com/2018/03/21/detect-wsl/
function! s:isWsl()
    return filereadable('/proc/sys/fs/binfmt_misc/WSLInterop')
endfunction

" Removed because it doesn't work
" Turn off the IME when leaving insert mode
" cf.https://moyapro.com/2018/04/02/disable-ime-on-wsl-vim/
" if s:isWsl() && executable('AutoHotkeyU64.exe')
"     augroup insertLeave
"         autocmd!
"         autocmd InsertLeave * :call system('AutoHotkeyU64.exe "C:/linux_home/git/dotfiles/nvim/userautoload/init/ImDisable.ahk"')
"     augroup END
" endif

" Disable keys that would cause trouble if accidentally pressed
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>

" Disable arrow keys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>

" Move lines
nnoremap <C-k> :m-2<cr>==
nnoremap <C-j> :m+<cr>==
" Move multiple lines
xnoremap <C-k> :m-2<cr>gv=gv
xnoremap <C-j> :m'>+<cr>gv=gvk

" Yank from cursor to end of line with Y
nnoremap Y y$

" Don't clobber the register when deleting the character under the cursor with x/X
nnoremap x "_x
vnoremap x "_x
nnoremap X "_X
vnoremap X "_X

" Don't clobber the register when deleting the character under the cursor with s/S
nnoremap s "_s
vnoremap s "_s
nnoremap S "_S
vnoremap S "_S

" c.f. http://vimblog.hatenablog.com/entry/vimrc_key_mapping_examples

" Keep visual mode active after indenting with < > keys
vnoremap < <gv
vnoremap > >gv

" Center the next (previous) search match on screen with n/N
nnoremap n nzz
nnoremap N Nzz

" Increment/decrement numbers
nnoremap + <C-a>
nnoremap - <C-x>

" Remap hard-to-reach $ and ^
nmap H ^
nmap L $
vmap H ^
vmap L $

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

" Window related
" c.f. https://qiita.com/tekkoc/items/98adcadfa4bdc8b5a6ca
" c.f. http://ivxi.hatenablog.com/entry/2013/05/23/163825
nnoremap s <Nop>
nnoremap s= <C-w>=
nnoremap sh <C-w>h
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sp :bprevious<CR>
nnoremap sn :bnext<CR>
nnoremap sr <C-w>r
nnoremap sw <C-w>w
nnoremap sH <C-w>H
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
nnoremap <silent>sd :bd<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>
nnoremap <silent>st :tabnew<CR>
nnoremap <silent>sx :tabclose<CR>
nnoremap <M-l> gt
nnoremap <M-h> gT

" Function key related

" cf.
" Toggle relative line numbers
nnoremap <F12> :set relativenumber!<CR>
" Expand %% to the path of the directory of the current file in command-line mode
cnoremap %% <C-R>=expand('%:p:h').'/'<cr>

" Keys for selecting command line completion
set wildcharm=<TAB>
cnoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
cnoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"


" Terminal settings

" Open a terminal in a new tab
nnoremap @t :tabe<CR>:terminal<CR>
" Quit terminal with Ctrl+q
tnoremap <C-q> <C-\><C-n>:q<CR>
" Return from terminal mode to normal mode with ESC or jj
tnoremap <ESC> <C-\><C-n>
tnoremap jj <C-\><C-n>
vnoremap gj  j


" Auto compile
" augroup setAutoCompile
"     autocmd!
"     autocmd BufWritePost *.tex  | :!latexmk -lualatex %
"     " autocmd BufWritePost *.c | :!gcc %:p
"     " autocmd BufWritePost *.R | :!R -f %:p
" augroup END
