scriptencoding utf-8

" let s:script_path = expand('<sfile>:p')
" echom '[debug]enter ' . s:script_path

" Neovim config directory
let nvim_dir = substitute(expand($XDG_CONFIG_HOME) . '/nvim/', '\', '/', 'g')

" dein related paths
let dein_path = 'github.com/Shougo/dein.vim'
let dein_url = 'https://' . dein_path

" Directory where plugins are installed
let s:dein_dir = nvim_dir . '.cache/dein/'
" dein.vim itself
let s:dein_repo_dir = s:dein_dir . 'repos/' . dein_path

" Install dein.vim if it is not present
if !isdirectory(s:dein_repo_dir)
  execute '!git clone ' . dein_url s:dein_repo_dir
endif
" Add dein.vim to runtimepath
let &runtimepath = s:dein_repo_dir . ',' . &runtimepath


" Start configuration
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " Path to the git-managed toml folder
  let s:toml_dir = expand('<sfile>:p:h:h').'/toml/'
  " Plugin list files
  let s:lazy_toml_dir = s:toml_dir . 'lazy/'

  " Load and cache the plugin list
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

  " End configuration
  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

" Retrieve the GitHub Personal Access Token

" GitHub apt file.
let s:github_pat = expand('<sfile>:p:h:h:h:h').'/github_pat'
" If github_pat exists, check for updates and update plugins
if filereadable(s:github_pat)
  " Set the PAT to g:dein#install_github_api_token here.
  let g:dein#install_github_api_token = readfile(s:github_pat)[0]
  call dein#check_update('v:true')
endif

" Install any not-yet-installed plugins
if dein#check_install()
  call dein#install()
endif
