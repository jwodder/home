" Configuration for mgedmin/coverage-highlight.vim

map gc :ToggleCoverage<CR>
map gp :PrevUncovered<CR>
map gn :NextUncovered<CR>

" So as not to conflict with the error highlight for Ale:
hi NoCoverage ctermbg=11
