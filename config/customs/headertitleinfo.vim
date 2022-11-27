" =========================================================
"
" 自动添加头标注
" 
" Author: chunshuyumao
" Created: 2022-07-10 19:29:29 Sunday
" Modified:2022-10-12 21:19:07 Wednesday
"
" =========================================================


" ---------------------------------------------------------
" 自动添加头标注
" ---------------------------------------------------------

let s:header={
  \  'r':      { 'shabang': 'Rscript'                   },
  \  'sh':     { 'shabang': 'bash'                      },
  \  'vim':    {                       'commentor': '"' },
  \  'lua':    { 'shabang': 'lua',     'commentor': '--'},
  \  'python': { 'shabang': 'python'                    },
  \}
let s:date_fmt = '%Y-%m-%d %H:%M:%S %A'

" 定义一个函数，加注标头
" commentor 默认是 `#`
function! s:header_title_info()

  if !exists('s:header[&filetype]')
    return
  endif

  let l:file = s:header[&filetype]

  let l:lineno = 1
  if exists('l:file["shabang"]')
    call setline(l:lineno, l:file->get('shabang')->printf("#!/bin/env %s"))
    let l:lineno += 1
  endif

  let l:fmt_time = s:date_fmt->strftime()
  " Get commentor of script file. If not exist, use `#` default.
  let l:cmtr = l:file->get('commentor', '#')
  let l:border = l:cmtr->printf("%s %s", repeat('=', 56))

  call setline(l:lineno, [
        \ l:cmtr->printf("%s encoding: %s", l:file->get('encoding', 'utf-8')),
        \ l:border,
        \ l:cmtr, 
        \ l:cmtr->printf("%s File: %s", expand('%:t')),
        \ l:cmtr,
        \ l:cmtr->printf("%s Author: %s", $USER),
        \ l:cmtr->printf("%s Created: %s", l:fmt_time),
        \ l:cmtr->printf("%s Modified: %s", l:fmt_time),
        \ l:cmtr,
        \ l:cmtr->printf("%s Description: "),
        \ l:cmtr,
        \ l:border,
        \ '',
        \ ])

  " 鼠标移到最后一行
  normal! G
endfunction

" 创建新文件时自动添加标头
autocmd! BufNewFile *.* call <SID>header_title_info()
command! -nargs=0 InsertHeader call <SID>header_title_info()
