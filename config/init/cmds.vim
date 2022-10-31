" =========================================================
"
" 自定义命令和函数，杂项
"
" Author: chunshuyumao
" Created: 2022-07-10 19:29:03 Sunday
" Modified: 2022-10-12 17:28:12 Wednesday
"
" =========================================================


" ---------------------------------------------------------
" 自动插入时间
" ---------------------------------------------------------

" 正常模式自动插入时间
nmap <leader>dt a<leader>dt<Esc>

" 插入模式自动插入时间
inoremap <leader>dt <C-R>=strftime('%Y-%m-%d %H:%M:%S %A')<CR>


" ---------------------------------------------------------
" 打开文件时恢复上一次光标所在位置
" ---------------------------------------------------------

autocmd BufReadPost * 
      \ if 1 < line("'\"") && line("'\"") <= line("$") && 
      \ &filetype !~# 'commit' | execute "normal! g`\"" |
      \ endif


" ---------------------------------------------------------
" 设置脚本缩进
" ---------------------------------------------------------

autocmd FileType c,cpp,lua,sh,vim setlocal tabstop=2 shiftwidth=2


" ---------------------------------------------------------
" 查看原始文件与当前文件的差异 
" ---------------------------------------------------------

if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 
        \ 0d_ | diffthis | wincmd p | diffthis
endif


" --------------------------------------------------------
" 返回窗口文本的字数
" --------------------------------------------------------

command! -nargs=? -complete=file WordCount :echo ' words:'
      \ . expand(<q-args>??'%')->readfile()->join('𰻝')
      \ ->substitute('[\r\n]\+\|\s\+', '𰻝', 'g')
      \ ->substitute('[\x00-\xff]\+', 'w', 'g')
      \ ->substitute('𰻝\+', '', 'g')
      \ ->substitute('\A', 'w', 'g')
      \ ->len()


" --------------------------------------------------------
" 重命名文件
" --------------------------------------------------------

function! s:date_for_filename(a,l,p)
  return strftime('%Y%m%d%H%M%S')
endfunction
command! -nargs=1 -complete=custom,s:date_for_filename
      \ Rename saveas <args> 
      \ | silent! call expand('#')->delete()


" --------------------------------------------------------
" 交换虚拟上下行移动的键位
" --------------------------------------------------------

nnoremap <silent> j gj
nnoremap <silent> k gk

nnoremap <silent> gj j
nnoremap <silent> gk k
