vim9script
# Insert or delete brackets, parens, quotes in pairs .. 
# Maintainer:	JiangMiao <jiangfriend@gmail .. com>
# Contributor: camthompson
# Last Change:  2019-02-02
# Version: 2 .. 0 .. 0
# Homepage: http://www .. vim .. org/scripts/script .. php?script_id=3599
# Repository: http//github .. com/jiangmiao/auto-pairs
# License: MIT

const AutoPairs: dict<string> = get(g:, 'AutoPairs', {
  '(': ')',
  '[': ']',
  '{': '}',
  "'": "'",
  '"': '"',
  "`": "`",
  '```': '```',
  '"""': '"""',
  "'''": "'''",
})

#var b:autopairs_defaultpairs: dict<string> = null_dict
# default pairs base on filetype
def AutoPairsDefaultPairs(): dict<string>
  if !exists('b:autopairs_defaultpairs')
    b:autopairs_defaultpairs = AutoPairs->copy()
    const allPairs: dict<dict<string>> = {
          'vim': {'\v^\s*\zs"': ''},
          'rust': {'\w\zs<': '>', '&\zs''': ''},
          'php': {'<?': '?>//k]', '<?php': '?>//k]'},
    }
    for [filetype, pairs] in allPairs->items()
      if &filetype == filetype
        for [open, close] in pairs->items()
          b:autopairs_defaultpairs[open] = close
        endfor
      endif
    endfor
  endif
  return b:autopairs_defaultpairs
enddef

const AutoPairsMapBS: bool = get(g:, 'AutoPairsMapBS', true)
# Map <C-h> as the same BS
const AutoPairsMapCh: bool = get(g:, 'AutoPairsMapCh', true)
const AutoPairsMapCR: bool = get(g:, 'AutoPairsMapCR', true)
const AutoPairsWildClosedPair: string = get(g:, "AutoPairsWildClosedPair", '')
const AutoPairsMapSpace: bool = get(g:, 'AutoPairsMapSpace', true)
const AutoPairsCenterLine: bool = get(g:, 'AutoPairsCenterLine', true)
const AutoPairsShortcutToggle: string = get(g:, 'AutoPairsShortcutToggle', '<M-p>')
const AutoPairsShortcutFastWrap: string = get(g:, 'AutoPairsShortcutFastWrap', '<M-e>')
const AutoPairsMoveCharacter: string = get(g:, 'AutoPairsMoveCharacter', "()[]{}\"'")
const AutoPairsShortcutJump: string = get(g:, 'AutoPairsShortcutJump', '<M-j>')

# Fly mode will for closed pair to jump to closed pair instead of insert .. 
# also support AutoPairsBackInsert to insert pairs where jumped .. 
const AutoPairsFlyMode: bool = get(g:, 'AutoPairsFlyMode', false)

# When skipping the closed pair, look at the current and
# next line as well .. 
const AutoPairsMultilineClose: bool = get(g:, 'AutoPairsMultilineClose', true)

# Work with Fly Mode, insert pair where jumped
const AutoPairsShortcutBackInsert: string = get(g:, 'AutoPairsShortcutBackInsert', '<M-b>')

const AutoPairsSmartQuotes: bool = get(g:, 'AutoPairsSmartQuotes', true)

# 7 .. 4 .. 849 support <C-G>U to avoid breaking ' .. '
# Issue talk: http//github .. com/jiangmiao/auto-pairs/issues/3
# Vim note: http//github .. com/vim/vim/releases/tag/v7 .. 4 .. 849
const Go: string = (v:version > 704 || v:version == 704 && has("patch849")) ? "\<C-G>U" : ''

const Left: string = Go .. "\<LEFT>"
const Right: string = Go .. "\<RIGHT>"

# unicode len
const Ulen = (s: string): number => s->split('\zs')->len()
const Left_fn = (s: string): string => Left->repeat(Ulen(s))
const Right_fn = (s: string): string => Right->repeat(Ulen(s))
const Delete = (s: string): string => "\<DEL>"->repeat(Ulen(s))
const Backspace = (s: string): string => "\<Backspace>"->repeat(Ulen(s))


