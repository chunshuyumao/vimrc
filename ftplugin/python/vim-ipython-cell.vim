" encoding: utf-8
" ========================================================
"
" File: vim-ipython-cell.vim
"
" Author: hg006006
" Created: Sat 30 Jul 2022 06:34:20 PM CST
" Modified: Sat 30 Jul 2022 06:34:20 PM CST
"
" Description: ipython-cell configuration
"
" ========================================================

let g:slime_python_ipython = v:true

nnoremap <buffer> <Leader>s :SlimeSend1 ipython --matplotlib<CR>

nnoremap <buffer> <Leader>r :IPythonCellRun<CR>
nnoremap <buffer> <Leader>R :IPythonCellRunTime<CR>

nnoremap <buffer> <Leader>c :IPythonCellExecuteCell<CR>
nnoremap <buffer> <Leader>C :IPythonCellExecuteCellJump<CR>

nnoremap <buffer> <Leader>l :IPythonCellClear<CR>
nnoremap <buffer> <Leader>x :IPythonCellClose<CR>

nnoremap <buffer> [c :IPythonCellPrevCell<CR>
nnoremap <buffer> ]c :IPythonCellNextCell<CR>

nmap <buffer> <Leader>h <Plug>SlimeLineSend
xmap <buffer> <Leader>h <Plug>SlimeRegionSend

nnoremap <buffer> <Leader>p :IPythonCellPrevCommand<CR>
nnoremap <buffer> <Leader>Q :IPythonCellRestart<CR>
nnoremap <buffer> <Leader>d :SlimeSend1 %debug<CR>
nnoremap <buffer> <Leader>q :SlimeSend1 exit<CR>

nmap <buffer> <F9> :IPythonCellInsertAbove<CR>a
nmap <buffer> <F10> :IPythonCellInsertBelow<CR>a
imap <buffer> <F9> <C-o>:IPythonCellInsertAbove<CR>
imap <buffer> <F10> <C-o>:IPythonCellInsertBelow<CR>
