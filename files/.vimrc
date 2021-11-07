set spl=en sps=best,13 spc= spf=~/share/spell/words.utf-8.add
{%@@ for spf in extra_spellfiles() @@%}
set spf+=~/share/spell/{{@@ spf @@}}
{%@@ endfor @@%}

set flp=\\v^\\s*[[(]?(\\d+\|\\a\|[IiVvXxLlCcDdMm]+)[]:.)]\\s+
set com^=s1:#\|,mb:\|,ex:\|#,b:--,b:#:,n:# com+=b:!,b:\",b:;,bf:..,b:\\
set ai bs=2 cm=blowfish2 cpo+=M enc=utf-8 et fcl=all fo+=jn ic
set lcs+=nbsp:~,tab:‣‧,trail:‧ ml mls=1 mps+=<:> nf-=octal ru ruf=%l:%c sc scs
set scl=no sts=4 sw=1 ttm=100 ttimeout ww=h,l,[,]
{%@@ if profile != "macOS" @@%}
set bg=dark
{%@@ endif @@%}

au BufNewFile,BufRead *.{bh,tsv,txt} setl noet sts=0
au BufNewFile,BufRead *.{yml,yaml}   setl sts=2
au BufNewFile,BufRead Makefile       setl noet sts=0
au BufReadCmd         *.whl          call zip#Browse(expand("<amatch>"))
au BufWinEnter * if getfsize(expand("%")) > 1024*1024 | syntax clear | endif

dig uh 601 y- 563 Y- 562 zh 658 sh 643 dh 240 DH 208 !? 8253 :: 776
dig ^1 185 ^2 178 ^3 179 ^4 8308 ^5 8309 ^6 8310 ^7 8311 ^8 8312 ^9 8313 ^0 8304
dig ^n 8319 ^+ 8314 ^- 8315
dig _1 8321 _2 8322 _3 8323 _4 8324 _5 8325 _6 8326 _7 8327 _8 8328 _9 8329
dig _0 8320 _+ 8330 _- 8331
dig NN 8469 ZZ 8484 QQ 8474 RR 8477 CC 8450 HH 8461 PP 8473 PW 119979
dig && 8743 \|\| 8744 !! 172 ^^ 8853 (< 10216 >) 10217 (/ 8713 x\| 8906
dig NE 8708 ~= 8773 ~~ 8776 T^ 8868 \|- 8866 v\| 8595 ^\| 8593 \\ 8726 dx 10799
dig _. 8228 .. 8230 )< 8828

map S 24k
map s 24j
map W <C-W>w
map \- :exe "normal " . (81-col("$")) . "A-\e"<CR>
map \= :exe "normal " . (81-col("$")) . "A=\e"<CR>
cmap <C-A> <C-B>
map gB :%!black -q -<CR>
map gI :%!isort -q -<CR>
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>

let loaded_matchparen=1
syntax on

" Printing options:
set penc=utf-8 pheader=%<%t%=[Page\ %N]
set popt=syntax:n,formfeed:y,wrap:y,duplex:off,bottom:10pc

if &bg == "light"
    hi Identifier ctermfg=DarkGreen
    hi String ctermfg=DarkBlue
else
    hi Identifier cterm=NONE ctermfg=121
endif
hi link Structure Label
hi link diffAdded Type
hi link diffNewFile diffAdded
hi link diffOldFile diffRemoved
hi link jsonNull Identifier
hi link pythonBuiltin Identifier
hi Boolean ctermfg=DarkGreen
hi Constant ctermfg=DarkGreen
hi Function ctermfg=DarkRed
hi Number ctermfg=DarkRed
hi Operator ctermfg=DarkRed
hi Special ctermfg=DarkRed
hi htmlItalic cterm=underline
hi markdownCode ctermfg=DarkGreen
hi rstEmphasis cterm=underline

command -nargs=1 Sp :sp `=system("pim -l " . shellescape(<q-args>))`

if empty(glob('~/.vim/autoload/plug.vim'))
  silent execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'cespare/vim-toml', { 'branch': 'main' }
Plug 'junegunn/vim-plug'
Plug 'knatsakis/deb.vim'
Plug 'mgedmin/coverage-highlight.vim'
Plug 'ntpeters/vim-better-whitespace'
call plug#end()
filetype plugin indent off

map gc :ToggleCoverage<CR>
map gp :PrevUncovered<CR>
map gn :NextUncovered<CR>

" Show syntax highlighting groups for word under cursor
" <https://stackoverflow.com/a/7893500/744178>
nmap gs :call <SID>SynStack()<CR>
function! <SID>SynStack()
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
