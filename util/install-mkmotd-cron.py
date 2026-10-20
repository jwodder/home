#!/usr/bin/env python3
from __future__ import annotations
import subprocess

RULE = "0 * * * * chronic ~/share/mkmotd.py -v -o ~/.local/etc/motd"


def main() -> None:
    try:
        crontab = subprocess.run(
            ["crontab", "-l"],
            check=True,
            stdout=subprocess.PIPE,
            text=True,
            encoding="utf-8",
        ).stdout
    except subprocess.CalledProcessError as e:
        if e.returncode == 1:
            crontab = ""
        else:
            raise
    rules = crontab.splitlines()
    for i, ln in enumerate(rules):
        if "mkmotd.py" in ln:
            if ln == RULE:
                return
            else:
                rules[i] = RULE
                break
    else:
        rules.append(RULE)
    subprocess.run(
        ["crontab", "-"],
        check=True,
        input="".join(f"{r}\n" for r in rules),
        text=True,
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
