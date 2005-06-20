
" File: t7ko/windiff.vim
" Author: Ivan Tishchenko (t7ko AT mail DOT ru)
" Version: 1.1
" Last Modified: June 11, 2005
"
" Purpose: Using diff under Windows.
"
" This file is a part of a multi-purpose plugin set T7ko.  To get more info,
" install this plugin-set and type
"   :help t7ko
" for general info, or
"   :help t7ko--windiff
" for help on this plugin.

command! -bar PlugOutWindiff
  \   delcommand PlugOutWindiff
  \ | delfunction Windiff
  \ | exe "let &diffexpr=g:WindiffDiffExprSaved"
  \ | unlet g:WindiffDiffExprSaved

let g:WindiffDiffExprSaved=&diffexpr

set diffexpr=Windiff()
function! Windiff() abort
  let opt = '-a --binary '
  if &diffopt =~ 'icase'  | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  let arg2 = v:fname_new
  let arg3 = v:fname_out
  let i=1
  while i<=3
    if arg{i} =~ ' '
      let arg{i} = '"' . arg{i} . '"'
    endif
    let i=i+1
  endwhile
  if &sh =~ '\<cmd'
    silent execute '!""'.$VIMRUNTIME.'\diff"' opt arg1 arg2 '>' arg3 '"'
  else
    silent execute '!"' .$VIMRUNTIME.'\diff"' opt arg1 arg2 '>' arg3
  endif
endfunction
