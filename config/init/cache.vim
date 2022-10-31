" =========================================================
"
" 高级配置，用于设置 VIM 的相关文件.
"
" Author: chunshuyumao
" Date: Fri Jul 8 22:13 2022
" Modified: Sat 30 Jul 2022 10:07:17 AM CST
" 
" =========================================================


" ---------------------------------------------------------
" 备份设置
" ---------------------------------------------------------

" 开启备份
set backup

" 保存时备份
set writebackup

" 设置备份文件目录
set backupdir=~/.vim/cache/backup//

" 如果不存在文件夹，则创建
if !isdirectory(('~/.vim/cache/backup'))
  call mkdir(expand('~/.vim/cache/backup'), 'p', 0750)
endif


" ---------------------------------------------------------
" 撤消设置 
" ---------------------------------------------------------

" 查看是否支持保存 撤消 操作
if has('persistent_undo')
  " 开启撤销文件
  set undofile

  " 设置撤销操作保存目录
  set undodir=~/.vim/cache/undo//

  " 如果不存在文件夹，则创建
  if !isdirectory(('~/.vim/cache/undo'))
    call mkdir(expand('~/.vim/cache/undo'), 'p', 0750)
  endif
endif

" 设置 命令行 操作历史的记录数
set history=1000


" ---------------------------------------------------------
" 交换文件设置
" ---------------------------------------------------------

" 设置交换文件目录
set directory=~/.vim/cache/swap//

" 如果不存在文件夹，则创建
if !isdirectory(expand('~/.vim/cache/swap'))
  call mkdir(expand('~/.vim/cache/swap'), 'p', 0750)
endif
