" Set character encoding to UTF-8
scriptencoding utf-8

" if has('win32') || has('win64')
"     let g:python3_host_prog = 'C:\Program Files (x86)\Microsoft Visual Studio\Shared\Python36_64\python.exe'
"     let g:python_host_prog = 'C:\Python27amd64\python.exe'
" endif

" Path to the git-managed nvim directory
let g:nvim_git_dir_path = expand('<sfile>:p:h:h:h')

" encodings
set fileencoding=utf-8
set fileencodings=utf-8,euc-jp,ucs-bom,iso-2022-jp,sjis,cp932,latin1
set fileformats=unix,dos,mac

" setting
set autoread   " Automatically reload the file when it is changed outside
set hidden     " Allow opening other files even if the current buffer is modified
set autochdir

set guioptions+=a
set clipboard^=unnamed,unnamedplus

" Location of temporary files created by vim
set directory=$XDG_CONFIG_HOME/nvim/.temp
set viminfo+=n$XDG_CONFIG_HOME/nvim/.temp/viminfo.txt
set undofile                      " Create undo files
set undodir=$XDG_CONFIG_HOME/nvim/.temp/undodir

" Backup file settings
" c.f. https://orebibou.com/2015/04/vim%E3%81%A7%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E4%BF%9D%E5%AD%98%E6%99%82%E3%81%AB%E4%BD%9C%E6%88%90%E3%81%95%E3%82%8C%E3%82%8B%E3%83%90%E3%83%83%E3%82%AF%E3%82%A2%E3%83%83%E3%83%97%E3%83%95/
set backup                      " Enable file backup
set writebackup                 " Backup the file before it is edited (disable with "nowritebackup")
set backupdir=$XDG_CONFIG_HOME/nvim/.backup  " Create this directory in advance. Don't forget to chmod 700 it
" Use "filename.timestamp" as the backup file name
" autocmd BufWritePre * let &backupext= '.' . strftime("%Y%m%d_%H%M%S")

" Appearance
set number                " Show line numbers
set relativenumber
set ruler                 " Show the ruler
" set cursorline            " Highlight the current line
" set cursorcolumn          " Highlight the current column
set title                 " Show the window title
set virtualedit=onemore   " Allow moving the cursor one character past the end of line
set visualbell            " Visualize the bell instead of beeping
set showmatch             " Show matching brackets when typing brackets
set matchtime=1
set matchpairs+=<:>
set showcmd               " Show the command being typed in the status line
set noshowmode
set laststatus=2          " Always show the status line
" set nowrap                " Do not wrap text
set wrap
set display=lastline
set cursorline            " Highlight the current line
hi clear CursorLine       " Combined with the above, highlight only the line number
set ambiwidth=double
set signcolumn=auto
set switchbuf=useopen

set conceallevel=2
let g:tex_conceal=''
set concealcursor=nc

" Folding
" cf. https://maku77.github.io/vim/advanced/folding.html
set foldmethod=indent  "Criteria for determining fold ranges (default: manual)
set foldlevel=99       "Default fold level when a file is opened (0: fold everything, n: don't fold n levels)
set foldcolumn=3       "Add a column on the left showing the fold state

" " Automatically save folds
" " cf. https://vim-jp.org/vim-users-jp/2009/10/08/Hack-84.html
" " Save fold settings.
" autocmd BufWritePost * if expand('%') != '' && &buftype !~ 'nofile' | mkview | endif
" autocmd BufRead * if expand('%') != '' && &buftype !~ 'nofile' | silent loadview | endif
" " Don't save options.
" set viewoptions-=options

" Directory for storing fold settings, etc.
" set viewdir=$XDG_CONFIG_HOME/nvim/.temp/view

" Completion
set wildmenu
set wildmode=longest:full,full " Command line completion
set pumheight=10          "Set the number of candidates shown at once in the popup menu
set infercase             " Adjust case intelligently during completion

" Register additional dictionaries per filetype
" augroup fileTypeDictionary
"     autocmd!
"     autocmd FileType * execute 'setlocal dictionary+='. g:nvim_git_dir_path.'/userautoload/dictionary/'.&filetype.'.txt'
" augroup END

" Tabs
set expandtab               " Use spaces instead of tab characters
set tabstop=2              " Display width of tab characters not at the beginning of a line
set shiftwidth=2            " Display width of tab characters at the beginning of a line
set softtabstop=2         " Number of spaces a <Tab> corresponds to during editing operations such as inserting <Tab> or using <BS>

" Change tab settings per filetype
augroup fileTypeIndent
    autocmd!
augroup END

" Visualize invisible characters (tab displayed as "»-")
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:⍽


" Input
set textwidth=0
set cindent           " Use C-style indentation
set backspace=indent,eol,start " Change <BS> behavior
set imdisable           " Turn off the IME when leaving insert mode

" Selection
set virtualedit=block

" spellcheck
set spell
set spelllang=en,cjk " Exclude Japanese

" Search
set ignorecase " Ignore case if the search string is lowercase
set smartcase  " Match case if the search string contains uppercase
set incsearch  " Show incremental matches while typing the search string
set wrapscan   " Wrap around to the top after reaching the bottom during search
set hlsearch   " Highlight search matches

set updatetime=100 " Speed up editor updates.

" status line
" references:
" - https://blog.htkyama.org/vimrm
" Show file name
set statusline=%F
" Show modified flag
set statusline+=%m
" Show read-only flag
set statusline+=%r
" Show [HELP] for help pages
set statusline+=%h
" Show [Preview] for preview windows
set statusline+=%w
" Right-align the following
set statusline+=%=
" Show file type
set statusline+=%y
" file encoding
set statusline+=[%{&fileencoding}]
" Show file format
set statusline+=[%{&fileformat}]
" Current line/total lines/percent
set statusline+=[L%l:C%c\ (%p%%)]

" I like highlighting strings inside C comments.
let c_comment_strings=1

" Remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//ge

" Convert tabs to spaces on save
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

" vimdiff settings
set diffopt=internal,filler,algorithm:histogram,indent-heuristic

" Location of coc-setting.json
let g:coc_config_home=expand('<sfile>:p:h:h').'/toml'

" " Show the error window
" function! s:ale_list()
"     let g:ale_open_list = 1
"     call ale#Queue(0, 'lint_file')
" endfunction
" command! ALEList call s:ale_list()
" Auto compile
" augroup setAutoCompile
"     autocmd!
"     autocmd BufWritePost *.tex :!latexmk -lualatex %
"     " autocmd BufWritePost *.c :lcd %:h | :!gcc %:p
" augroup END
