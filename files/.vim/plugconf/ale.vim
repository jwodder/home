" Configuration for dense-analysis/ale

let g:ale_fixers = {
\   'python': ['black', 'isort'],
\   'rust': ['rustfmt'],
\}

let g:ale_linters = {
\   'python': ['flake8', 'mypy'],
\   'rust': ['analyzer'],
\}

let g:ale_completion_enabled = 1
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:ale_fix_on_save = 1
let g:ale_hover_to_preview = 1
let g:ale_linters_explicit = 1
let g:ale_rust_rustfmt_options = '--edition 2021'
let g:ale_virtualtext_cursor = 0

let g:ale_set_signs = 0
hi link ALEErrorLine SpellBad
hi link ALEWarningLine SpellCap
hi link ALEInfoLine ALEWarningLine

nmap !h :1messages<CR>
nmap !i <Plug>(ale_hover)
nmap !? <Plug>(ale_detail)
nmap !p <Plug>(ale_previous_wrap)
nmap !n <Plug>(ale_next_wrap)
nmap !D <Plug>(ale_go_to_definition_in_split)
nmap !R <Plug>(ale_find_references)
nmap !. <CursorHold>

" <https://rust-analyzer.github.io/manual.html#configuration>
let g:ale_rust_analyzer_config = {
\   'assist': {
\       'expressionFillDefault': 'todo!()',
\   },
\   'cargo': {
\       'features': 'all',
\   },
\   'hover': {
\       'memoryLayout': {
\           'enable': v:false,
\       },
\   },
\   'imports': {
\       'granularity': {
\           'group': 'module',
\       },
\       'group': {
\           'enable': v:false,
\       },
\       'prefix': 'self',
\   },
\}

" Display a '@' after the ruler if rust-analyzer hasn't finished an initial
" sweep.  Unfortunately, the only way to update the ruler seems to be by
" moving the cursor.  Putting this in the statusline instead doesn't help.
function JTW_rust_analyzer_sigil()
    if &ft == "rust"
        \ && get(b:, 'ale_enabled', g:ale_enabled)
        \ && getbufvar(bufnr(''), 'ale_linted', 0) == 0
        return ' @'
    else
        return ''
    endif
endfunc
set ruf+=%{JTW_rust_analyzer_sigil()}
