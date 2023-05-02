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
var cite_act_timer: number = -1

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
    citations = readfile(citepath)
                  ->join()
                  ->json_decode()
                  ->map(CreateInfo)
  endif
  return citations
enddef


def Cite(timer: number): void

  silent! timer_stop(cite_act_timer)
  cite_act_timer = timer

  var stoppos: number = charcol('.') - 2
  var startpos: number = stoppos
  const str: string = getline('.')
  while str[startpos] =~ '\w'
    startpos = startpos - 1
  endwhile

  if str[startpos] == '@'
    const words: string = str[startpos + 1 : stoppos]
    if words->len() >= 3
      const at: number = searchpos('@', 'nbc', line('.'))[1]
      Initial()->copy()->filter((_, item) => 
        item->get('word', null_string) =~? words ||
        item->get('info', null_string) =~? words
      )->complete(at + 1)
    endif
  endif
enddef

export def EnableCitation(): void

  augroup CiteComplete
    autocmd!
    autocmd CursorMovedI <buffer> call timer_start(1, 'Cite')
    inoremap <buffer><silent><expr><CR> pumvisible() ? "\<C-Y>" : "\<C-G>u\<CR>"
  augroup End

  cmpopt = &completeopt
  setlocal completeopt=menu,noselect

enddef

export def DisableCitation(): void

  augroup CiteComplete
    autocmd!
  augroup End

  execute 'setlocal completeopt=' .. cmpopt

enddef
