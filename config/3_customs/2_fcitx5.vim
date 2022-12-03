" encoding: utf-8
" ========================================================
"
" File: fcitx5.vim
"
" Author: chunshuyumao
" Created: Wed 20 Jul 2022 05:46:59 PM CST
" Modified: Wed 20 Jul 2022 05:46:59 PM CST
"
" Description: Auto switch input method of fcitx5
"
" ========================================================

" If using Fcitx5, automatically change input method.
if executable('fcitx5-remote')
  autocmd InsertLeave,BufCreate,BufEnter,BufLeave * 
    \ :silent! !fcitx5-remote -c
endif

