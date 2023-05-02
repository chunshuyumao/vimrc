vim9script

import autoload '../autoimport/mdshortcut.vim' as shortcuts
import autoload '../autoimport/cite.vim' as cite

const CheckTab = () => search('<++>', 'ncz', line('.') + 3) != 0 
        ? "\<Esc>/<++>\<CR>\:nohlsearch\<CR>c4l" 
        : "\<Tab>"

nnoremap <buffer><silent><expr><Tab> CheckTab()
inoremap <buffer><silent><expr><Tab> CheckTab()

highlight! def link Conceal Normal
setlocal foldlevel=99

nnoremap <buffer><silent> mh <Cmd>call setline('.', [
      \ '---',
      \ 'title: <++>',
      \ 'author: <++>',
      \ 'abstract: <++>',
      \ '---',
      \ '',
      \ '<++>',
      \ ])<CR>

nnoremap <buffer><silent> mp <ScriptCmd>shortcuts.Markdown2HTMLNPreview()<CR>
nnoremap <buffer><silent> mc <ScriptCmd>shortcuts.CloseMarkdowPreview()<CR>

xnoremap <buffer><silent> ml <ScriptCmd>shortcuts.Command('link')<CR>
inoremap <buffer><silent> <C-L> [](<++>) <++><Esc>F[a

xnoremap <buffer><silent> mi <ScriptCmd>shortcuts.Command('italic')<CR>
inoremap <buffer><silent> <C-K> ** <++><Esc>F*i

xnoremap <buffer><silent> ms <ScriptCmd>shortcuts.Command('strong')<CR>
inoremap <buffer><silent> <C-S> **** <++><Esc>F*hi

nnoremap <buffer><silent> mt <ScriptCmd>shortcuts.InsertTable()<CR>

function FormatTableForLagecy() range
  call shortcuts.FormatTable(a:firstline, a:lastline)
endfunction
xnoremap <buffer><silent> mft :call <SID>FormatTableForLagecy()<CR>
command! -buffer -range FmtTbl call <SID>shortcuts.FormatTable(<line1>, <line2>)

nnoremap <buffer><silent> mg <ScriptCmd>shortcuts.InsertImageFromClip()<CR>
inoremap <buffer><silent> <C-G> ![](<++>){#fig:<++>} <Enter><++><Esc>kF[a

nnoremap <buffer> mz "=<SID>shortcuts.Cite()<CR>p
inoremap <buffer> <C-Z> <C-R>=<SID>shortcuts.Cite()<CR>

command! -buffer RefreshCite call <SID>cite.Initial()
command! -buffer EnableCite call <SID>cite.EnableCitation()
command! -buffer DisableCite call <SID>cite.DisableCitation()
