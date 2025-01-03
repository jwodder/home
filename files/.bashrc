[ -n "$PS1" ] || return

export GPG_TTY="$(tty)"

{%@@ if profile == "macOS" @@%}
alias toc='ls -ACFG'
{%@@ else @@%}
alias toc='ls -ACF --color'
{%@@ endif @@%}
alias tree="tree -aF -I '*.egg-info|.cache|.git|.mypy_cache|.nox|.tox|__pycache__|_build|build|target|venv' --matchdirs --noreport"

shopt -s checkwinsize direxpand globstar histappend no_empty_cmd_completion
shopt -s progcomp
set -o ignoreeof -o pipefail

HISTCONTROL=ignoredups
HISTSIZE=1000
HISTFILESIZE=2000

function _have_command {
    command -V "$1" >/dev/null 2>&1
}

if _have_command lesspipe
then eval "$(lesspipe)"
fi

{%@@ if profile != "macOS" @@%}
if _have_command dircolors
then if [ -r ~/.dircolors ]
     then eval "$(dircolors -b ~/.dircolors)"
     else eval "$(dircolors -b)"
     fi
fi

{%@@ endif @@%}
function show_exit_status {
    CHILD_ERROR="${?:-0}"
    [ "$CHILD_ERROR" = 0 ] || printf '\033[1;31m[%d]\033[0m\n' "$CHILD_ERROR"
}

function show_my_ps1 {
{%@@ if profile == "macOS" @@%}
    PS1="$(jwodder-ps1 --no-hostname --theme light "$PS1_GIT")"
{%@@ else @@%}
    PS1="$(jwodder-ps1 "$PS1_GIT")"
{%@@ endif @@%}
}

PS1_GIT=on
PROMPT_COMMAND="show_exit_status; show_my_ps1"

{%@@ if profile != "macOS" @@%}
# TODO: Is it even necessary to set this?
BASH_COMPLETION_COMPAT_DIR=/etc/bash_completion.d
{%@@ endif @@%}
for compfile in /usr/local/share/bash-completion/bash_completion \
                /usr/share/bash-completion/bash_completion \
                /etc/bash_completion
do if [ -r "$compfile" ]
   then . "$compfile"
        break
   fi
done

venvwrappath="$(type -p virtualenvwrapper.sh)"
_apt_venvwrappath=/usr/share/virtualenvwrapper/virtualenvwrapper.sh
if [ -z "$venvwrappath" ] && [ -f "$_apt_venvwrappath" ]
then venvwrappath="$_apt_venvwrappath"
fi
if [ -n "$venvwrappath" ]
then WORKON_HOME="$HOME/.local/virtualenvwrapper/venvs"
     VIRTUALENVWRAPPER_HOOK_DIR="$HOME/.local/virtualenvwrapper/scripts"
     VIRTUALENVWRAPPER_PYTHON="$(type -p python3)"
     VIRTUALENVWRAPPER_WORKON_CD=0
     . "$venvwrappath"
     alias mktmpenv='mktmpenv --prompt TMP'
fi
