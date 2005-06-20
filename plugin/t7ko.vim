
" File: t7ko.vim
" Author: Ivan Tishchenko (t7ko AT mail DOT ru)
" Version: 1.1
" Last Modified: June 11, 2005
"
" Purpose: T7ko-plugins management.
"
" This file is a part of a multi-purpose plugins-set T7ko.  To get more info,
" install this plugin-set and type
"   :help t7ko"
" for general info, or
"   :help t7ko-plugins
" for help on commands and functions of this file.

let T7KOdir=expand('<sfile>:p:r')

function! Plugged(plugin) abort
	if 0==strlen(a:plugin)
		return 0
	endif
	let f=a:plugin
	let f=substitute(f,'^.',toupper(f[0]),'')
	let f=':PlugOut'.f
	return 2==exists(f)
endfunction

command! -nargs=+ -complete=custom,s:PlugInCompletion PlugInRequire call PlugInRequire(<f-args>)
function! PlugInRequire(...) abort
  let i=1
  while i<=a:0
    let plugin=a:{i}
    let i=i+1
    if !Plugged(plugin)
      call PlugIn(plugin)
    endif
  endwhile
endfunction

command! -nargs=+ -complete=custom,s:PlugInCompletion PlugIn call PlugIn(<f-args>)

function! s:PlugInCompletion(ArgLead,CmdLine,CursorPos)
	let files=glob(g:T7KOdir.'/*.vim')
	return substitute(files,'\f\+[\\/]\([^\\/]\+\)\.vim','\1','g')
endfunction

function! PlugIn(...)
	let i = 1
	while i<=a:0
		let plugin=a:{i}
		if Plugged(plugin)
			echoerr "Plugin" plugin "is already plugged in."
		else
			exe 'source' g:T7KOdir.'/'.plugin.'.vim'
		endif
		let i=i+1
	endwhile
endfunction

command! -nargs=+ -complete=custom,s:PlugOutCompletion PlugOut call PlugOut(<f-args>)

function! s:PlugOutCompletion(ArgLead,CmdLine,CursorPos)
	let files   = glob(g:T7KOdir.'/*.vim')
	let plugins = substitute(files,'\f\+[\\/]\([^\\/]\+\)\.vim','\1','g')
	let plugged = ''
	let p=0
	while p<strlen(plugins)
		let f=matchstr(plugins,'\w\+',p)
		if Plugged(f)
			if 0<strlen(plugged)
				let plugged = plugged . "\n"
			endif
			let plugged = plugged . f
		endif
		let p=match(plugins,"\n",p)
		if p<0 | let p=strlen(plugins) | endif
		let p=p+1
	endwhile
	return plugged
endfunction

function! PlugOut(...)
	let i = 1
	while i<=a:0
		let f=a:{i}
		if !Plugged(f)
			echoerr "Plugin" f "is not plugged in."
		else
			let f=substitute(f,'^.',toupper(f[0]),'')
			let f='PlugOut'.f
			exe f
		endif
		let i=i+1
	endwhile
endfunction
