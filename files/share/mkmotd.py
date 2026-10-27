#!/usr/bin/env python3
# /// script
# requires-python = ">=3.14"
# dependencies = []
# ///

# TODO:
# - Show firmware updates available with `fwupd`
#     - Cf.
#       <https://wiki.archlinux.org/title/Talk:Fwupd#RFC:_new_section_about_auto-update_checking>
# - Show notices about pacnew files?

from __future__ import annotations
import argparse
from collections.abc import Iterator
from datetime import datetime
from io import Writer
import json
import logging
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import textwrap
from types import TracebackType
from typing import Any

DISK_THRESHOLD = 75  # measured in percentage points

MAX_CHECKUPDATES_LINES = 5

MAIL_DIR = Path("/var/spool/mail")

log = logging.getLogger("mkmotd")


class AtomicWriter:
    def __init__(self, target: Path) -> None:
        self.target = target
        target.parent.mkdir(parents=True, exist_ok=True)
        fd, tmppath = tempfile.mkstemp(
            dir=target.parent,
            prefix=f".{target.name}-",
        )
        os.close(fd)
        self.tmppath = Path(tmppath)

    def __enter__(self) -> AtomicWriter:
        self.fp = self.tmppath.open("w", encoding="utf-8")
        return self

    def __exit__(
        self,
        _exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        _exc_tb: TracebackType | None,
    ) -> None:
        self.fp.close()
        if exc_val is None:
            self.tmppath.replace(self.target)
        else:
            self.tmppath.unlink()

    def write(self, s: str) -> int:
        return self.fp.write(s)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("-o", "--outfile", type=Path)
    parser.add_argument("-v", "--verbose", action="store_true")
    args = parser.parse_args()
    logging.basicConfig(
        format="%(asctime)s [%(levelname)-8s] %(name)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S %z",
        level=logging.INFO if args.verbose else logging.WARNING,
    )
    outfp: Writer[str]
    if args.outfile is not None:
        outfp = AtomicWriter(args.outfile)
    else:
        outfp = sys.stdout
    with outfp:
        nonempty = False
        for check in [
            check_disk,
            check_mailboxes,
            check_updates,
            check_reboot_for_kernel,
        ]:
            if (s := check()) is not None:
                nonempty = True
                print(s.rstrip("\n") + "\n\n", end="", file=outfp)
        nowstamp = datetime.now().astimezone().isoformat(sep=" ", timespec="seconds")
        if nonempty:
            lastmsg = f"[MOTD generated at {nowstamp}]"
        else:
            lastmsg = f"[No news as of {nowstamp}]"
        print(f"\x1b[38;2;255;255;96m{lastmsg}\x1b[m", file=outfp)


