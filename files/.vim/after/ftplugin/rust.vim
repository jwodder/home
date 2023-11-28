setl com+=fb:- tw=79

if get(b:, 'ale_enabled', g:ale_enabled)
    " Remove %linter% from global echo msg format:
    let b:ale_echo_msg_format = '%code: %%s'

    " Display a '@' after the ruler if rust-analyzer hasn't finished an initial
    " sweep.  Unfortunately, the only way to update the ruler seems to be by
    " moving the cursor.  Putting this in the statusline instead doesn't help.
    setl ruf+=%{getbufvar(bufnr(''),'ale_linted',0)==0?'\ @':''}
endif
