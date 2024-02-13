setl com+=fb:- nosi tw=79

if get(b:, 'ale_enabled', g:ale_enabled)
    " Remove %linter% from global echo msg format:
    let b:ale_echo_msg_format = '%code: %%s'
endif
