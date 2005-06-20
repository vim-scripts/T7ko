
" File: t7ko/mat.vim
" Author: Ivan Tishchenko (t7ko AT mail DOT ru)
" Version: 1.1
" Last Modified: June 11, 2005
"
" Purpose: Mathematika-like loops.
"
" This file is a part of a multi-purpose plugin set T7ko.  To get more info,
" install this plugin-set and type
"   :help t7ko
" for general info, or
"   :help t7ko--mat
" for help on this plugin.

command! -bar PlugOutMat
  \   delcommand  PlugOutMat
  \ | delcommand  MatDo
  \ | delcommand  MatFor
  \ | delfunction MatDo
  \ | delfunction MatFor

command! -nargs=+ MatDo call MatDo(<f-args>)
function! MatDo(expression,ntimes) abort
  if a:ntimes <= 0
    echoerr 'Argument ntimes must be greater than zero'
    return
  endif
  let local_MatDo_i = a:ntimes
  while local_MatDo_i > 0
    execute a:expression
    let local_MatDo_i = local_MatDo_i - 1
  endwhile
endfunction

command! -nargs=+ MatFor call MatFor(<f-args>)
function! MatFor(expression,varname,begval,endval,increment) abort
  if ( a:endval - a:begval ) * a:increment <= 0
    echoerr 'Incorrect combination of begval, endval and increment specified'
    return
  endif
  let local_MatDo_i = a:begval
  let local_MatDo_s = 1
  if a:increment < 0
    let local_MatDo_s = -1
  endif
  while (local_MatDo_s*local_MatDo_i)<=(local_MatDo_s*a:endval)
    execute 'let ' . a:varname . ' = ' . local_MatDo_i
    execute a:expression
    let local_MatDo_i = local_MatDo_i + a:increment
  endwhile
endfunction
