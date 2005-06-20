
" File: t7ko/position.vim
" Author: Ivan Tishchenko (t7ko AT mail DOT ru)
" Version: 1.1
" Last Modified: June 11, 2005
"
" Purpose: Saving and restoring position.
"
" This file is a part of a multi-purpose plugin set T7ko.  To get more info,
" install this plugin-set and type
"   :help t7ko
" for general info, or
"   :help t7ko--position
" for help on this plugin.

" vim: foldmethod=marker foldcolumn=2

command! -bar PlugOutPosition
  \   delcommand  PlugOutPosition
  \ | delcommand  PositionSave
  \ | delcommand  PositionRestore
  \ | delcommand  PositionListCOpen
  \ | delfunction PositionSave
  \ | delfunction PositionRestore
  \ | delfunction PositionListCOpen
  \ | delfunction PositionCmd
  \ | delfunction PositionSCmd
  \ | exe "unmap <c-q>ps"
  \ | exe "unmap <c-q>pr"

"{{{1 Mappings
nmap <c-q>ps :PositionSave<cr>
nmap <c-q>pr :PositionRestore<cr>

command! -bar PositionSave    call PositionSave   () "{{{1

command! -bar PositionRestore call PositionRestore() "{{{1

function! PositionSave() "{{{1
    let @"='<'.@%.'|'.line('.').'|'.col('.').'>'
    let @+=@"
endfunction

function! PositionRestore() "{{{1
    let s=getline('.')
  let c=col('.')
  let beg=match(strpart(s,0,c),'<[^<]*$')
  let end=match(s,'>',c-1)
  let pos=strpart(s,beg+1,end-beg-1)
  if beg<0 || end<0 || pos=~'[<>]'
    echoerr 'There is no saved position under cursor'
    return 0
  endif
  exe 'new '.substitute(pos,'|\(\d\+\)$','|normal 0\1lh','')
  return 1
endfunction

command! -range PositionListCOpen <line1>,<line2>call PositionListCOpen() "{{{1

function! PositionListCOpen() range abort "{{{1
  let fname=tempname()
  let regsave=@"
  try
    execute a:firstline ',' a:lastline 'yank'
    execute 'new' fname
    %del _
    put "
    normal Go
    setlocal errorformat=<%f\|%l\|%c>%m
    execute '%s/\s*\n\s*/ '."\<cr>/ge"
    w
    execute 'cfile' fname
    execute 'bw' fname
    call delete(fname)
    wincmd x
    wincmd w
  finally
    if -1 < bufnr(fname)
      exe 'bw' fname
    endif
    call delete(fname)
    let @"=regsave
  endtry
  copen
endfunction

function! PositionCmd() abort "{{{1
  return 'silent '.line('.').'|silent exe "normal '.col('.').'|"'
endfunction

function! PositionSCmd() abort "{{{1
  " Unlike PositionCmd, saves relative position of current line in viewport.
  let cmd = PositionCmd()
  normal H
  let ret = 'silent '.line('.').'|execute "normal zt"|'.cmd
  exe cmd
  return ret
endfunction

