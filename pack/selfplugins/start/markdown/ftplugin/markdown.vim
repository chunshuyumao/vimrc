if exists('b:did_ftplugin') | finish | endif
let b:did_ftplugin = v:true

let b:CheckTab = {->
      \ search('<++>', 'ncz', line('.') + 3) != 0 ?
      \ "\<Esc>/<++>\<CR>\:nohlsearch\<CR>c4l" : "\<Tab>"
      \ }

nnoremap <buffer><silent><expr><Tab> b:CheckTab()
inoremap <buffer><silent><expr><Tab> b:CheckTab()

highlight! def link Conceal Normal
setlocal foldlevel=99

nnoremap <buffer><silent> mh
      \ :call setline('.', [
      \ '---',
      \ 'title: <++>',
      \ 'author: <++>',
      \ 'abstract: <++>',
      \ '---',
      \ '',
      \ '<++>',
      \ ])<CR>

nnoremap <buffer><silent> mp :call mdshortcut#markdown2html_n_preview()<CR>
nnoremap <buffer><silent> mc :call mdshortcut#close_markdow_preview()<CR>

xnoremap <buffer><silent> ml :call mdshortcut#command('link')<CR>
inoremap <buffer><silent> <C-L> [](<++>) <++><Esc>F[a

xnoremap <buffer><silent> mi :call mdshortcut#command('italic')<CR>
inoremap <buffer><silent> <C-K> ** <++><Esc>F*i

xnoremap <buffer><silent> ms :call mdshortcut#command('emphasize')<CR>
inoremap <buffer><silent> <C-S> **** <++><Esc>F*hi

nnoremap <buffer><silent> mt :call mdshortcut#insert_table()<CR>
xnoremap <buffer><silent> mft :call mdshortcut#format_table()<CR>
command! -buffer -range FmtTbl :<line1>,<line2>call mdshortcut#format_table()

nnoremap <buffer><silent> mg :call mdshortcut#insert_image_from_clip()<CR>
inoremap <buffer><silent> <C-G> ![](<++>){#fig:<++>} <Enter><++><Esc>kF[a

nnoremap <buffer> mz "=mdshortcut#cite()<CR>p
inoremap <buffer> <C-Z> <C-R>=mdshortcut#cite()<CR>

command! -buffer RefreshCite call cite#initial()
command! -buffer EnableCite call cite#enable_citation()
command! -buffer DisableCite call cite#disable_citation()
