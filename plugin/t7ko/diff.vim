
" File: t7ko/diff.vim
" Author: Ivan Tishchenko (t7ko AT mail DOT ru)
" Version: 1.1
" Last Modified: June 11, 2005
"
" Purpose: Performing diff on directories.
"
" This file is a part of a multi-purpose plugin set T7ko.  To get more info,
" install this plugin-set and type
"   :help t7ko
" for general info, or
"   :help t7ko--diff
" for help on this plugin.

command! -bar PlugOutDiff
  \   delcommand PlugOutDiff
  \ | call delete(g:DiffTmpName)
  \ | unlet g:DiffPrg
  \ | unlet g:DiffTmpName
  \ | delcommand  Diff
  \ | delcommand  DiffOpen
  \ | delfunction Diff
  \ | delfunction <SID>DiffDoOpen
  \ | delfunction <SID>DiffDoRem
  \ | delfunction <SID>DiffDoCopy
  \ | delfunction <SID>DiffDoDiff
  \ | delfunction <SID>DiffDoUpdate

if 1==executable('diff')
  let g:DiffPrg='diff'
elseif has("win32")
  let g:DiffPrg='"'.$VIMRUNTIME.'\diff.exe"'
else
  echoerr "Cannot find 'diff' executable!"
endif

let g:DiffTmpName=''

command! -nargs=* -complete=file Diff call Diff(<f-args>)

command! -bar DiffOpen execute 'new' g:DiffTmpName

