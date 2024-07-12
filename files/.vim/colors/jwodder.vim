" References:
"  :help cterm-colors
"  :help group-name
"  :help highlight-groups
"  $VIMRUNTIME/colors/README.txt

highlight clear Normal
set bg&
highlight clear

if exists("syntax_on")
    syntax reset
endif

let g:colors_name="jwodder"

" Common syntax highlighting groups to leave at the default values:
"hi Comment
"hi Statement
"hi PreProc
"hi Underlined
"hi Ignore
"hi Error
"hi Todo

if &bg == "light"

    " Black-on-white
    hi Boolean ctermfg=DarkGreen
    hi Constant ctermfg=DarkGreen
    hi Function ctermfg=DarkRed
    hi Identifier ctermfg=DarkGreen
    hi Number ctermfg=DarkRed
    hi Operator ctermfg=DarkRed
    hi Special ctermfg=DarkRed
    hi String ctermfg=DarkBlue
    hi Type ctermfg=DarkGreen

    hi markdownCode ctermfg=DarkGreen

else

    " White-on-black
    hi Boolean ctermfg=Green
    hi Constant ctermfg=Green
    hi Function ctermfg=Red
    hi Identifier cterm=NONE ctermfg=Green
    hi Number ctermfg=Red
    hi Operator ctermfg=Red
    hi Special ctermfg=Red
    hi String ctermfg=Cyan
    hi Type ctermfg=Green

    hi markdownCode ctermfg=Green

endif

hi link Structure Label

hi link diffAdded Type
hi link diffNewFile diffAdded
hi link diffOldFile diffRemoved

hi link jsonNull Identifier

hi link pythonBuiltin Identifier

hi htmlItalic cterm=underline

hi rstEmphasis cterm=underline

hi csvCol1 ctermfg=DarkRed
hi csvCol2 ctermfg=DarkGreen
hi csvCol3 ctermfg=DarkYellow
hi csvCol4 ctermfg=DarkBlue
hi csvCol5 ctermfg=DarkMagenta
hi csvCol6 ctermfg=DarkCyan
hi csvCol7 ctermfg=Red
hi csvCol8 ctermfg=Blue
