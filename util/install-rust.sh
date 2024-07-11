#!/bin/bash
set -ex -o pipefail

curl --proto '=https' --tlsv1.2 -LsSf https://sh.rustup.rs \
    | sh /dev/stdin -y --no-modify-path

curl --proto '=https' --tlsv1.2 -LsSf \
    https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh \
    | bash

if [ "$(uname)" = Linux ]
then
    # <https://rust-analyzer.github.io/manual.html#rust-analyzer-language-server-binary>
    mkdir -p ~/.local/bin
    curl --proto '=https' --tlsv1.2 -LsSf \
        https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-"$(arch)"-unknown-linux-gnu.gz \
        | gunzip -c - > ~/.local/bin/rust-analyzer
    chmod +x ~/.local/bin/rust-analyzer
fi