function! Diff(dir_local,dir_remote)
  if     has("win32") | let slash='\' | let notslash='[^\\]'
  elseif has("unix" ) | let slash='/' | let notslash='[^/]'
  endif

  let rex='\(\/$\|\\\+$\|[^\\]\@<=\%(\\\\\)*\\ \@=\)'
  let dir_local =substitute(a:dir_local ,rex,'','g')
  let dir_remote=substitute(a:dir_remote,rex,'','g')

  let rex='[][.\\$*/]'
  let rex_local =substitute(dir_local ,rex,'\\&','g')
  let rex_remote=substitute(dir_remote,rex,'\\&','g')

  if !isdirectory(dir_local)
    echoerr 'Local dir '.dir_local.' does not exists.'
    return
  endif
  if !isdirectory(dir_remote)
    echoerr 'Remote dir '.dir_remote.' does not exists.'
    return
  endif
  new
  only
  let cmd=g:DiffPrg.' --recursive --brief "'.dir_local.'" "'.dir_remote.'"'
  if has("win32") | let cmd='"'.cmd.'"' | endif
  execute 'read !'.cmd
  normal ggdd

  " removing leading local/remote directories
  " 'Only in <localdir>'
  if has("win32") | let rex='\S\+\s\+\S\+\s\+'.tolower(rex_local) .'\(.*\): \c'
  else            | let rex='\S\+\s\+\S\+\s\+'.        rex_local  .'\(.*\): '
  endif
  execute '%s/'.rex.'/ > \1\'.slash.'/e'
  " 'Only in <remotedir>'
  if has("win32") | let rex='\S\+\s\+\S\+\s\+'.tolower(rex_remote).'\(.*\): \c'
  else            | let rex='\S\+\s\+\S\+\s\+'.        rex_remote .'\(.*\): '
  endif
  execute '%s/'.rex.'/<  \1\'.slash.'/e'
  " 'Files <localdir>/file and <remotedir>/file differ'
  if has("win32") | let rex='\S\+\s\+'.tolower(rex_local).'\(.*\)\s\+\S\+\s\+'.tolower(rex_remote).'\1\s\+\S\+\c'
  else            | let rex='\S\+\s\+'.        rex_local .'\(.*\)\s\+\S\+\s\+'.        rex_remote .'\1\s\+\S\+'
  endif
  execute '%s/'.rex.'/<> \1/e'

  " creating entries for directories
  let i=1
  let curdir=slash
  while i<=line('$')
    let s=strpart(getline(i),3)
    let basedir=substitute(s,notslash.'\+\'.slash.'\?$','','')
    if basedir==curdir
      let i=i+1
      continue
    endif
    let comdir=slash
    let tcd=strpart(curdir ,1)
    let tbd=strpart(basedir,1)
    let creating=0
    while 0<strlen(tbd)
      let tbdd=strpart(tbd,0,match(tbd,'\'.slash)+1)
      let tbd=strpart(tbd,strlen(tbdd))
      let comdir=comdir.tbdd
      if creating==0
        let tcdd=strpart(tcd,0,match(tcd,'\'.slash)+1)
        let tcd=strpart(tcd,strlen(tcdd))
        if tcdd==tbdd
          continue
        endif
        let creating=1
      endif
      call append(i-1,'   '.comdir)
      let i=i+1
    endwhile
    let curdir=comdir.slash
    let i=i+1
  endwhile

  " adding trailing slashes to dirnames
  let i=0
  while i<line('$')
    let i=i+1
    let name=strpart(getline(i),3)
    if slash==strpart(name,strlen(name)-1)
      continue
    endif
    if isdirectory(dir_local.name) || isdirectory(dir_remote.name)
      call setline(i,getline(i).slash)
    endif
  endwhile

  setlocal foldcolumn=8 foldmethod=manual
  setlocal foldtext='--\ '.strpart(getline(v:foldstart),3).'\ ('.(1+v:foldend-v:foldstart).'\ lines)'
  let i=1
  while i<=line('$')
    let str=getline(i)
    if -1<match(str,'\'.slash.'$')
      let str=substitute(str,'^'.notslash.'*','','')
      let str=substitute(str,'[\/?]','\\&','g')
      execute i.',1?\V'.str.'?fold'
      normal zR
    endif
    let i=i+1
  endwhile

  " Adding lines with dir-names
  normal ggOLocal dir is  =dir_localRemote dir is =dir_remote

  " Setting up mappings to manage diffs
  let b:dir_local =dir_local
  let b:dir_remote=dir_remote
  nmap <buffer> <c-q>o :call <SID>DiffDoOpen()<cr>
  nmap <buffer> <c-q>c :call <SID>DiffDoCopy()<cr>
  nmap <buffer> <c-q>r :call <SID>DiffDoRem()<cr>
  nmap <buffer> <c-q>d :call <SID>DiffDoDiff()<cr>
  nmap <buffer> <c-q>u :call <SID>DiffDoUpdate()<cr>

  " Saving buffer to file
  if g:DiffTmpName==''
    let g:DiffTmpName=tempname()
  endif
  execute 'saveas! '.g:DiffTmpName
endfunction

function! <SID>DiffDoOpen()
  let cmd=strpart(getline('.'),0,2)
  if cmd!='< ' && cmd!=' >'
    echoerr 'No file to be opened in this line'
    return
  endif
  let name=strpart(getline('.'),3)
  if cmd=='< ' | let name=b:dir_remote.name
  else         | let name=b:dir_local .name
  endif
  exe 'new '.name
endfunction

function! <SID>DiffDoRem() abort
  let cmd=strpart(getline('.'),0,2)
  if cmd!='< ' && cmd!=' >'
    echoerr 'No file to be removed in this line'
    return
  endif
  let name=strpart(getline('.'),3)
  if cmd=='< ' | let srcname=b:dir_remote.name
  else         | let srcname=b:dir_local .name
  endif
  if 1==confirm('Remove '.srcname.'?',"&No\n&Yes",1)
    return
  endif
  if isdirectory(srcname)
    execute '!rmdir "'.srcname.'"'
    echomsg 'Directory '.srcname.' removed'
  else
    call delete(srcname)
    if filereadable(srcname)
      echoerr "Deletion of" srcname "failed."
    else
      echomsg 'File '.name.' removed'
    endif
  endif
endfunction

function! <SID>DiffDoCopy() abort
  let cmd=strpart(getline('.'),0,2)
  if cmd!='< ' && cmd!=' >'
    echoerr 'No file to be copied in this line'
    return
  endif
  let name=strpart(getline('.'),3)
  if cmd=='< ' | let srcname=b:dir_remote.name | let dstdir=b:dir_local
  else         | let srcname=b:dir_local .name | let dstdir=b:dir_remote
  endif
  if isdirectory(srcname)
    execute '!mkdir "'.dstdir.name.'"'
    echomsg 'Directory '.dstdir.name.' created'
  else
    if     has("win32") | let cmd='copy'
    elseif has("unix" ) | let cmd='cp'
    endif
    execute '!'.cmd.' "'.srcname.'" "'.dstdir.name.'"'
    echomsg 'File '.strpart(name,1).' copied to '.dstdir
  endif
endfunction

function! <SID>DiffDoDiff()
  let cmd=strpart(getline('.'),0,2)
  if cmd!='<>'
    echoerr 'No files to be "diff"ed in this line'
    return
  endif
  let name=strpart(getline('.'),3)
  let localname =substitute(b:dir_local.name ,' ','\ ','g')
  let remotename=substitute(b:dir_remote.name,' ','\ ','g')
  execute 'new '.localname
  only
  execute 'vert botr diffsplit '.remotename
endfunction

function! <SID>DiffDoUpdate()
  let ln=b:dir_local
  let rn=b:dir_remote
  new | only
  call Diff(ln,rn)
endfunction
