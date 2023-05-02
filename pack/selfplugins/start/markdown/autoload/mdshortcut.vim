" encoding: utf-8
" ========================================================
"
" File: mdshortcut.vim
"
" Author: chunshuyumao
" Created: 2022-10-09 18:41:19 Sunday
" Modified: 2022-10-09 18:41:19 Sunday
"
" Description: 
"
" ========================================================

if !exists('g:html_yaml')
  let g:html_yaml = expand('~/Documents/Pandoc/defaults/HTML.yaml')
endif

if !exists('g:img_dir')
  let g:img_dir = 'Assets'
endif

function! mdshortcut#insert_image_from_clip() abort

  if !executable('xclip')
    echom 'Please install xclip for getting image!'
    return
  endif

  let l:put_img_to = 'xclip -sel clip -target image/png -o >'
  if !system(printf("%s /dev/null", l:put_img_to))->empty()
    return popup_notification('Empty clipboard!', {
          \ 'col': 'cursor',
          \ 'line': 'cursor',
          \ 'moved': 'any',
          \ })
  endif

  call inputsave()
  let l:imgname = input('Enter image name: ', strftime('%Y%m%d%H%M%S'))
  call inputrestore()

  if l:imgname->empty()
    return
  endif

  if !isdirectory(g:img_dir)
    call mkdir(g:img_dir, 'p', 0750)
  endif

  let l:target = printf("%s/%s.png", g:img_dir, l:imgname)
  call system(printf("%s %s", l:put_img_to, l:target))
  " Optimized
  call job_start('pngquant -f --ext .png --strip -Q 20-50 '..l:target)

  call setline('.', printf("![<++>](%s){#fig:<++>}", l:target))

endfunction

function! mdshortcut#insert_table() abort

  call inputsave()
  let l:XY = input('Enter table X×Y(e.g 3,4): ')
  call inputrestore()

  if l:XY->empty()
    return
  endif

  let [X, Y; _] = l:XY->split(',')
  call append('.',
        \ [repeat('|<++>', X) .. '|']->repeat(Y)
        \ ->insert(repeat('|:----:', X) .. '|', 1)
        \ ->add(': <++> {#tbl:<++>}'))

endfunction

"function s:formated_tbl() range
"
"  let l:lines = getline(a:firstline, a:lastline)
"  let l:lines_arr = l:lines->map('v:val->split("|")->map("v:val->trim()")')
"
"  let l:width_arr = l:lines_arr[0]->len()->range()->mapnew('v:val->strwidth()')
"
"
"endfunction


function! mdshortcut#format_table() range
  let l:start = strftime('%s')
  call setline(a:firstline, { lines -> { widths -> lines
        \ ->map({_, row -> printf("|%s|", row->map({_, txt -> {
        \  width -> txt=~'[:-]\{3,}'?printf(" %s%s%s ", txt[0],
        \   repeat('-', width - 2), txt[-1:]) : { space -> { lr ->
        \    printf(" %s%s%s%s ", lr, txt, lr, space%2?' ':'')
        \       }(repeat(' ', float2nr(space/2)))
        \      }(width - txt->strwidth())
        \     }(widths->remove(0))
        \    })->join('|'))
        \   })
        \  }(lines[0]->len()->range()->map({_,v -> lines
        \    ->mapnew('v:val->mapnew("v:val->strwidth()")')
        \    ->map('v:val[v]')->max()
        \   })->repeat(lines->len()))
        \ }(getline(a:firstline, a:lastline)
        \   ->map('v:val->split("|")->map("v:val->trim()")')
        \   ->filter('v:val->len() > 1'))
        \ )
  echom (strftime('%s') - start)
endfunction

function! mdshortcut#command(action) abort
  try
    let l:rgs_a = @a
    if a:action == 'link'

      call inputsave()
      let l:link = input('Enter link: ')
      call inputrestore()

      if l:link->empty()
        return
      endif

      silent! normal! gv"ad
      exec printf("normal! i[%s](%s)\<Esc>", @a, l:link)
    elseif a:action == 'italic'
      silent! normal! gv"ad
      exec printf("normal! i*%s*\<Esc>", @a)
    elseif a:action == 'emphasize'
      silent! normal! gv"ad
      exec printf("normal! i**%s**\<Esc>", @a)
    endif
  finally
    let @a = l:rgs_a
  endtry
endfunction

let s:target = tempname() . '.html'

function! mdshortcut#preview_in_browser(job, msg) abort
  if !exists('s:job_id') && s:target->filereadable()
    let s:job_id = ['firefox', s:target]->job_start({
          \ 'exit_cb': function('mdshortcut#close_markdow_preview'),
          \ })
  endif
endfunction

function! mdshortcut#markdown2html_n_preview() abort
  if exists('s:pandoc_job_id')
    silent! call job_stop(s:pandoc_job_id)
  endif
  let s:pandoc_job_id = job_start([
        \ 'pandoc', 
        \ '-d', g:html_yaml,
        \ '--lua-filter=relative2abs.lua',
        \ expand('%'),
        \ '-o', s:target,
        \ ], {
        \  'exit_cb': function('mdshortcut#preview_in_browser'),
        \  'callback': { _, msg -> popup_notification(msg, {
        \     'time': 90000, 'moved': 'any',
        \   })},
        \ })
endfunction

function! mdshortcut#close_markdow_preview(...) abort
  if exists('s:job_id')
    call job_stop(s:job_id)
    unlet s:job_id
  endif
endfunction

function! mdshortcut#cite() abort
  " pick a format based on the filetype (customize at will)
  let l:format = &filetype =~ '.*tex' ? 'citep' : 'pandoc'
  let l:api_call = 'http://localhost:23119/better-bibtex/cayw?format='.l:format.'&brackets=1'
  let l:ref = system('curl -qs '.shellescape(l:api_call))
  return l:ref
endfunction
