" Vim syntax file
" Language:		RFC 822-style headers

" Quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn spell toplevel

syn match headerName "\v^(\w|-)+:($| )@="
syn match headerURL contains=@NoSpell `\v<(((https?|ftp|gopher)://|(mailto|file|news):)[^' \t<>"]+|(www|web|w3)[a-z0-9_-]*\.[a-z0-9._-]+\.[^' \t<>"]+)[a-z0-9/]`
syn match headerComment "#.*$"

hi def link headerName Type
hi def link headerURL String
hi def link headerComment Comment

let b:current_syntax = "headers"

let &cpo = s:cpo_save
unlet s:cpo_save
