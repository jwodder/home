#!/bin/bash
set -e -o pipefail

case "$(uname)" in
    Darwin) export DOTDROP_PROFILE=macOS
            ;;
     Linux) source /etc/os-release
            if [ "x$ID" = xdebian ] || [ "x$ID_LIKE" = xdebian ]
            then if [ -z "$MAIL_HOSTNAME" ] && command -V postconf &> /dev/null
                 then export MAIL_HOSTNAME="$(postconf -h mydomain)"
                 fi
                 if [ -n "$MAIL_HOSTNAME" ]
                 then export DOTDROP_PROFILE=debian-mail
                 else export DOTDROP_PROFILE=debian
                 fi
            else echo "[WARNING] Unsupported distribution" >&2
                 export DOTDROP_PROFILE=base
            fi
            ;;
         *) echo "Unknown OS: $(uname)" >&2
            exit 1
            ;;
esac

export DOTDROP_NOBANNER=1
dotdrop "$@"
