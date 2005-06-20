
" File: t7ko/sort.vim
" Author: Ivan Tishchenko (t7ko AT mail DOT ru)
" Version: 1.1
" Last Modified: June 17, 2005
"
" Purpose: Sorting lines.
"
" Note: This file also contains slightly modified code for sorting lines by
" Robert Webb.
"
" This file is a part of a multi-purpose plugin set T7ko.  To get more info,
" install this plugin-set and type
"   :help t7ko
" for general info, or
"   :help t7ko--sort
" for help on this plugin.

" vim: foldmethod=marker foldmarker={{{,}}}

command! -bar PlugOutSort
  \   delcommand  PlugOutSort
  \ | delcommand  SortT7ko
  \ | delfunction SortT7ko
  \ | delcommand  SortWebb
  \ | delfunction SortWebb
  \ | delfunction s:SortWebbR
  \ | delfunction SortStrLess
  \ | delfunction SortStrCmp

function! SortStrLess(str1,str2) abort "{{{1
  return a:str1 < a:str2
endfunction

function! SortStrCmp(str1, str2) "{{{1
  return a:str1 < a:str2 ? -1 :
       \ a:str1 > a:str2 ?  1 :
       \ 0
endfunction

command! -bar -nargs=? -range=% SortT7ko <line1>,<line2>call SortT7ko(<f-args>) "{{{1

function! SortT7ko(...) range abort "{{{1
  if a:firstline > a:lastline
    echoerr "Invalid rage"
  endif
  if a:0>1
    echoerr '0 or 1 argument must be supplied'
  endif
  let cmpfunc = ( a:0>0 ? a:1 : "SortStrLess" )
  if !exists('*'.cmpfunc)
    echoerr "Comparison function" cmpfunc "doesn't exists"
  endif
  let finished=0
  let start=a:firstline
  while !finished
    let i=start
    let finished=1
    while i<a:lastline
      exe 'let rc='.cmpfunc.'(getline(i+1),getline(i))'
      if rc
        if finished
          if i>a:firstline
            let start=i-1
          else
            let start=a:firstline
          endif
        endif
        let finished=0
        exe i
        normal ddp
      endif
      let i=i+1
    endwhile
  endwhile
endfunction

command! -bar -nargs=? -range=% SortWebb <line1>,<line2>call SortWebb(<f-args>) "{{{1

function! SortWebb(...) range abort "{{{1
  if a:firstline > a:lastline
    echoerr "Invalid range"
  endif
  if a:0>1
    echoerr '0 or 1 argument must be supplied'
  endif
  let cmpfunc = ( a:0>0 ? a:1 : "SortStrCmp" )
  if !exists('*'.cmpfunc)
    echoerr "Comparison function" cmpfunc "doesn't exists"
  endif
  call s:SortWebbR(a:firstline,a:lastline,cmpfunc)
endfunction

function! s:SortWebbR(start,end,cmpfunc) abort
  if (a:start >= a:end)
    return
  endif
  let partition = a:start - 1
  let middle = partition
  let partStr = getline((a:start + a:end) / 2)
  let i = a:start
  while (i <= a:end)
    let str = getline(i)
    exec "let result = " . a:cmpfunc . "(str, partStr)"
    if (result <= 0)
      " Need to put it before the partition.  Swap lines i and partition.
      let partition = partition + 1
      if (result == 0)
        let middle = partition
      endif
      if (i != partition)
        let str2 = getline(partition)
        call setline(i, str2)
        call setline(partition, str)
      endif
    endif
    let i = i + 1
  endwhile

  " Now we have a pointer to the "middle" element, as far as partitioning
  " goes, which could be anywhere before the partition. Make sure it is at
  " the end of the partition.
  if (middle != partition)
    let str = getline(middle)
    let str2 = getline(partition)
    call setline(middle, str2)
    call setline(partition, str)
  endif
  call s:SortWebbR( a:start,     partition-1, a:cmpfunc)
  call s:SortWebbR( partition+1, a:end,       a:cmpfunc)
endfunction
