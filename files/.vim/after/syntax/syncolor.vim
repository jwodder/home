" This goes in ~/.vim/after/ so that it will take effect after Vim sets &bg,
" which apparently happens after the .vimrc is processed.

if &bg == "light"
    hi Boolean ctermfg=DarkGreen
    hi Constant ctermfg=DarkGreen
    hi Function ctermfg=DarkRed
    hi Identifier ctermfg=DarkGreen
    hi Number ctermfg=DarkRed
    hi Operator ctermfg=DarkRed
    hi Special ctermfg=DarkRed
    hi String ctermfg=DarkBlue
    hi markdownCode ctermfg=DarkGreen
else
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
