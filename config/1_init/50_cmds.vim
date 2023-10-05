vim9script
# =========================================================
#
# 自定义命令和函数，杂项
#
# Author: chunshuyumao
# Created: 2022-07-10 19:29:03 Sunday
# Modified: 2022-10-12 17:28:12 Wednesday
#
# =========================================================


# ---------------------------------------------------------
# 自动插入时间
# ---------------------------------------------------------

exec printf('iab xdate %s', strftime('%Y-%m-%d %H:%M:%S %A'))

# ---------------------------------------------------------
# 打开文件时恢复上一次光标所在位置
# ---------------------------------------------------------

autocmd BufReadPost * {
  if 1 < line("'\"")
      && line("'\"") <= line("$")
      && &filetype !~# 'commit'
    execute 'normal! g`"'
  endif
}


# ---------------------------------------------------------
# 设置脚本缩进
# ---------------------------------------------------------

autocmd FileType h,hpp,c,cpp,cxx,lua,zsh,sh,vim
      \ setlocal tabstop=2 shiftwidth=2


autocmd FileType md,markdown,text,txt,log setlocal smoothscroll


# --------------------------------------------------------
# 返回窗口文本的字数
# --------------------------------------------------------

command! -nargs=? -complete=file WordCount {
  echomsg ' word: ' .. expand(<q-args> ?? '%')->readfile()->join('𰻝')
  ->substitute('[\r\n]\+\|\s\+', '𰻝', 'g')
  ->substitute('[\x00-\xff]\+', 'w', 'g')
  ->substitute('𰻝\+', '', 'g')
  ->substitute('\A', 'w', 'g')
  ->len()
}

# --------------------------------------------------------
# 重命名文件
# --------------------------------------------------------

const DateForFilename = (_, _, _): string => strftime('%Y%m%d%H%M%S')
command! -nargs=1 -complete=custom,DateForFilename Rename {
  :saveas <args>
  const fname: string = expand('#')
  if fname->filereadable()
    fname->delete()
  endif
}


# --------------------------------------------------------
# 交换虚拟上下行移动的键位
# --------------------------------------------------------

nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> <Up> g<Up>
nnoremap <silent> <Down> g<Down>

nnoremap <silent> gj j
nnoremap <silent> gk k
nnoremap <silent> g<Up> <Up>
nnoremap <silent> g<Down> <Down>

# --------------------------------------------------------
# Search in all currently opened buffers
# --------------------------------------------------------

command! -nargs=1 Search {
  exe ':bufdo silent! lvimgrepadd <args> %'
  :lopen
}
