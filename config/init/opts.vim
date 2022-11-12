" ==========================================================
"
" 基础配置
"
" Author: chunshuyumao
" Date: Fri Jul 8 21:17 2022
" Modified: Sat 30 Jul 2022 10:08:29 AM CST
"
" ==========================================================


" ----------------------------------------------------------
" 一般配置
" ----------------------------------------------------------

" 关闭对 Vi 编辑器的兼容性
set nocompatible

" 开启行号
set number

" 高亮显示鼠标所在行
set cursorline

" 设置 word 包含的字符
set iskeyword=@,_,-,48-57,192-255

" 设置 Tab 键和多空格的展示方式
set list
set listchars=tab:·–,multispace:·

" 设置延迟重绘
set lazyredraw


" ---------------------------------------------------------
" 颜色配置
" ---------------------------------------------------------

" 开启终端真彩，否则开启 256 Bit 颜色
if has('termguicolors')
  set termguicolors
else
  set t_Co=256
endif

" 选择配色方案
set background=dark
colorscheme molokai_self

autocmd! ColorScheme * hi! link PmenuSel CursorLine

let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"

" ---------------------------------------------------------
" 开启语法高亮
" ---------------------------------------------------------
if has('syntax')
  syntax enable on
endif


" ---------------------------------------------------------
" 保持鼠标所在行为屏幕中央
" ---------------------------------------------------------
let s:mid_col = {-> float2nr(win_getid()->winheight() / 2)}
let &scrolloff = s:mid_col()
autocmd VimResized * let &scrolloff = s:mid_col()

" ---------------------------------------------------------
" 编码配置
" ---------------------------------------------------------

" 内部编码
set encoding=utf-8
set termencoding=utf-8

" 默认文件编码
set fileformat=unix

" 文件编码方式
set fileformats=unix,dos,mac

" 尝试使用以下凡是打开文件
set fileencodings=utf-8,gb2312,gbk,gb18030,bgi5,latin1,ucs-bom,cp936,euc-jp,euc-kr


" ---------------------------------------------------------
" 插件配置
" ---------------------------------------------------------
if has('filetype')
  filetype plugin indent on
endif


" ---------------------------------------------------------
" 快捷键打开当前目录
" ---------------------------------------------------------

let g:netrw_banner = v:false
" 20% 窗口大小
let g:netrw_winsize = 20
" 树状目录
let g:netrw_liststyle = 3
nnoremap <leader>o :Lexplore<CR>


" ---------------------------------------------------------
" Terminal debugger vertical
" ---------------------------------------------------------

let g:termdebug_wide = v:true