def Getline(): list<string>
  var line: string = getline('.')
  const pos: number = col('.') - 1
  const before: string = line->strpart(0, pos)
  var after: string = line->strpart(pos)
  const afterline: string = after
  if AutoPairsMultilineClose
    for i in range(line('.') + 1, line('$'))
      line = getline(i)
      after = after .. ' ' .. line
      if line !~ '\v^\s*$'
        break
      endif
    endfor
  endif
  return [before, after, afterline]
enddef

# split text to two part
# returns [orig, text_before_open, open]
def Matchend(text: string, open: string): list<string>
    const m: string = text->matchstr('\V' .. open .. '\v$')
    return m->empty()
      ? []
      : [text, text->strpart(0, text->len() - m->len()), m]
enddef

# returns [orig, close, text_after_close]
def Matchbegin(text: string, close: string): list<string>
    const m: string = text->matchstr('^\V' .. close)
    return m->empty()
      ? []
      : [text, m, text->strpart(m->len(), text->len() - m->len())]
enddef

# add or delete pairs base on AutoPairs
# AutoPairsDefine(addPairdict[, removeOpenPairList:list])
# e
#   au FileType html var b:AutoPairs = AutoPairsDefine({'<!--' : '-->'}, ['{'])
#   add <!-- --> pair and remove '{' for html file
def g:AutoPairsDefine(pairs: dict<string>, rm: list<string>): dict<string>
  var r = AutoPairsDefaultPairs()
  for open in rm
    r[open] = null_string
  endfor
  for [open, close] in pairs->items()
    r[open] = close
  endfor
  return r
enddef

def g:AutoPairsInsert(key: string): string
  if !b:autopairs_enabled
    return key
  endif

  b:autopairs_saved_pair = [key, getpos('.')]

  var [before, after, afterline] = Getline()

  # Ignore auto close if prev character is \
  if before[-1] == '\'
    return key
  endif

  # check open pairs
  for [open, close, _] in b:AutoPairsList
    var ms: list<string> = Matchend(before .. key, open)
    var m: string = afterline->matchstr('^\v\s*\zs\V' .. close)
    if len(ms) > 0
      # process the open pair
      
      # remove inserted pair
      # e if the pairs include < > and  <!-- --> 
      # when <!-- is detected the inserted pair < > should be clean up 
      const target: string = ms[1]
      const openPair: string = ms[2]
      if openPair->len() == 1 && m == openPair
        break
      endif
      var bs: string
      var del: string
      while before->len() > target->len()
        var found: bool = false
        # delete pair
        for [o, c, opts] in b:AutoPairsList
          const os: list<string> = Matchend(before, o)
          if os->len() > 0 && os[1]->len() < target->len()
            # any text before openPair should not be deleted
            continue
          endif
          const cs: list<string> = Matchbegin(afterline, c)
          if os->len() > 0 && cs->len() > 0
            found = true
            before = os[1]
            afterline = cs[2]
            bs = bs .. Backspace(os[2])
            del = del .. Delete(cs[1])
            break
          endif
        endfor
        if !found
          # delete charactor
          ms = Matchend(before, '\v.')
          if ms->len() > 0
            before = ms[1]
            bs = bs .. Backspace(ms[2])
          endif
        endif
      endwhile
      return bs .. del .. openPair .. close .. Left_fn(close)
    endif
  endfor

  # check close pairs
  for [open, close, opt] in b:AutoPairsList
    if close->empty()
      continue
    endif
    if key == AutoPairsWildClosedPair || opt['mapclose'] && opt['key'] == key
      # the close pair is in the same line
      var m: string = afterline->matchstr('^\v\s*\V' .. close)
      if !m->empty()
        if before =~ '\V' .. open .. '\v\s*$' && m[0] =~ '\v\s'
          # remove the space we inserted if the text in pairs is blank
          return "\<DEL>" .. Right_fn(m[1 : ])
        endif
        return Right_fn(m)
      endif
      m = after->matchstr('^\v\s*\zs\V' .. close)
      if !m->empty()
        if key == AutoPairsWildClosedPair || opt['multiline']
          if b:autopairs_return_pos == line('.') && getline('.') =~ '\v^\s*$'
            normal! ddk$
          endif
          search(m, 'We')
          return "\<Right>"
        endif
        break
      endif
    endif
  endfor


  # Fly Mode, and the key is closed-pairs, search closed-pair and jump
  if AutoPairsFlyMode && key =~ '\v[\}\]\)]'
    if search(key, 'We')
      return "\<Right>"
    endif
  endif

  return key
