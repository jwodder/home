#!/usr/bin/env python3
# Script for removing the E3 capability from the terminfo definitions for
# various terminals so that `clear` on those terminals won't clear the
# scrollback.  See <https://askubuntu.com/a/812990/25560> for more information.
from __future__ import annotations
import subprocess
import re
from pathlib import Path


def rm_e3(term: str) -> None:
    terminfo = subprocess.run(
        ["infocmp", "-x", term], check=True, text=True, stdout=subprocess.PIPE
    ).stdout
    (terminfo, subs) = re.subn(r"(?<=\s)E3=[^\s,]+,", "", terminfo)
    if subs:
        print(f"Modifying {term} definition ...")
        subprocess.run(
            ["tic", "-o", Path.home() / ".terminfo", "-x", "-"],
            check=True,
            input=terminfo,
            text=True,
        )
    else:
        print(f"No change to {term} definition")


if __name__ == "__main__":
    rm_e3("xterm-256color")
    rm_e3("screen-256color")
    rm_e3("tmux-256color")
