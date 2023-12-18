#!/bin/bash
set -ex -o pipefail

curl --proto '=https' --tlsv1.2 -LsSf https://sh.rustup.rs \
    | sh /dev/stdin -y --no-modify-path

curl --proto '=https' --tlsv1.2 -LsSf \
    https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh \
    | bash
