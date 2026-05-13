#!/bin/bash
set -e -o pipefail

case "$(uname)" in
    Darwin) export DOTDROP_PROFILE=macOS
            ;;
     Linux) source /etc/os-release
            if [ "$ID" = debian ] || [ "$ID_LIKE" = debian ]
            then distro=debian
            elif [ "$ID" = arch ]
            then distro=arch
            else echo "[WARNING] Unsupported distribution" >&2
                 export distro=base
            fi
            if [ "$distro" != base ] && [ -z "$MAIL_HOSTNAME" ] && command -V postconf &> /dev/null
            then export MAIL_HOSTNAME="$(postconf -h mydomain)"
            fi
            if [ -n "$MAIL_HOSTNAME" ]
            then export DOTDROP_PROFILE="$distro"-mail
            else export DOTDROP_PROFILE="$distro"
            fi
            ;;
         *) echo "Unknown OS: $(uname)" >&2
            exit 1
            ;;
esac

export DOTDROP_NOBANNER=1
dotdrop "$@"
