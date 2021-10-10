[ -n "$PS1" ] || return

export GPG_TTY="$(tty)"

alias ls='LC_ALL=C.UTF-8 ls'
alias sort='LC_ALL=C.UTF-8 sort'
alias tree="LC_ALL=C.UTF-8 tree -aF -I '__pycache__|.git|venv|.nox|.tox|*.egg-info|.cache' --matchdirs --noreport"

case "$(uname)" in
    Darwin) alias toc='ls -ACFG'
            PS1='\d \w\$ '
            ;;
         *) alias toc='ls -ACF --color'
            PS1='\u@\h:\w\$ '
            # TODO: Is it even necessary to set this?
            BASH_COMPLETION_COMPAT_DIR=/etc/bash_completion.d
            ;;
esac

shopt -s checkwinsize globstar histappend no_empty_cmd_completion progcomp
#shopt -s failglob  # Not supported by bash-completion
set -o ignoreeof -o pipefail

HISTCONTROL=ignoredups
HISTSIZE=1000
HISTFILESIZE=2000

function _have_command {
    command -V "$1" >/dev/null 2>&1
}

if _have_command lesspipe
then eval "$(lesspipe)"
elif _have_command lesspipe.sh  # Homebrew
then eval "$(lesspipe.sh)"
fi

if _have_command dircolors
then if [ -r ~/.dircolors ]
     then eval "$(dircolors -b ~/.dircolors)"
     else eval "$(dircolors -b)"
     fi
fi

function show_exit_status {
    CHILD_ERROR="${?:-0}"
    [ "$CHILD_ERROR" = 0 ] || printf '\033[1;31m[%d]\033[0m\n' "$CHILD_ERROR"
}

PROMPT_COMMAND=show_exit_status
if [ -e "$HOME/share/ps1.py" ]
then PS1_GIT=on
     PROMPT_COMMAND="$PROMPT_COMMAND"'; PS1="$(python3 ~/share/ps1.py "$PS1_GIT")"'
fi

for compfile in /usr/local/share/bash-completion/bash_completion \
                /usr/share/bash-completion/bash_completion \
                /etc/bash_completion
do if [ -r "$compfile" ]
   then . "$compfile"
        break
   fi
done

if venvwrappath="$(type -p virtualenvwrapper.sh)"
then WORKON_HOME="$HOME/.local/virtualenvwrapper/venvs"
     VIRTUALENVWRAPPER_HOOK_DIR="$HOME/.local/virtualenvwrapper/scripts"
     VIRTUALENVWRAPPER_PYTHON="$(type -p python3)"
     VIRTUALENVWRAPPER_WORKON_CD=0
     . "$venvwrappath"
fi
