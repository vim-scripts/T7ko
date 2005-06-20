
" File: t7ko/float.vim
" Author: Ivan Tishchenko (t7ko AT mail DOT ru)
" Version: 1.1
" Last Modified: June 11, 2005
"
" Purpose: Floating-point arithmetics (incomplete).
"
" This file is a part of a multi-purpose plugin set T7ko.  To get more info,
" install this plugin-set and type
"   :help t7ko
" for general info, or
"   :help t7ko--float
" for help on this plugin.

command! -bar PlugOutFloat
  \   delcommand PlugOutFloat
  \ | delfunction FloatQ
  \ | delfunction FloatAssert
  \ | delfunction FloatSimplify
  \ | delfunction FloatIsNegative
  \ | delfunction FloatEqual
  \ | delfunction FloatNegate
  \ | delfunction FloatDecompose
  \ | delfunction FloatRound
  \ | delfunction FloatAdd
  \ | delfunction FloadDis
  \ | delfunction FloatMult
  \ | delfunction FloatDiv

" To switch debug on:
"   execute '%s/"dbg"\_\s\+/"dbg"' . "\<cr>/ge"
" To switch debug off:
"   %s/"dbg"\_\s\+/"dbg" /ge

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FloatQ(a)
  return (a:a =~ '^-\?\d\+\.\?\d*$') || (a:a =~ '^-\?\.\d\+$')
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FloatAssert(a)
  if !FloatQ(a:a)
    throw a:a.' is not a floating point number'
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FloatSimplify(a)
  let res=a:a
  let sn=FloatIsNegative(a:a)
  if sn
    let res=strpart(res,1)
    let sn='-'
  else
    let sn=''
  endif

  if res =~ '\.'
    let res=substitute(res,'0\+$','','')
  endif
  let res=substitute(res,'^0\+','','')
  if res=='' || res=='.'
    return 0
  endif
  let res=substitute(res,'\.$','','')
  return sn.res
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FloatIsNegative(a)
  call FloatAssert(a:a)
  return a:a[0] == '-'
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FloatEqual(a,b)
  return FloatSimplify(a:a)==FloatSimplify(a:b)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FloatNegate(a)
  if FloatIsNegative(a:a)
    return strpart(a:a,1)
  else
    return '-'.a:a
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FloatDecompose(a,p)
  call FloatAssert(a:a)
  let res=a:a
  let letp='let '.a:p

  if res !~ '\.'
    let res=res.'.0'
  endif
  if res =~ '\.$'
    let res=res.'0'
  endif
  let res=substitute(res,'\.',"'|".letp."flt='",'')."'"

  if res[0]=='-'
    let s=-1
    let res=strpart(res,1)
  else
    let s=1
  endif
  if res[0]=="'"
    let res='0'.res
  endif
  let res=letp.'sign='.s.'|'.letp."int='".res

  return res
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FloatRound('11.11', 1) -> 10
" FloatRound('11.11',-1) -> 11.1
" FloatRound('0.5',0) -> 0
" FloatRound('1.5',0) -> 2
function! FloatRound(a,dig)
"dbg" echo 'Round('.a:a.','.a:dig.')'
  execute FloatDecompose(a:a,'')
  if (-a:dig) >= strlen(flt)
    return FloatSimplify(a:a)
  endif
  let res='1'.int.flt
  let dig=strlen(int)-a:dig
  if dig < 0
    return '0'
  endif
"dbg" echo 'dig: ' . dig
  let last = (0+res[dig+1])
  let beg=strpart(res,0,dig+1)
  if last>5 || (last==5 && (0+res[dig])%2)
    " need to increase last digit before zero
    let beg = beg+1
  endif
  let res = beg . substitute(strpart(res,dig+1),'.','0','g')
  let beg = res[0]
  let res = strpart(res,1)
  let il = strlen(int)
  let res = strpart(res,0,il) . '.' . strpart(res,il)
  if beg=='2'
    let res = '1'.res
  endif
  if sign<0
    let res = '-'.res
  endif
  return FloatSimplify(res)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FloatAdd(a,b)
  execute FloatDecompose(a:a,'a')
  execute FloatDecompose(a:b,'b')
"dbg" echo a:a . ' + ' . a:b

  let rsign = asign

  let i = strlen(aflt) - strlen(bflt)
  while i>0
    let bflt=bflt.'0'
    let i=i-1
  endwhile
  while i<0
    let aflt=aflt.'0'
    let i=i+1
  endwhile
"dbg" echo 'flt: ' . aflt . ',' . bflt
  let rflt = ('3'.aflt) + asign*bsign*('1'.bflt)
  let i=strpart(rflt,0,1)
  let rflt = strpart(rflt,1)
"dbg" echo 'i: ' . i
  if i==5
    let rint=1
  elseif i==1
    let rint=-1
  else
    let rint=0
  endif

  let rint = rint + aint + asign*bsign*bint
  if rint < 0
"dbg" echo 'rint,rflt: '.rint.','.rflt
    let rsign = -rsign
    if rflt !~ '[^0]'
      let rint = -rint
    else
      let rint = -1 - rint
      let rflt = '3'.substitute(rflt,'.','0','g') - ('1'.rflt)
      let rflt = strpart(rflt,1)
    endif
  endif

  return FloatSimplify( (rsign>0?'':'-') . rint . '.' . rflt )
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FloadDis(a,b)
  return FloatAdd(a:a,FloatNegate(a:b))
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FloatMult(a,b)
  throw 'is not implemented yet'
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FloatDiv(a,b,precision)
  throw 'is not implemented yet'
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"echo ' --->' . FloatEqual( '3.011' , FloatAdd( '2.001', '1.01' ))
"echo ' --->' . FloatEqual( '0.991' , FloatAdd( '2.001','-1.01' ))
"echo ' --->' . FloatEqual('-0.009' , FloatAdd( '1.001','-1.01' ))
"echo ' --->' . FloatEqual( '3.011' , FloatAdd( '1.01' , '2.001'))
"echo ' --->' . FloatEqual( '0.991' , FloatAdd('-1.01' , '2.001'))
"echo ' --->' . FloatEqual('-0.009' , FloatAdd('-1.01' , '1.001'))

"echo FloatRound('11.11', -3)
"echo FloatRound('11.11', -2)
"echo FloatRound('11.11', -1)
"echo FloatRound('11.11', -0)
"echo FloatRound('11.11',  1)
"echo FloatRound('11.11',  2)
"echo FloatRound('11.11',  3)
"echo FloatRound('0.5', 0)
"echo FloatRound('1.5', 0)
"echo FloatRound('-0.5', 0)
"echo FloatRound('-1.5', 0)
