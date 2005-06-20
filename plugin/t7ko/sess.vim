
" File: t7ko/sess.vim
" Author: Ivan Tishchenko (t7ko AT mail DOT ru)
" Version: 1.1
" Last Modified: June 11, 2005
"
" Purpose: Vimsession utilization.
"
" This file is a part of a multi-purpose plugin set T7ko.  To get more info,
" install this plugin-set and type
"   :help t7ko
" for general info, or
"   :help t7ko--sess
" for help on this plugin.

" vim: foldmethod=marker foldcolumn=2

command! -bar PlugOutSess
  \   delcommand  PlugOutSess
  \ | delfunction SessExtraFname
  \ | delfunction SessSave
  \ | delcommand  SessSave
  \ | delfunction SessExtraOpen
  \ | delcommand  SessExtraOpen
  \ | delcommand  SessExtraReread
  \ | delfunction SessOSSwitch
  \ | delcommand  SessOSSwitch
  \ | execute "autocmd! SessAuGroup"
  \ | execute "augroup! SessAuGroup"
  \ | unmap <c-z>l


nmap <c-z>l :SessSave<cr>

command! -bar SessSave call SessSave()
function! SessSave() abort
  if v:this_session==""
    echoerr "There is no loaded session"
    return
  endif
  if 2==confirm('Save session '.v:this_session.'?',"&No\n&Yes",1)
    exe 'mksession! '.v:this_session
    call confirm('Session '.v:this_session.' saved.','&Ok',1)
  endif
endfunction

function! SessExtraFname() abort
  if v:this_session==""
    echoerr "There is no loaded session"
  endif
  return substitute(v:this_session,'\.[^.]*$','x.vim','')
endfunction

command! -bar SessExtraReread exe 'source' SessExtraFname()
command! -bar SessExtraOpen call SessExtraOpen()
function! SessExtraOpen() abort
  exe 'new' SessExtraFname()
  try
    augroup SessAuGroup
    autocmd!
    let fn=SessExtraFname()
    if has("win32")
      let fn=substitute(fn,'\\\ze\S','/','g')
    endif
    execute "autocmd BufLeave ".fn." source ".fn
  finally
    augroup END
  endtry
endfunction

" Helps saving vimsession for different platforms in different files.
" Usage.
" 1. Create session-file.
" 2. Determ which feature of Vim identifies your platform (see 'help has()').
"    For example, if you're running on Windows, your feature is "win32", if on
"    Linux -- "unix".
" 3. Move your <session-name>.vimsession to <session-name>.OS-<feature>.
" 4. Create file <session-name>.vimsession, which will contain two lines:
"      PlugInSess
"      SessOSSwitch
" After you create those files for different platforms, you may start your
" session by starting main-file <session-name>.vimsession.  It will load
" appropriate file itself.  NOTE, that:
" 1. Session-extra is still loaded for each of those files.
" 2. All function listed in this file still work well.
"
command! -bar SessOSSwitch call SessOSSwitch(expand('<sfile>:p:r'))
function! SessOSSwitch(session) abort
  let variants=glob(a:session.'.OS-*')
  while 0<strlen(variants)
    let v = matchstr(variants,'^.\{-}\(\ze\n\|$\)')
    let variants = strpart(variants,strlen(v)+1)
    let os = matchstr(v,'.*\.OS-\zs.*\ze')
    if has(os)
      execute 'source' v
      return
    endif
  endwhile
  echoerr "Session-file for this platform is not found"
endfunction
