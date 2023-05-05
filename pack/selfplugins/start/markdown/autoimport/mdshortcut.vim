vim9script
# encoding: utf-8
# ========================================================
#
# File: mdshortcut.vim
#
# Author: chunshuyumao
# Created: 2023-04-28 22:39:17 Friday
# Modified: 2023-04-28 22:39:17 Friday
#
# Description: 
#
# ========================================================

var img_dir: string = get(g:, 'img_dir', 'Assets')
var html_yaml: string = get(g:, 'html_yaml', expand('~/Documents/Pandoc/defaults/HTML.yaml'))

var job_id: job = null_job
var pandoc_job_id: job = null_job
const target: string = tempname() .. '.html'

var command_tbl: dict<func()> = null_dict

export def InsertImageFromClip(): void

  if !executable('xclip')
    echowin 'Please install xclip for getting image!'
    return
  endif

  const put_img_to: string = 'xclip -sel clip -target image/png -o >'
  if !system(put_img_to .. " /dev/null")->empty()
    popup_notification('Empty clipboard!', {
           'col': 'cursor',
           'line': 'cursor',
           'moved': 'any',
           })
    return
  endif

  inputsave()
  const imgname: string = input('Enter image name: ', strftime('%Y%m%d%H%M%S'))
  inputrestore()

  if imgname->empty()
    return
  endif

  if !isdirectory(img_dir)
    mkdir(img_dir, 'p', 0750)
  endif

  const target: string = printf("%s/%s.png", img_dir, imgname)
  system(put_img_to .. ' ' .. target)
  #Optimized
  job_start('pngquant -f --ext .png --strip -Q 20-50 ' .. target)

  setline('.', "![<++>](" .. target .. "){#fig:<++>}")

enddef


export def InsertTable(): void

  inputsave()
  const XY: list<number> = input('Enter table X×Y(e.g 3,4): ')
                            ->split(',')
                            ->map('str2nr(v:val)')
  inputrestore()

  if XY->empty()
    return
  endif

  append('.',
    [repeat('|<++>', XY[0]) .. '|']
      ->repeat(XY[1])
      ->insert(repeat('|:----:', XY[0]) .. '|', 1)
      ->add('')
      ->add(': <++> {#tbl:<++>}'))
enddef

export def FormatTable(firstline: number, lastline: number): void

  var lines: list<list<string>> = getline(firstline, lastline)
    ->map((_, v): list<string> => v->split('|')->map('v:val->trim()'))

  var max_width: list<number>
  for i in range(lines[0]->len())
    max_width[i] = max(lines->mapnew((_, v): number => v[i]->strwidth()))
  endfor

  var tbl: list<string>
  for i in range(lines->len())
    for j in range(lines[i]->len())
      const str: string = lines[i][j]
      const width: number = max_width[j]

      if str =~ '[:-]\{3,}'
        lines[i][j] = printf(' %s%s%s ', str[0], repeat('-', width - 2), str[-1])
        continue
      endif

      const n_space: number = width - str->strwidth()
      const padding: string = repeat(' ', float2nr(n_space / 2))

      lines[i][j] = printf(' %s%s%s%s ', padding, str, padding, n_space % 2 ? ' ' : '')
    endfor
    tbl[i] = lines[i]->join('|')->printf('|%s|')
  endfor

  setline(firstline, tbl)
enddef

def GetComandTbl(): dict<func()>

  if command_tbl == null_dict
    command_tbl = {
      'link': () => {
        inputsave()
        const link: string = input('Enter link: ')
        inputrestore()

        if link->empty()
          return
        endif

        silent! normal! gv"ad
        exec printf("normal! i[%s](%s)\<Esc>", @a, link)
      },
      'italic': () => {
        silent! normal! gv"ad
        exec printf("normal! i*%s*\<Esc>", @a)
      },
      'strong': () => {
        silent! normal! gv"ad
        exec printf("normal! i**%s**\<Esc>", @a)
      }}
  endif
  return command_tbl
enddef


export def Command(action: string): void
  const rgs_a: string = @a
  GetComandTbl()->get(action, () => {
    @a = rgs_a
  })()
  @a = rgs_a
enddef


def PreviewInBrowser(job: job, msg: number): void
  if job_id == null_job && target->filereadable()
    job_id = ['firefox', target]->job_start()
  endif
enddef


export def Markdown2HTMLNPreview(): void
  if pandoc_job_id != null_job
    silent! job_stop(pandoc_job_id)
  endif
  pandoc_job_id = job_start([
    'pandoc', 
    '-d', html_yaml,
    '--lua-filter=relative2abs.lua',
    expand('%'),
    '-o', target,
    ], {
     'exit_cb': PreviewInBrowser,
     'callback': (_, msg) => popup_notification(msg, {
        'time': 90000, 'moved': 'any',
      }),
    })
enddef


export def CloseMarkdowPreview(): void
  if job_id != null_job
    job_stop(job_id)
    job_id = null_job
  endif
enddef


export def Cite(): string
  # pick a format based on the filetype (customize at will)
  const format: string = &filetype =~ '.*tex' ? 'citep' : 'pandoc'
  const api_call: string = 'http://localhost:23119/better-bibtex/cayw?format=' .. format .. '&brackets=1'
  const ref: string = system('curl -qs ' .. shellescape(api_call))
  return ref
enddef
