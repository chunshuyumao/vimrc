vim9script
# =========================================================
#
# 自动添加头标注
# 
# Author: chunshuyumao
# Created: 2022-07-10 19:29:29 Sunday
# Modified:2022-10-12 21:19:07 Wednesday
#
# =========================================================


# ---------------------------------------------------------
# 自动添加头标注
# ---------------------------------------------------------

const header: dict<dict<string>> = {
    'r':      { 'shabang': 'Rscript'                   },
    'sh':     { 'shabang': 'bash'                      },
    'zsh':    { 'shabang': 'zsh'                       },
    'vim':    {                       'commentor': '"' },
    'lua':    { 'shabang': 'lua',     'commentor': '--'},
    'python': { 'shabang': 'python'                    }, }

const date_fmt: string = '%Y-%m-%d %H:%M:%S %A'

# 定义一个函数，加注标头
# commentor 默认是 `#`
def HeaderTitleInfo(): void

  const file: dict<string> = header->get(&filetype, null_dict)
  if file == null_dict
    return
  endif

  var lineno: number = 1
  const shabang: string = file->get('shabang', null_string)
  if shabang != null_string
    setline(lineno, shabang->printf("#!/bin/env %s"))
    lineno = lineno + 1
  endif

  const fmt_time: string = date_fmt->strftime()
  # Get commentor of script file. If not exist, use `#` default.
  const cmtr: string = file->get('commentor', '#')
  const border: string = cmtr->printf("%s %s", repeat('=', 56))
 
  setline(lineno, [
          cmtr->printf("%s encoding: %s", file->get('encoding', 'utf-8')),
          border,
          cmtr, 
          cmtr->printf("%s File: %s", expand('%:t')),
          cmtr,
          cmtr->printf("%s Author: %s", $USER),
          cmtr->printf("%s Created: %s", fmt_time),
          cmtr->printf("%s Modified: %s", fmt_time),
          cmtr,
          cmtr->printf("%s Description: "),
          cmtr,
          border,
          '',
          ])

  # 鼠标移到最后一行
  normal! G
enddef

command! -nargs=0 InsertHeader call HeaderTitleInfo()
