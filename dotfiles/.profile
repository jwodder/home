{%@@ if profile == "macOS" @@%}
cd ~/work
{%@@ endif @@%}
[ -t 0 ] && mesg n
umask 0022

export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export PATH="{%@@ if profile == "macOS" @@%}/usr/local/sbin:{%@@ endif @@%}$PATH:$HOME/bin:$HOME/.local/bin"
export MANPATH="$MANPATH:$HOME/man"

pyuserbase="$(python3 -msite --user-base)"
if [ "x$pyuserbase" != "x$HOME/.local" -a -d "$pyuserbase/bin" ]
then PATH="$PATH:$pyuserbase/bin"
fi

export PAGER={{@@ lesspath|shlex_quote @@}}
export MANPAGER="$PAGER -is"
export LESS=-iRS
export EDITOR={{@@ vimpath|shlex_quote @@}}
export VISUAL="$EDITOR"
export BC_ENV_ARGS="-lq $HOME/share/util.gbc"
export SYSTEMD_LESS=-iRS

[ -z "$BASH" ] || . ~/.bashrc
