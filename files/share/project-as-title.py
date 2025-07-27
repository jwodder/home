#!/usr/bin/env python3
# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
from __future__ import annotations
import os
import os.path
import subprocess


def main() -> None:
    name = get_project_name() or ""
    if os.environ.get("TERM_PROGRAM", "") == "tmux":
        code = 0
    else:
        code = 1
    print(f"\x1b]{code};{name}\x1b\\", end="", flush=True)


def get_project_name() -> str | None:
    try:
        r = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            check=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
    except (IOError, subprocess.CalledProcessError):
        return None
    path = r.stdout.removesuffix("\n").removesuffix("\r")
    return os.path.basename(path)


if __name__ == "__main__":
    main()
