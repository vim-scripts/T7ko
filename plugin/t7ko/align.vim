
" File: t7ko/align.vim
" Author: Ivan Tishchenko (t7ko AT mail DOT ru)
" Version: 1.1
" Last Modified: June 11, 2005
"
" Purpose: Align text to be columns-like.
"
" This file is a part of a multi-purpose plugin set T7ko.  To get more info,
" install this plugin-set and type
"   :help t7ko
" for general info, or
"   :help t7ko--align
" for help on this plugin.

command! -bar PlugOutAlign
  \   delcommand  PlugOutAlign
  \ | delcommand  Align
  \ | delcommand  AlignF
  \ | delfunction Align
  \ | delfunction s:AlignDo
  \ | delfunction s:AlignPad

command! -range -nargs=* Align  <line1>,<line2>call Align('',<f-args>)
command! -range -nargs=* AlignF <line1>,<line2>call Align(<f-args>)

function! Align(cmds, ...) range abort
  let char      = ' '
  let condition = ''
  let shift     = ''

  let i  = 1
  let c  = a:cmds
  while strlen(c) > 0
    if i > a:0
      throw 'Not enough parameters passed to Align.'
    endif
    if     c[0] == 'i' | let condition = a:{i}
    elseif c[0] == 'c' | let char      = a:{i}
    elseif c[0] == 's' | let shift     = a:{i}
    elseif c[0] == 'S' | let shift     = ' '    | let i = i-1
    else | throw 'Unknown cmd '.c[0].' passed to align.'
    endif
    let i = i+1
    let c = strpart(c,1)
  endwhile

  while i <= a:0
    call s:AlignDo(a:{i},condition,char,shift,a:firstline,a:lastline)
    let i = i+1
  endwhile
endfunction

" condition must be string, which being evaluated yelds true or false
" depending on must sln be aligned or not.

function! s:AlignDo(regex, condition, char, shift, first, last) abort
  let padding = a:char

  let col    = 0
  let maxcol = 0

  let do_check = strlen(a:condition) > 0
  let res = 1

  " Find the maximum column "
  let ln = a:first
  while ln <= a:last
    let sln = getline(ln)
  if do_check
      execute 'let res=('.a:condition.')'
    endif

    if res && sln =~ a:regex
      let col    = match(sln, a:regex)
      let maxcol = col > maxcol ? col : maxcol
    endif

    let ln = ln + 1
  endwhile

  " Set them all "
  let ln = a:first
  while ln <= a:last
    let sln = getline(ln)
    if do_check
      execute 'let res='.a:condition
    endif

    if res && sln =~ a:regex
      let col = match(sln, a:regex)
      call setline(ln,
            \   strpart(sln, 0, col)
            \ . s:AlignPad('', maxcol-col, ' ')
            \ . a:shift
            \ . strpart(sln, col)
            \ )
    endif

    let ln = ln + 1
  endwhile
endfunction

function! s:AlignPad(str, num, char) abort
  let str = a:str
  while strlen(str) < a:num
    let str = a:char . str
  endwhile
  return str
endfunction
