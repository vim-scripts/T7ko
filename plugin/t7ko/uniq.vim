
" File: t7ko/uniq.vim
" Author: Ivan Tishchenko (t7ko AT mail DOT ru)
" Version: 1.1
" Last Modified: June 11, 2005
"
" Purpose: Eliminating duplicates of lines.
"
" This file is a part of a multi-purpose plugin set T7ko.  To get more info,
" install this plugin-set and type
"   :help t7ko
" for general info, or
"   :help t7ko--uniq
" for help on this plugin.

command! -bar PlugOutUniq
  \   delcommand  PlugOutUniq
  \ | delcommand  Uniq
  \ | delfunction Uniq

command! -range=% -bar Uniq <line1>,<line2>call Uniq()

function! Uniq() range abort
  let i=a:lastline
  while i>a:firstline
    if getline(i)==getline(i-1)
      exe i 'del'
    endif
    let i=i-1
  endwhile
endfunction
