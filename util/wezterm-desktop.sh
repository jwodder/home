#!/bin/bash
set -eux -o pipefail

src=/usr/share/applications/org.wezfurlong.wezterm.desktop
dest="$HOME"/.local/share/applications/org.wezfurlong.wezterm.desktop
link="$HOME"/.config/autostart/org.wezfurlong.wezterm.desktop

mkdir -p "$(dirname "$dest")"
mkdir -p "$(dirname "$link")"

# Remove the `--cwd .` arguments from the Exec line so that WezTerm will honor
# config.default_cwd.
perl -ple 's/ --cwd \.(?= |$)// if /^Exec=/' "$src" > "$dest"

# Autostart WezTerm on desktop startup
ln -sf "$dest" "$link"
