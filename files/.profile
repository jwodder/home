{%@@ if profile == "macOS" @@%}
cd ~/work
{%@@ endif @@%}
[ -t 0 ] && mesg n
umask 0022

{%@@ if profile == "macOS" @@%}
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
{%@@ else @@%}
export LANG=C.UTF-8 LC_ALL=C.UTF-8
{%@@ endif @@%}
export PATH="{%@@ if profile == "macOS" @@%}/usr/local/sbin:{%@@ endif @@%}$PATH:$HOME/bin:$HOME/.local/bin"

export PAGER={{@@ lesspath|shlex_quote @@}}
export MANPAGER="$PAGER -is"
export LESS=-iRS
export EDITOR={{@@ vimpath|shlex_quote @@}}
export VISUAL="$EDITOR"
export BC_ENV_ARGS="-lq $HOME/share/util.gbc"
{%@@ if profile == "macOS" @@%}
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=1
export WS=/Library/WebServer/Documents
{%@@ else @@%}
export SYSTEMD_LESS=-iRS
{%@@ endif @@%}

[ -z "$BASH" ] || . ~/.bashrc