enddef

def g:AutoPairsDelete(): string
  if !b:autopairs_enabled
    return "\<BS>"
  endif

  const [before, after, ig] = Getline()
  for [open, close, opt] in b:AutoPairsList
    const b: string = before->matchstr('\V' .. open .. '\v\s?$')
    const a: string = after->matchstr('^\v\s*\V' .. close)
    if !b->empty() && !a->empty()
      if b[-1] == ' '
        return a[0] == ' ' ? "\<BS>\<DELETE>" : "\<BS>"
      endif
      return Backspace(b) .. Delete(a)
    endif
  endfor

  return "\<BS>"
enddef


# Fast wrap the word in brackets
def AutoPairsFastWrap(): string
  const c: string = @"
  normal! x
  const [before, after, ig] = Getline()
  if after[0] =~ '\v[\{\[\(\<]'
    normal! %
    normal! p
  else
    for [open, close, opt] in b:AutoPairsList
      if close->empty()
        continue
      endif
      if after =~ '^\s*\V' .. open
        search(close, 'We')
        normal! p
        @" = c
        return ""
      endif
    endfor
    if after[1] =~ '\v\w'
      normal! e
      normal! p
    else
      normal! p
    endif
  endif
  @" = c
  return ""
enddef

const g:AutoPairsJump = (): number => search('["\]'')}]', 'W')

def g:AutoPairsMoveCharacterF(key: string): string
  const escaped_key: string = key->substitute("'", "''", 'g')
  return printf("\<DEL>\<ESC>:call search('%s')\<CR>a%s\<LEFT>",
      escaped_key,
      getline('.')[col('.') - 1]
  )
enddef

def g:AutoPairsBackInsert()
  const pair = b:autopairs_saved_pair[0]
  const pos: number  = b:autopairs_saved_pair[1]
  setpos('.', pos)
  return pair
enddef

def g:AutoPairsReturn(): string
  if !b:autopairs_enabled
    return ''
  endif
  b:autopairs_return_pos = 0
  const before: string = getline(line('.') - 1)
  const [_, _, afterline] = Getline()
  var cmd: string
  for [open, close, opt] in b:AutoPairsList
    if close->empty()
      continue
    endif

    if before =~ '\V' .. open .. '\v\s*$' && afterline =~ '^\s*\V' .. close
      b:autopairs_return_pos = line('.')
      if AutoPairsCenterLine && winline() * 3 >= winheight(0) * 2
        # Recenter before adding new line to avoid replacing line content
        cmd = "zz"
      endif

      # If equalprg has been set, then avoid call =
      # http//github .. com/jiangmiao/auto-pairs/issues/24
      if !&equalprg->empty()
        return "\<ESC>" .. cmd .. "O"
      endif

      # conflict with javascript and coffee
      # javascript   need   indent new line
      # coffeescript forbid indent new line
      if &filetype == 'coffeescript' || &filetype == 'coffee'
        return "\<ESC>" .. cmd .. "k==o"
      else
        return "\<ESC>" .. cmd .. "=ko"
      endif
    endif
  endfor
  return ''
enddef

def g:AutoPairsSpace(): string
  if !b:autopairs_enabled
    return "\<SPACE>"
  endif

  const [before, after, _] = Getline()

  for [open, close, _] in b:AutoPairsList
    if close->empty()
      continue
    endif
    if before =~ '\V' .. open .. '\v$' && after =~ '^\V' .. close
      if close =~ '\v^[''"`]$'
        return "\<SPACE>"
      else
        return "\<SPACE>\<SPACE>" .. Left
      endif
    endif
  endfor
  return "\<SPACE>"
enddef

def AutoPairsMap(key: string)
  # | is special key which separate map command from text
  const lkey: string = (key == '|') ? '<BAR>' : key
  const escaped_key: string = lkey->substitute("'", "''", 'g')
  # use expr will cause search() doesn't work
  printf("inoremap <buffer><silent> %s <C-R>=AutoPairsInsert('%s')<CR>",
      lkey,
      escaped_key
  )->execute()
