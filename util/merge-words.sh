#!/bin/bash
set -ex -o pipefail

REPO_WORDS="$(dirname "$0")"/../files/share/spell/words.utf-8.add
HOME_WORDS="$HOME/share/spell/words.utf-8.add"
TMP_WORDS="$(mktemp)"

LC_ALL=C.UTF-8 sort -o "$TMP_WORDS" -u "$REPO_WORDS" "$HOME_WORDS"

cp -f "$TMP_WORDS" "$REPO_WORDS"
cp -f "$TMP_WORDS" "$HOME_WORDS"
rm "$TMP_WORDS"

make -C ~/share/spell