def check_updates() -> str | None:
    log.info("Checking available pacman updates ...")
    try:
        r = subprocess.run(
            ["checkupdates"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
        )
    except FileNotFoundError:
        log.warning("checkupdates not installed")
        return (
            "\x1b[33mcheckupdates program not found;"
            " please install the pacman-contrib package.\x1b[m"
        )
    except subprocess.CalledProcessError as e:
        if e.returncode == 2 and not e.stdout and not e.stderr:
            log.info(" ↳ No updates available")
            return None
        else:
            if e.stdout:
                output = "Stdout:\n\n" + textwrap.indent(e.stdout, " " * 4)
            else:
                output = "Stdout: <empty>"
            if e.stderr:
                output += "\n\nStderr:\n\n" + textwrap.indent(e.stderr, " " * 4)
            else:
                output += "\n\nStderr: <empty>"
            log.error(
                "`checkupdates` exited with return code %d:\n\n%s",
                e.returncode,
                output,
            )
            sys.exit(e.returncode)
    else:
        update_qty = len(r.stdout.splitlines())
        if update_qty == 0:
            log.info(" ↳ No updates available")
            return None
        else:
            log.info(" ↳ %s available", quantify(update_qty, "update"))
            s = quantify(update_qty, "package update") + " available"
            if update_qty <= MAX_CHECKUPDATES_LINES:
                s += ":\n" + textwrap.indent(r.stdout, " " * 4)
            return s


def check_reboot_for_kernel() -> str | None:
    log.info("Fetching currently-installed kernel version ...")
    r = subprocess.run(
        ["pacman", "--color=never", "-Q", "linux"],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
        encoding="utf-8",
    )
    installed_version = r.stdout.split()[1]
    iv2 = installed_version.replace(".arch", "-arch")
    log.info(" ↳ Got %r → %r", installed_version, iv2)
    log.info("Fetching currently-running kernel version ...")
    running_version = os.uname().release
    log.info(" ↳ Got %r", running_version)
    if running_version != iv2:
        return "\x1b[1;31m[!]\x1b[m \x1b[31mReboot to upgrade kernel\x1b[m"
    else:
        return None


def check_mailboxes() -> str | None:
    log.info("Checking for nonempty mailboxes ...")
    nonempty = [p.name for p in MAIL_DIR.iterdir() if p.stat().st_size > 0]
    log.info(
        " ↳ Found %s",
        quantify(len(nonempty), "nonempty mailbox", plural="nonempty mailboxes"),
    )
    if nonempty:
        nonempty.sort()
        return "Mail for: " + " ".join(map(highlight, nonempty))
    else:
        return None


def check_disk() -> str | None:
    log.info("Fetching data on mounted filesystems ...")
    r = subprocess.run(
        ["findmnt", "--json", "--real", "-o", "TARGET,USE%"],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
        encoding="utf-8",
    )
    mntdata = json.loads(r.stdout)
    msgs = []
    for mntpoint, pctused in iter_findmnt(mntdata["filesystems"]):
        if pctused >= DISK_THRESHOLD:
            msgs.append(
                f"\x1b[1;33m[!]\e[m \x1b[33mWARNING: Disk usage on {mntpoint} at {pctused}%\x1b[m"
            )
    log.info(" ↳ %s over warning threshold", quantify(len(msgs), "filesystem"))
    if msgs:
        return "\n\n".join(msgs)
    else:
        return None


def iter_findmnt(data: list[dict[str, Any]]) -> Iterator[tuple[str, int]]:
    for fs in data:
        mntpoint = fs["target"]
        if fs["use%"] == "-":
            # I don't think this can happen for "real" filesystems, but just in
            # case...
            continue
        pctused = int(fs["use%"].removesuffix("%"))
        yield (mntpoint, pctused)
        if subdata := fs.get("children", []):
            yield from iter_findmnt(subdata)


def quantify(qty: int, singular: str, plural: str | None = None) -> str:
    # cf. the humanfriendly package's pluralize() function
    if qty == 1:
        return f"{qty} {singular}"
    elif plural is None:
        return f"{qty} {singular}s"
    else:
        return f"{qty} {plural}"


colors = set(range(1, 15))
colors.update(range(26, 52))
colors.update(range(58, 232))
colors.remove(7)
colors.remove(58)
colors.remove(59)
colors.remove(60)
colors.remove(61)
colors.remove(62)
colors.remove(88)
colors.remove(89)
colors.remove(90)
colors.remove(91)
colors.remove(92)
colors.remove(93)
colors.remove(124)
COLORS = sorted(colors)


def highlight(s: str) -> str:
    # <https://github.com/osa1/tiny/blob/07b0ceb6b0fe92146f28f2bde03938daad422ad0/crates/libtiny_tui/src/messaging.rs#L360>
    # Note that we can't use Python's hash() function, as that's randomized on
    # each program invocation.
    h = 5381
    for ch in s:
        h = h * 33 + ord(ch)
    index = COLORS[h % len(COLORS)]
    return f"\x1b[38:5:{index}m{s}\x1b[m"


if __name__ == "__main__":
    main()
