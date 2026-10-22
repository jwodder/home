#!/bin/bash
set -eux -o pipefail

cd "$(dirname "$0")"
mkdir -p ~/.config/systemd/user
cp -f mkmotd.service mkmotd.timer ~/.config/systemd/user
systemctl --user enable --now mkmotd.timer
