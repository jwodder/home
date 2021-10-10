#!/bin/bash
export MAIL_HOSTNAME=
while getopts :m: opt
do
    case "$opt" in
        m) MAIL_HOSTNAME="$OPTARG"
           ;;
        *) echo "Usage: $0 [-m <mail hostname>]" 1>&2
           exit 2
    esac
done

set -ex

cd "$(dirname "$0")"

#if ! pipx list --json | jq -r '.venvs | has("datalad")' > /dev/null
if ! pipx list | grep -q dotdrop
then pipx install dotdrop
fi

case "$(uname)" in
    Darwin) export DOTDROP_PROFILE=macOS
            ;;
     Linux) source /etc/os-release
            if [ "x$ID" = xdebian ] || [ "x$ID_LIKE" = xdebian ]
            then if [ -n "$MAIL_HOSTNAME" ]
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

dotdrop install

mkdir -p ~/work
[ -z "$MAIL_HOSTNAME" ] || mkdir -p ~/Mail

if command -V make &> /dev/null
then make -C ~/share/spell
fi

mkdir -p ~/.vim/pack/plugins/start
cd ~/.vim/pack/plugins/start
for repo in https://github.com/cespare/vim-toml \
            https://github.com/knatsakis/deb.vim \
            https://github.com/ntpeters/vim-better-whitespace
do [ -e "$(basename "$repo")" ] || git clone "$repo"
done
