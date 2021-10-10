[ -t 0 ] && mesg n
umask 0022

export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export PATH="$PATH:$HOME/bin:$HOME/.local/bin"
export MANPATH="$MANPATH:$HOME/man"

pyuserbase="$(python3 -msite --user-base)"
if [ "x$pyuserbase" != "x$HOME/.local" -a -d "$pyuserbase/bin" ]
then PATH="$PATH:$pyuserbase/bin"
fi

export PAGER=/usr/bin/less
export MANPAGER="$PAGER -is"
export LESS=-iRS
export EDITOR=/usr/bin/vim
export VISUAL="$EDITOR"
export BC_ENV_ARGS="-lq $HOME/share/util.gbc"
export SYSTEMD_LESS=-iRS

[ -z "$BASH" ] || . ~/.bashrc
