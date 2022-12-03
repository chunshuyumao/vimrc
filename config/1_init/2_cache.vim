" =========================================================
"
" 高级配置，用于设置 VIM 的相关文件.
"
" Author: chunshuyumao
" Date: Fri Jul 8 22:13 2022
" Modified: Sat 30 Jul 2022 10:07:17 AM CST
" 
" =========================================================

let s:backupdir = glob('~/.vim/cache/backup')
let s:undodir = glob('~/.vim/cache/undo')
let s:swapdir = glob('~/.vim/cache/swap')

" ---------------------------------------------------------
" 备份设置
" ---------------------------------------------------------

" 开启备份
set backup

" 保存时备份
set writebackup

" 如果不存在文件夹，则创建
if !isdirectory(s:backupdir)
  call mkdir(s:backupdir, 'p', 0750)
endif

" 设置备份文件目录
execute printf('set backupdir=%s//', s:backupdir)
unlet! s:backupdir


" ---------------------------------------------------------
" 撤消设置 
" ---------------------------------------------------------

" 查看是否支持保存 撤消 操作
if has('persistent_undo')
  " 开启撤销文件
  set undofile

  " 如果不存在文件夹，则创建
  if !isdirectory(s:undodir)
    call mkdir(s:undodir, 'p', 0750)
  endif

  " 设置撤销操作保存目录
  execute printf('set undodir=%s//', s:undodir)
endif
unlet! s:undodir

" 设置 命令行 操作历史的记录数
set history=10000


" ---------------------------------------------------------
" 交换文件设置
" ---------------------------------------------------------

" 如果不存在文件夹，则创建
if !isdirectory(s:swapdir)
  call mkdir(s:swapdir, 'p', 0750)
endif

" 设置交换文件目录
execute printf('set directory=%s//', s:swapdir)
unlet! s:swapdir
