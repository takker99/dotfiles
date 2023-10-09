scriptencoding utf-8

" let s:script_path = expand('<sfile>:p')
" echom '[debug]enter ' . s:script_path

" Neovim設定ディレクトリ
let nvim_dir = substitute(expand($XDG_CONFIG_HOME) . '/nvim/', '\', '/', 'g')

" deinの関連のパス
let dein_path = 'github.com/Shougo/dein.vim'
let dein_url = 'https://' . dein_path

" プラグインをインストールするディレクトリ
let s:dein_dir = nvim_dir . '.cache/dein/'
" dein.vim 本体
let s:dein_repo_dir = s:dein_dir . 'repos/' . dein_path

" dein.vimがなければインストールする
if !isdirectory(s:dein_repo_dir)
  execute '!git clone ' . dein_url s:dein_repo_dir
endif
" dein.vimをruntimepathへ追加
let &runtimepath = s:dein_repo_dir . ',' . &runtimepath


" 設定開始
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " gitで管理しているtomlフォルダへのパス
  let s:toml_dir = expand('<sfile>:p:h:h').'/toml/'
  " プラグインリストファイル
  let s:lazy_toml_dir = s:toml_dir . 'lazy/'

  " プラグインリストを読み込みキャッシュする
  let s:toml_list = glob(s:toml_dir.'*.toml')
  let s:splitted = split(s:toml_list, '\n')
  for file in s:splitted
    call dein#load_toml(file, {'lazy': 0})
  endfor
  let s:toml_list = glob(s:lazy_toml_dir.'*.toml')
  let s:splitted = split(s:toml_list, '\n')
  for file in s:splitted
    call dein#load_toml(file, {'lazy': 1})
  endfor

  " 設定終了
  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

" GitHub Personal Access Tokenを取得する

" GitHub apt file.
let s:github_pat = expand('<sfile>:p:h:h:h:h').'/github_pat'
" github_patが有れば更新を確認し、pluginsをupdateする
if filereadable(s:github_pat)
  " ここで、g:dein#install_github_api_tokenにPATをセットする。
  let g:dein#install_github_api_token = readfile(s:github_pat)[0]
  call dein#check_update('v:true')
endif

" 未インストールのプラグインがある場合はインストール
if dein#check_install()
  call dein#install()
endif
