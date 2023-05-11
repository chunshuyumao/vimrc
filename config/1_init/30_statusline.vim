vim9script
# encoding: utf-8
# ========================================================
#
# File: init-statusline.vim
#
# Author: chunshuyumao
# Created: Sun 31 Jul 2022 08:05:04 AM CST
# Modified: Sun 31 Jul 2022 10:33:11 AM CST
#
# Description: 标签栏和状态栏设置
#
# ========================================================


# ---------------------------------------------------------
# 标签栏设置
# ---------------------------------------------------------

set tabline=%!CustomTabLine()
def g:CustomTabLine(): string

  var tblline: list<string>
  for i in range(1, tabpagenr('$'))
    const buf_nr: number = tabpagebuflist(i)[tabpagewinnr(i) - 1]
    const buf_tp: string = buf_nr->getbufvar('&buftype')
    var buf_title: string = 'quickfix'
    if buf_tp != 'quickfix'
      const buf_name: string = bufname(buf_nr)->fnamemodify(':t')
      buf_title = buf_name->empty() ? 'untitled'
        : (buf_nr->getbufvar('&modified') ? '+' : '') .. buf_name
    endif
    const cur_tab: string = i == tabpagenr() ? '%#Normal#' : '%#Comment#'
    tblline->add(printf('%s %d %s', cur_tab, i, buf_title))
  endfor
  tblline->add('%#TabLineFill#')
  return tblline->join(' »')
enddef


# ---------------------------------------------------------
# 状态栏设置
# ---------------------------------------------------------

# 一直报告文件的改变状态
set report=0

# 一直显示状态栏
set laststatus=2

# 如果太长，从这里截断
set statusline=\ %<
# 文件全路径
set statusline+=%F
# 显示 修改、只读、帮助、预览 的标识
set statusline+=%(%m%r%h%w%)
# 多文件时显示当前文件的标识
set statusline+=%a
# 左右状态栏的分界
set statusline+=%=
# 如果开启拼写检测，则显示拼写的语言
set statusline+=%{&spell?'spell\:'..&spelllang..'\ ':''}
# 文件类型
set statusline+=%y\ 
# 文件格式，指的是系统格式
set statusline+=%{&fileformat}\ 
# 文件编码方式
set statusline+=%{&fileencoding??&encoding}\ 
# 鼠标位置
set statusline+=%c,%l\ 
# 鼠标位置所在文件行数的百分比
set statusline+=%p%%\ 