enddef

def g:AutoPairsToggle()
  if b:autopairs_enabled
    b:autopairs_enabled = false
    echo 'AutoPairs Disabled .. '
  else
    b:autopairs_enabled = true
    echo 'AutoPairs Enabled .. '
  endif
enddef

def AutoPairsInit()

  b:autopairs_loaded = true
  b:autopairs_enabled = true

  if !exists('b:AutoPairs')
    b:AutoPairs = AutoPairsDefaultPairs()
  endif

  if !exists('b:AutoPairsMoveCharacter')
    b:AutoPairsMoveCharacter = AutoPairsMoveCharacter
  endif

  b:autopairs_return_pos = 0
  b:autopairs_saved_pair = [0, 0]
  b:AutoPairsList = []

  # buffer level map pairs keys
  # n - do not map the first charactor of closed pair to close key
  # m - close key jumps through multi line
  # s - close key jumps only in the same line
  for [open, close] in b:AutoPairs->items()
    const o: string = open[-1]
    var c: string = close[0]
    var opt: dict<any> = {
      'key': c,
      'mapclose': true,
      'multiline': (o == c) ? false : true,
    }
    const m: list<string> = close->matchlist('\v(.*)//(.*)$')
    if m->len() > 0
      if m[2] =~ 'n'
        opt['mapclose'] = false
      endif
      if m[2] =~ 'm'
        opt['multiline'] = true
      endif
      if m[2] =~ 's'
        opt['multiline'] = false
      endif
      const ks: list<string> = m[2]->matchlist('\vk(.)')
      if ks->len() > 0
        opt['key'] = ks[1]
        c = opt['key']
      endif
    endif
    AutoPairsMap(o)
    if o != c && !c->empty() && opt['mapclose']
      AutoPairsMap(c)
    endif
    b:AutoPairsList += [[open, close, opt]]
  endfor

  # sort pairs by length, longer pair should have higher priority
  b:AutoPairsList = b:AutoPairsList->sort(
    (i1: list<any>, i2: list<any>): number => i2[0]->len() - i1[0]->len()
  )

  for item in b:AutoPairsList
    const [open, close, _] = item
    if open == "'" && open == close
      item[0] = '\v(^|\W)\zs'''
    endif
  endfor


  for key in b:AutoPairsMoveCharacter->split('\s*')
    const escaped_key: string = key->substitute("'", "''", 'g')
    printf("inoremap <buffer><silent> <M-%s> <C-R>=AutoPairsMoveCharacterF('%s')<CR>",
      key,
      escaped_key
    )->execute()
  endfor

  # Still use <buffer> level mapping for <BS> <SPACE>
  if AutoPairsMapBS
    # Use <C-R> instead of <expr> for issue #14 sometimes press BS output strange words
    execute 'inoremap <buffer><silent> <BS> <C-R>=AutoPairsDelete()<CR>'
  endif

  if AutoPairsMapCh
    execute 'inoremap <buffer><silent> <C-h> <C-R>=AutoPairsDelete()<CR>'
  endif

  if AutoPairsMapSpace
    # Try to respect abbreviations on a <SPACE>
    const do_abbrev: string = 
      (v:version == 703 && has("patch489") || v:version > 703)
    ? "<C-]>"
    : ''
    printf('inoremap <buffer><silent> <SPACE> %s<C-R>=AutoPairsSpace()<CR>',
      do_abbrev
    )->execute()
  endif

  if !AutoPairsShortcutFastWrap->empty()
    printf('inoremap <buffer><silent> %s <C-R>=AutoPairsFastWrap()<CR>',
      AutoPairsShortcutFastWrap
    )->execute()
  endif

  if !AutoPairsShortcutBackInsert->empty()
    printf('inoremap <buffer><silent> %s <C-R>=AutoPairsBackInsert()<CR>',
      AutoPairsShortcutBackInsert
    )->execute()
  endif

  if !AutoPairsShortcutToggle->empty()
    # use <expr> to ensure showing the status when toggle
    printf('inoremap <buffer><silent><expr> %s AutoPairsToggle()',
      AutoPairsShortcutToggle
    )->execute()
    printf('noremap <buffer><silent> %s :call AutoPairsToggle()<CR>',
      AutoPairsShortcutToggle
    )->execute()
  endif

  if !AutoPairsShortcutJump->empty()
    printf('inoremap <buffer><silent> %s <ESC>:call AutoPairsJump()<CR>a',
      AutoPairsShortcutJump
    )->execute()
    printf('noremap <buffer><silent> %s :call AutoPairsJump()<CR>',
      AutoPairsShortcutJump
    )->execute()
  endif

  if !&keymap->empty()
    const imsearch: number = &imsearch
    const iminsert: number = &iminsert
    const imdisable: bool = &imdisable
    execute 'setlocal keymap=' .. &keymap
    execute 'setlocal imsearch=' .. imsearch
    execute 'setlocal iminsert=' .. iminsert
    if imdisable
      execute 'setlocal imdisable'
    else
      execute 'setlocal noimdisable'
    endif
  endif

