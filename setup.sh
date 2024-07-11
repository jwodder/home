#!/bin/bash
set -e
export MAIL_HOSTNAME=
while getopts :m: opt
do
    case "$opt" in
        m) MAIL_HOSTNAME="$OPTARG"
           ;;
        *) echo "Usage: $0 [-m <mail hostname>]" >&2
           exit 2
    esac
done

set -ex

pybinpath="$(python3 -msite --user-base)"/bin
if [[ ":$PATH:" != *":$pybinpath:"* ]]
then PATH="$PATH:$pybinpath"
fi

cd "$(dirname "$0")"

for f in setup.d/*
do ./"$f"
done
