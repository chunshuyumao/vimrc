vim9script
# encoding: utf-8
# ========================================================
#
# File: cite.vim
#
# Author: chunshuyumao
# Created: 2022-09-04 08:43:08 Sunday
# Modified: 2022-10-12 20:40:30 Wednesday
#
# Description: 
#
# ========================================================

var citepath = get(g:, 'citepath', expand('~/Documents/Pandoc/ZoteroLibrary.json'))

var cmpopt: string = null_string
var citations: list<dict<string>> = null_list
var cite_timer_id: number = -1

def CreateInfo(_: number, item: dict<any>): dict<string>

  const authors: string = item->get('author', [])
    ->map((_, athr): string => 
    athr->get('literal') ??
    athr->get('family', '') .. ' ' .. athr->get('given')
  )->join(', ')

  return {
    'word': item->get('id', ''),
    'info': printf("Title: %s\nAuthors: %s",
            item->get('title', ''),
            authors
    )}
enddef

def Initial(): list<dict<string>>

  if citations == null_list
    citations = readfile(citepath)->join()->json_decode()->map(CreateInfo)
  endif
  return citations
enddef

def Cite(timer: number): void

  const curpos: number = col('.')
  const curline: number = line('.')
  const begpos: number = searchpos('[@', 'bnc', curline)[1]
  const endpos: number = searchpos(']',   'nc', curline)[1]

  if begpos <= curpos && curpos <= endpos

    silent! timer_stop(cite_timer_id)
    cite_timer_id = timer

    const startpos: number = searchpos('@', 'bnc', curline)[1]
    const words: list<string> = getline('.')[startpos : (curpos - 2)]
           ->split()->filter('v:val->len() > 1')

    if words != null_list
      Initial()->copy()->filter((_, item) => {
          const wd: string = item->get('word', null_string)
          const inf: string = item->get('info', null_string)
          for word in words
            if wd =~? word || inf =~? word
              return true
            endif
          endfor
          return false
      })->complete(startpos + 1)
    endif
  endif
enddef

export def EnableCitation(): void

  augroup CiteComplete
    autocmd!
    autocmd CursorMovedI <buffer> call timer_start(0, 'Cite')
    inoremap <buffer><silent><expr><CR> pumvisible() ? "\<C-Y>" : "\<C-G>u\<CR>"
  augroup End

  cmpopt = &completeopt
  setlocal completeopt=menu,noselect,popup

enddef

export def DisableCitation(): void

  augroup CiteComplete
    autocmd!
  augroup End

  execute 'setlocal completeopt=' .. cmpopt

enddef
