" =========================================================
" 
" rainbow 配置
"
" Author: chunshuyumao
" Data: Fri Jul 8 22:35
" Modified: Tue 12 Jul 2022 10:31:26 AM CST
"
" =========================================================

let g:rainbow_active = 1

let g:rainbow_load_separately = [
    \ [ '*' , [['(', ')'], ['\[', '\]'], ['{', '}'], ['<', '>']] ],
    \ [ '*.{html,htm}' , [['(', ')'], ['\[', '\]'], ['{', '}'], ['<\a[^>]*>', '</[^>]*>']] ],
    \]

let g:rainbow_guifgs = [
  \ 'RoyalBlue3', 'DarkOrange3', 'LightBlue', 'FireBrick',
  \ 'Cyan', 'DarkMagenta', 'DarkCyan', 'DarkOrchid3', 'SeaGreen',
  \ 'Blue', 'DarkBlue', 'LightCyan', 'LightYellow', 'Brown', 'Violet'
  \]

let g:rainbow_ctermfgs = [
  \ 'lightblue', 'lightgreen', 'lightcyan', 'lightmagenta',
  \ 'lightyellow','yellow', 'red', 'magenta', 'cyan'
  \]
