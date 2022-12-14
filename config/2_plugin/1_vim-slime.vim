" encoding: utf-8
" ========================================================
"
" File: vim-slime.vim
"
" Author: chunshuyumao
" Created: 2022-08-04 14:59:52 Thursday
" Modified: 2022-08-04 14:59:52 Thursday
"
" Description: 
"
" ========================================================

let g:slime_target = "vimterminal"
let g:slime_paste_file = tempname()
let g:slime_cell_delimiter = '^\s*#\s*%%'
let g:slime_vimterminal_config = {
      \ "vertical": v:true,
      \ "term_finish": "close",
      \ "term_cols": float2nr(0.4 * winnr()->winwidth()),
      \ "ansi_colors": ['#073542','#DC322F','#859900','#B58900',
      \                 '#268BD2','#D33682','#2AA198','#EEE8D5',
      \                 '#002B36','#CB4B16','#586E75','#657BE3',
      \                 '#839496','#6C71C4','#93A1A1','#FDF6E3',
      \ ]
      \ }

nnoremap <leader>t :SlimeSend<CR>
autocmd! VimResized * call slime#term_resized()
