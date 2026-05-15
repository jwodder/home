[ -n "$PS1" ] || return

export GPG_TTY="$(tty)"

alias tmuxup='tmux new-session -A -s main'
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
     then eval "$(TERM=xterm-256color dircolors -b ~/.dircolors)"
     else eval "$(TERM=xterm-256color dircolors -b)"
     fi
fi

{%@@ endif @@%}
function show_exit_status {
    CHILD_ERROR="${?:-0}"
    [ "$CHILD_ERROR" = 0 ] || printf '\033[1;31m[%d]\033[0m\n' "$CHILD_ERROR"
}

function show_my_ps1 {
{%@@ if profile == "macOS" @@%}
    PS1="$(jwodder-ps1 --no-hostname "$PS1_GIT")"
{%@@ else @@%}
    PS1="$(jwodder-ps1 "$PS1_GIT")"
{%@@ endif @@%}
}

PS1_GIT=on
PROMPT_COMMAND="show_exit_status; $HOME/share/project-as-title.py; show_my_ps1"

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

if _have_command pipx && [ -f "$HOME/.local/bin/virtualenvwrapper.sh" ]
then pipx_local_venvs="$(pipx environment -V PIPX_LOCAL_VENVS)"
     WORKON_HOME="$HOME/.local/virtualenvwrapper/venvs"
     VIRTUALENVWRAPPER_HOOK_DIR="$HOME/.local/virtualenvwrapper/scripts"
     VIRTUALENVWRAPPER_PYTHON="$pipx_local_venvs/virtualenvwrapper/bin/python"
     VIRTUALENVWRAPPER_VIRTUALENV="$pipx_local_venvs/virtualenvwrapper/bin/virtualenv"
     VIRTUALENVWRAPPER_WORKON_CD=0
     . "$HOME/.local/bin/virtualenvwrapper.sh"
     alias mktmpenv='mktmpenv --prompt TMP'
fi
{%@@ if profile == "arch" or profile == "arch-mail" @@%}

if [ -f /usr/share/doc/pkgfile/command-not-found.bash ]
then . /usr/share/doc/pkgfile/command-not-found.bash
fi
{%@@ endif @@%}
{%@@ if profile != "macOS" @@%}

if ! pgrep -u "$USER" ssh-agent > /dev/null
then ssh-agent -t 30m -s > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [ ! -f "$SSH_AUTH_SOCK" ]
then . "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi
{%@@ endif @@%}
