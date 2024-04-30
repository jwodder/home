" https://vi.stackexchange.com/a/31647/1044

if did_filetype()
    finish
endif

if getline(1) =~ '^#!/usr/bin/env pipx run'
    setf python
endif