enddef

const ExpandMap = (map: string): string => map
  ->substitute('\(<Plug>\w\+\)', '\=maparg(submatch(1), "i")', 'g')
  ->substitute('\(<Plug>([^)]*)\)', '\=maparg(submatch(1), "i")', 'g')

def AutoPairsTryInit()
  if exists('b:autopairs_loaded')
    return
  endif

  # for auto-pairs starts with 'a', so the priority is higher than supertab and vim-endwise
  # vim-endwise doesn't support <Plug>AutoPairsReturn
  # when use <Plug>AutoPairsReturn will cause <Plug> isn't expanded
  # supertab doesn't support <SID>AutoPairsReturn
  # when use <SID>AutoPairsReturn  will cause Duplicated <CR>
  # and when load after vim-endwise will cause unexpected endwise inserted .. 
  # so always load AutoPairs at last

  # Buffer level keys mapping
  # comptible with other plugin
  const info: dict<any> = maparg('<CR>', 'i', 0, 1)
  var old_cr: string
  var is_expr: bool
  var wrapper_name: string
  if AutoPairsMapCR
    if v:version == 703 && has('patch32') || v:version > 703
      # VIM 7 .. 3 supports advancer maparg which could get <expr> info
      # then auto-pairs could remap <CR> in any case .. 
      if info->empty()
        old_cr = '<CR>'
        is_expr = false
      else
        old_cr = ExpandMap(info['rhs'])->substitute(
          '<SID>',
          printf('<SNR>%s_', info['sid']),
          'g'
        )
        is_expr = info['expr']
        wrapper_name = '<SID>AutoPairsOldCRWrapper73'
      endif
    else
      # VIM version less than 7 .. 3
      # the mapping's <expr> info is lost, so guess it is expr or not, it's
      # not accurate .. 
      old_cr = maparg('<CR>', 'i')
      if old_cr->empty()
        old_cr = '<CR>'
        is_expr = false
      else
        old_cr = ExpandMap(old_cr)
        # old_cr contain (, I guess the old cr is in expr mode
        is_expr = old_cr =~ '\V(' && old_cr->toupper() !~ '\V<C-R>'

        # The old_cr start with # it must be in expr mode
        is_expr = is_expr || old_cr =~ '\v^"'
        wrapper_name = '<SID>AutoPairsOldCRWrapper'
      endif
    endif

    if old_cr !~ 'AutoPairsReturn'
      if is_expr
        # remap <expr> to `name` to avoid mix expr and non-expr mode
        printf('inoremap <buffer><expr><script> %s %s',
          wrapper_name,
          old_cr
        )->execute()
        old_cr = wrapper_name
      endif
      # Always silent mapping
      printf('inoremap <buffer><silent><script> <CR> %s<SID>AutoPairsReturn',
        old_cr,
      )->execute()
    endif
  endif
  AutoPairsInit()
enddef

# Always silent the command
inoremap <silent> <SID>AutoPairsReturn <C-R>=AutoPairsReturn()<CR>
imap <script> <Plug>AutoPairsReturn <SID>AutoPairsReturn

autocmd BufEnter * :call AutoPairsTryInit()
