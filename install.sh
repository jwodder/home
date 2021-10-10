#!/bin/bash
set -ex

cd "$(dirname "$0")"

#if ! pipx list --json | jq -r '.venvs | has("datalad")' > /dev/null
if ! pipx list | grep -q dotdrop
then pipx install dotdrop
fi

case "$(uname)" in
    Darwin) export DOTDROP_PROFILE=macOS
            ;;
     Linux) export DOTDROP_PROFILE=debian
            ;;
esac

dotdrop install

mkdir -p ~/work
#mkdir -p ~/Mail

if command -V make &> /dev/null
then make -C ~/share/spell
fi
