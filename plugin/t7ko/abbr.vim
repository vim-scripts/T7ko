
" File: t7ko/abbr.vim
" Author: Ivan Tishchenko (t7ko AT mail DOT ru)
" Version: 1.1
" Last Modified: June 11, 2005
"
" Purpose: Creating abbreviations.
"
" This file is a part of a multi-purpose plugin set T7ko.  To get more info,
" install this plugin-set and type
"   :help t7ko
" for general info, or
"   :help t7ko--abbr
" for help on this plugin.

command! -bar PlugOutAbbr
  \   delcommand PlugOutAbbr
  \ | delcommand  AbbrEdit
  \ | delcommand  Abbr
  \ | delfunction Abbr
  \ | delfunction s:Abbr1
  \ | delfunction s:Abbr2
  \ | delcommand AbbrAdjectiveI
  \ | delcommand AbbrAdjectiveY
  \ | delcommand AbbrNounIA
  \ | delcommand AbbrNounIJa
  \ | delcommand AbbrNounIIO
  \ | delcommand AbbrNounIIE
  \ | delcommand AbbrNounIIJ
  \ | delcommand AbbrNounIISo
  \ | delcommand AbbrNounIISt
  \ | delcommand AbbrNounIIISo
  \ | delcommand AbbrNounIIISh

if has("win32")
  command! AbbrEdit new <sfile> | execute substitute("autocmd! BufLeave ".<sfile>." so ".<sfile>, '\\\\\ze\S', '/', 'g')
else
  command! AbbrEdit new <sfile> | autocmd! BufLeave <sfile> so <sfile>
endif

" Up to 16 prefixes and up to 16 postfixes are allowed.
command! -nargs=+ Abbr call Abbr(<f-args>)
function! Abbr( prefixes, root, abbr, common, postfixes ) abort
  if a:common=='-'
    execute "call s:Abbr2( a:root         , a:abbr         , a:prefixes, '".substitute(a:postfixes,',',"','",'g')."')"
  else
    execute "call s:Abbr2( a:root.a:common, a:abbr.a:common, a:prefixes, '".substitute(a:postfixes,',',"','",'g')."')"
  endif
endfunction

function! s:Abbr2( root, abbr, prefixes, ... ) abort
  let i=1
  while i <= a:0
    execute "call s:Abbr1( '".a:{i}."', a:root, a:abbr, '".substitute(a:prefixes,',',"','",'g')."')"
    let i=i+1
  endwhile
endfunction

function! s:Abbr1( postfix, root, abbr, ... ) abort
  let i=1
  let postfix=a:postfix
  while i <= a:0
    let ab=a:{i}.a:abbr.postfix
    let mm=a:{i}.a:root.postfix
    execute 'iabbrev '.ab.' '.mm
    let ab=toupper(ab[0]).strpart(ab,1)
    let mm=toupper(mm[0]).strpart(mm,1)
    execute 'iabbrev '.ab.' '.mm
    let i=i+1
  endwhile
endfunction

" Speech Parts

" Adjective (��������������)
command! -nargs=+ AbbrAdjectiveI Abbr <args> ��,��,���,��,��,��,��,���,��,���,��
command! -nargs=+ AbbrAdjectiveY Abbr <args> ��,��,���,��,��,��,��,���,��,���,��

" Nouns (���������������)

" I declension (������ ���������)
" ����
command! -nargs=+ AbbrNounIA    Abbr <args> �,�,�,�,��,,��,���,��
" ���
command! -nargs=+ AbbrNounIJa   Abbr <args> �,�,�,�,��,,��,���,��

" II declension (������ ���������)
" ����
command! -nargs=+ AbbrNounIIO   Abbr <args> �,�,�,��,�,��,���,��
" ����
command! -nargs=+ AbbrNounIIE   Abbr <args> �,�,�,��,��,���,��
" �������
command! -nargs=+ AbbrNounIIJ   Abbr <args> �,�,�,��,�,�,��,��,���,��
" ����
command! -nargs=+ AbbrNounIISo  Abbr <args> �,�,�,��,�,�,��,��,���,��
" ����
command! -nargs=+ AbbrNounIISt  Abbr <args>  ,�,�,��,�,�,��,��,��,���,��

" III declension
" ���
command! -nargs=+ AbbrNounIIISo Abbr <args> �,�,��,���,��
" ����
command! -nargs=+ AbbrNounIIISh Abbr <args> �,�,��,���,��


" Verb (������)
