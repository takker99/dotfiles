"�����R�[�h��UFT-8�ɐݒ�
set encoding=utf-8
scriptencoding utf-8

GuiFont! Consolas:h11

" �E�B���h�E�̏c��
" set lines=55
" �E�B���h�E�̉���
" set columns=180
" �J���[�X�L�[��
autocmd ColorScheme * highlight Comment ctermfg=22 guifg=#008800
autocmd ColorScheme * highlight Search term=reverse cterm=reverse ctermfg=166 gui=reverse guifg=#FF8C00
if has('multi_byte_ime')
    autocmd ColorScheme * highlight Cursor guifg=NONE guibg=Green
    autocmd ColorScheme * highlight CursorIM guifg=NONE guibg=Purple
endif
colorscheme molokai

" �_�[�N�n�̃J���[�X�L�[�����g��
set background=dark
syntax on

set termguicolors
