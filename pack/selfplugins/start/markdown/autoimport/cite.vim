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

const citepath = get(g:, 'citepath', expand('~/Documents/Pandoc/ZoteroLibrary.json'))

var cmpopt: string
var citations: list<dict<string>> = null_list
var cite_act_timer: number = -1

var prev_cursor_pos_x: number = -1
var prev_cursor_pos_y: number = -1

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
    citations = readfile(citepath)->join()
      ->json_decode()->map(CreateInfo)
  endif
  return citations
enddef


def Cite(timer: number): void

  const current_cursor_pos_x: number = col('.')
  const current_cursor_pos_y: number = line('.')

  if current_cursor_pos_x == prev_cursor_pos_x
    && current_cursor_pos_y == prev_cursor_pos_y
    return
  endif

  prev_cursor_pos_x = current_cursor_pos_x
  prev_cursor_pos_y = current_cursor_pos_y

  silent! timer_stop(cite_act_timer)
  cite_act_timer = timer

  # Get current position column index of character
  const stoppos: number = charcol('.') - 2
  if stoppos <= 0 | return | endif

  var startpos: number = stoppos
  const str: string = getline('.')
  while str[startpos] =~ '\w'
    startpos = startpos - 1
  endwhile

  if str[startpos] == '@'
    const words: string = str[startpos + 1 : stoppos]
    if words->len() >= 3
      Initial()->copy()->filter((_, item) =>
        item->get('word', '') =~? words ||
        item->get('info', '') =~? words
      )->complete(str->byteidx(startpos) + 2)
      
    endif
  endif
enddef

export def EnableCitation(): void

  augroup CiteComplete
    autocmd!
    autocmd CursorMovedI <buffer> call timer_start(300, 'Cite')
  augroup End

  cmpopt = &completeopt
  setlocal completeopt=menu,noinsert,popup

enddef

export def DisableCitation(): void

  augroup CiteComplete
    autocmd!
  augroup End

  execute 'setlocal completeopt=' .. cmpopt

enddef
