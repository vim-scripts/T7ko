
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

" Adjective (прилагательное)
command! -nargs=+ AbbrAdjectiveI Abbr <args> ий,им,ими,ие,ая,ой,ое,ому,ом,ого,ую
command! -nargs=+ AbbrAdjectiveY Abbr <args> ый,ым,ыми,ые,ая,ой,ое,ому,ом,ого,ую

" Nouns (существительные)

" I declension (первое склонение)
" мама
command! -nargs=+ AbbrNounIA    Abbr <args> а,ы,е,у,ой,,ам,ами,ах
" тётя
command! -nargs=+ AbbrNounIJa   Abbr <args> я,и,е,ю,ей,,ям,ями,ях

" II declension (второе склонение)
" утро
command! -nargs=+ AbbrNounIIO   Abbr <args> о,а,у,ом,е,ам,ами,ах
" поле
command! -nargs=+ AbbrNounIIE   Abbr <args> е,я,ю,ем,ям,ями,ях
" обалдуй
command! -nargs=+ AbbrNounIIJ   Abbr <args> й,я,ю,ем,е,и,ев,ям,ями,ях
" конь
command! -nargs=+ AbbrNounIISo  Abbr <args> ь,я,ю,ём,е,и,ей,ям,ями,ях
" стол
command! -nargs=+ AbbrNounIISt  Abbr <args>  ,а,у,ом,е,ы,ов,ев,ам,ами,ах

" III declension
" ель
command! -nargs=+ AbbrNounIIISo Abbr <args> ь,и,ей,ями,ях
" мышь
command! -nargs=+ AbbrNounIIISh Abbr <args> ь,и,ей,ами,ах


" Verb (глагол)
