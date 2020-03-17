"文字コードをUFT-8に設定
set encoding=utf-8
scriptencoding utf-8

" if has('win32') || has('win64')
"     let g:python3_host_prog = 'C:\Program Files (x86)\Microsoft Visual Studio\Shared\Python36_64\python.exe'
"     let g:python_host_prog = 'C:\Python27amd64\python.exe'
" endif

" let s:script_path = expand('<sfile>:p')
" echom '[debug]enter ' . s:script_path

" encodings
set fileencoding=utf-8
set fileencodings=utf-8,euc-jp,ucs-bom,iso-2022-jp,sjis,cp932,latin1
set fileformats=unix,dos,mac

" setting
set autoread   " 編集中のファイルが変更されたら自動で読み直す
set hidden     " バッファが編集中でもその他のファイルを開けるように
set autochdir

"set guioptions+=a
set clipboard=unnamed,unnamedplus

" vim が作る一時ファイルの場所
set directory=$XDG_CONFIG_HOME/nvim/.temp
set viminfo+=n$XDG_CONFIG_HOME/nvim/.temp/viminfo.txt
set undofile                      " Undo ファイルを作成する
set undodir=$XDG_CONFIG_HOME/nvim/.temp/undodir

" backup ファイルの設定
" c.f. https://orebibou.com/2015/04/vim%E3%81%A7%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E4%BF%9D%E5%AD%98%E6%99%82%E3%81%AB%E4%BD%9C%E6%88%90%E3%81%95%E3%82%8C%E3%82%8B%E3%83%90%E3%83%83%E3%82%AF%E3%82%A2%E3%83%83%E3%83%97%E3%83%95/
set backup                      " ファイルのバックアップを有効にする
set writebackup                 " 取得するバックアップを編集前のファイルとする(無効化する場合は「nowritebackup」)
set backupdir=$XDG_CONFIG_HOME/nvim/.backup  " このディレクトリはあらかじめ作っておく。chmod 700 するのを忘れずに
" バックアップを取得するファイル名を「ファイル名.タイムスタンプ」とする
" autocmd BufWritePre * let &backupext= '.' . strftime("%Y%m%d_%H%M%S")

" 見た目系
set number                " 行番号を表示
set relativenumber
set ruler                 " ルーラーを表示
" set cursorline            " 現在の行を強調表示
" set cursorcolumn          " 現在の行を強調表示（縦）
set title                 " タイトルを表示
set virtualedit=onemore   " 行末の1文字先までカーソルを移動できるように
set visualbell            " ビープ音を可視化
set showmatch             " 括弧入力時の対応する括弧を表示
set matchtime=1
set matchpairs
set matchpairs+=<:>
set showcmd               " 入力中のコマンドをステータスに表示する
set noshowmode
set laststatus=2          " ステータスラインを常に表示
" set nowrap                "テキストが折り返されないようにする
set wrap
set display=lastline
set cursorline            " 現在の行をハイライト
hi clear CursorLine       " 上と合わせることで行番号のみハイライト
set ambiwidth=double
set signcolumn=auto
set switchbuf=useopen

set conceallevel=2
let g:tex_conceal=""
set concealcursor="nc"

" 折りたたみ系
" cf. https://maku77.github.io/vim/advanced/folding.html
set foldmethod=indent  "折りたたみ範囲の判断基準（デフォルト: manual）
set foldlevel=0        "ファイルを開いたときにデフォルトで折りたたむレベル
set foldcolumn=3       "左端に折りたたみ状態を表示する領域を追加する

" " 折りたたみの自動保存
" " cf. https://vim-jp.org/vim-users-jp/2009/10/08/Hack-84.html
" " Save fold settings.
" autocmd BufWritePost * if expand('%') != '' && &buftype !~ 'nofile' | mkview | endif
" autocmd BufRead * if expand('%') != '' && &buftype !~ 'nofile' | silent loadview | endif
" " Don't save options.
" set viewoptions-=options

" 折りたたみ設定etc.を保存するフォルダ
" set viewdir=$XDG_CONFIG_HOME/nvim/.temp/view

" 補完系
set wildmenu
set wildmode=longest:full,full " コマンドラインの補完
set pumheight=10          "変換候補で一度に表示される数を設定する

" Tab系
set expandtab               " Tab文字を半角スペースにする
set tabstop=4              " 行頭以外のTab文字の表示幅（スペースいくつ分）
set shiftwidth=4            " 行頭でのTab文字の表示幅
set softtabstop=4         " <Tab> の挿入や <BS> の使用等の編集操作をするときに、<Tab> が対応する空白の数。

" 不可視文字を可視化(タブが「?-」と表示される)
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:⍽


" 入力系
set textwidth=0
set cindent           " インデントは C 形式のインデント
set backspace=indent,eol,start " <BS> の挙動を変更
set imdisable           " insert mode を抜けるときIMEをoffにする

" 選択系
set virtualedit=block

" spellcheck
set spell
set spelllang=en,cjk "日本語を除外

" 検索系
set ignorecase " 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set smartcase  " 検索文字列に大文字が含まれている場合は区別して検索する
set incsearch  " 検索文字列入力時に順次対象文字列にヒットさせる
set wrapscan   " 検索時に最後まで行ったら最初に戻る
set hlsearch   " 検索語をハイライト表示

set updatetime=100 " エディタの更新速度を速くする。


" I like highlighting strings inside C comments.
let c_comment_strings=1

" 保存時に行末の空白を除去する
autocmd BufWritePre * :%s/\s\+$//ge

" 保存時にタブをスペースに変換
autocmd BufWritePre * :retab

" Enable file type detection.
" Use the default filetype settings, so that mail gets 'textwidth' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on

if has("autocmd")
    " Put these in an autocmd group, so that we can delete them easily.
    augroup vimrcEx
        autocmd!

        " For all text files set 'textwidth' to 78 characters.
        autocmd FileType text setlocal textwidth=78

        " When editing a file, always jump to the last known cursor position.
        " Don't do it when the position is invalid or when inside an event handler
        autocmd BufReadPost *
                    \ if line("'\"") >= 1 && line("'\"") <= line("$") |
                    \   execute "normal! g`\"" |
                    \ endif

    augroup END
endif
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
    command DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif

" vimdiff 関連
set diffopt=internal,filler,algorithm:histogram,indent-heuristic

" coc-setting.jsonの場所
let g:coc_config_home=expand('<sfile>:p:h:h').'/toml'

" " エラーウィンドウを出す
" function! s:ale_list()
"     let g:ale_open_list = 1
"     call ale#Queue(0, 'lint_file')
" endfunction
" command! ALEList call s:ale_list()
" オートコンパイル
" augroup setAutoCompile
"     autocmd!
"     autocmd BufWritePost *.tex :!latexmk -lualatex %
"     " autocmd BufWritePost *.c :lcd %:h | :!gcc %:p
" augroup END
