
" File: t7ko/text.vim
" Author: Ivan Tishchenko (t7ko AT mail DOT ru)
" Version: 1.1
" Last Modified: June 11, 2005
"
" Purpose: Text files editing.
"
" This file is a part of a multi-purpose plugin set T7ko.  To get more info,
" install this plugin-set and type
"   :help t7ko
" for general info, or
"   :help t7ko--text
" for help on this plugin.

command! -bar PlugOutText
  \   delcommand  PlugOutText
  \ | delcommand  TextVimlinesPut
  \ | delfunction TextVimlinesPut
  \ | delcommand  TextEnableCodeSnip
  \ | delfunction TextEnableCodeSnip
  \ | delfunction s:TextECSComplete

command! -bar TextVimlinesPut call TextVimlinesPut()
function! TextVimlinesPut()
  insert
{{{ vim options (Plugin: text, Version: 3)
vim:foldmethod=marker:foldcolumn=4:tw=75:fo=tcroqwa2:ts=3:sw=3:expandtab:ww+=[,]
vim:autoindent:nocindent:nosmartindent
vim:comments=fb\:*,fb\:-,n\:>,b\:#,b\:$
}}}
.
endfunction

command! -nargs=* -complete=custom,s:TextECSComplete TextEnableCodeSnip call TextEnableCodeSnip(<f-args>)
function! TextEnableCodeSnip(filetype,start,end) abort
  try
    let ft=toupper(a:filetype)
    let group='textGroup'.ft
    if exists('b:current_syntax')
      let l:curr_syn=b:current_syntax
      unlet b:current_syntax
    endif
    execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
    execute 'syntax region textSnip'.ft.' matchgroup=textSnip start="'.a:start.'" end="'.a:end.'" contains=@'.group
    hi link textSnip SpecialComment
  finally
    if exists('l:curr_syn')
      let b:current_syntax=l:curr_syn
    elseif exists('b:current_syntax')
      unlet b:current_syntax
    endif
  endtry
endfunction

function! s:TextECSComplete(ArgLead, CmdLine, CursorPos) abort
  let cmd = a:CmdLine
  let cmd = strpart(cmd,0,a:CursorPos)
  let cmd = matchstr(cmd,'\s\+\zs.*')
  if cmd!~'\s'
    " First argument -- subdir name -- expansion
    let r = globpath(&runtimepath,'syntax/*.vim')
    let r = substitute(r,"\\.vim\\ze\\(\n\\|$\\)",'','g')   " Remove .vim
    let r = substitute(r,'[^'."\n".']*[/\\]\ze\w\+','','g') " Remove leading dirs
    return r
  else
    " Second or third argument -- nothing to be expanded
    return ''
  endif
endfunction
