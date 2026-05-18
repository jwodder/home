from __future__ import annotations
import re
import subprocess

DEFAULT_TMUX_VERSION = (3, 6, 0)


def tmux_version() -> tuple[int, int, int]:
    try:
        r = subprocess.run(["tmux", "-V"], check=True, capture_output=True, text=True)
    except FileNotFoundError:
        # tmux isn't installed
        return DEFAULT_TMUX_VERSION
    vstr = r.stdout.strip()
    if (
        m := re.fullmatch(
            r"(?:tmux\s+)?(?P<major>[0-9]+)\.(?P<minor>[0-9]+)(?P<patch>[a-z])?", vstr
        )
    ) is not None:
        major = int(m["major"])
        minor = int(m["minor"])
        if (p := m["patch"]) is not None:
            patch = ord(p) - ord("a") + 1
        else:
            patch = 0
        return (major, minor, patch)
    else:
        raise ValueError(f"Could not parse `tmux -V` output: {vstr!r}")
