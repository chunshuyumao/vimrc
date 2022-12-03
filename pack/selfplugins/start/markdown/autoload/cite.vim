" encoding: utf-8
" ========================================================
"
" File: cite.vim
"
" Author: chunshuyumao
" Created: 2022-09-04 08:43:08 Sunday
" Modified: 2022-10-12 20:40:30 Wednesday
"
" Description: 
"
" ========================================================

if !exists('g:citepath')
  let g:citepath = expand('~/Documents/Pandoc/ZoteroLibrary.json')
endif

function! cite#initial() abort

  let s:citations = g:citepath->readfile()->join()
        \ ->json_decode()->map({_, item -> {
        \ 'word': item->get('id', ''),
        \ 'info': printf("Title: %s\nAuthors: %s", item->get('title', ''),
        \   item->get('author', [])->map({_, v -> v->get('literal')??
        \     printf("%s %s", v->get('family', ''), v->get('given', ''))
        \   })->join(', '))
        \  }
        \ })

  return s:citations
endfunction

function! cite#cite(timer) abort

  let l:curpos = col('.')
  let l:beg = searchpos('[@', 'bnc', '.')[1]
  let l:end = searchpos(']',   'nc', '.')[1]
  if l:beg <= l:curpos && l:curpos <= l:end

    let l:startpos = searchpos('@', 'bnc', '.')[1]
    let l:word = getline('.')[l:startpos:(l:curpos - 2)]
          \ ->split()->filter('v:val->len() > 1')

    if !l:word->empty()
      call get(s:, 'citations', cite#initial())
            \ ->copy()->filter({_, item -> { w, i ->
            \   l:word->mapnew('w=~?v:val||i=~?v:val')->min()
            \  }(item->get('word', ''), item->get('info', ''))
            \ })->complete(l:startpos + 1)
    endif
  endif
endfunction

function! cite#enable_citation()

  augroup CiteComplete
    autocmd!
    autocmd CursorMovedI <buffer> call timer_start(0, 'cite#cite')
    inoremap <buffer><silent><expr><CR> pumvisible()?"\<C-Y>":"\<C-G>u\<CR>"
  augroup End

  let s:cmpopt = &completeopt
  setlocal completeopt=menu,noselect,popup

endfunction

function cite#disable_citation()

  augroup CiteComplete
    autocmd!
  augroup End

  execute 'setlocal completeopt='.s:cmpopt

endfunction
