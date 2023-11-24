setl com^=b:#:,n:#

if get(b:, 'ale_enabled', g:ale_enabled)
    let s:projdir = ale#python#FindProjectRootIni(bufnr(''))
    if !empty(s:projdir)
        if filereadable(s:projdir . '/.tox/typing/bin/mypy')
            let b:ale_python_mypy_executable = s:projdir . '/.tox/typing/bin/mypy'
        endif
    else
        let s:cfgfile = expand('~/share/pylinting.cfg')
        let b:ale_python_flake8_options = '--config=' . s:cfgfile
        let b:ale_python_isort_options = '--settings=' . s:cfgfile
        let b:ale_python_mypy_options = '--config-file=' . s:cfgfile
    endif
endif
