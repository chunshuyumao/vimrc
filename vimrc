" =========================================================
"
" 初始化，并调用 config 文件夹下的所有配置文件
"
" Author: chunshuyumao
" Data: Fri Jul 8 22:40 2022
" Modified: Sat 30 Jul 2022 10:06:20 AM CST
" =========================================================

" 避免多次加载
if exists('s:loaded')
  finish
endif

" 标记以加载
let s:loaded = v:true

" 依次加载 config 下的配置文件
call expand('<sfile>:p:h')->resolve()
      \ ->printf('%s/config/**/*.vim')->expand(v:true, v:true)
      \ ->sort('n')->map('"source " .. v:val')->execute()
