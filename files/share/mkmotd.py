#!/usr/bin/env python3
# /// script
# requires-python = ">=3.14"
# dependencies = []
# ///

# - welcome message?
#     - hostname
#     - distro name (styled using `ANSI_COLOR` from `/etc/os-release`?)
# - available firmware updates with `fwupd`
#     - Cf.
#       <https://wiki.archlinux.org/title/Talk:Fwupd#RFC:_new_section_about_auto-update_checking>
# - IP addresses?
# - notices about pacnew files?

from __future__ import annotations
import argparse
from collections.abc import Iterator
from datetime import datetime
from io import Writer
import json
import logging
import os
from pathlib import Path
from shutil import disk_usage
import subprocess
import sys
import tempfile
import textwrap
from types import TracebackType
from typing import Any

DISK_THRESHOLD = 75  # measured in percentage points

MAX_CHECKUPDATES_LINES = 5

# TODO: Confirm:
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
            check_updates,
            check_reboot_for_kernel,
            check_mailboxes,
            check_disk,
        ]:
            if (s := check()) is not None:
                nonempty = True
                print(s.rstrip("\n") + "\n\n", end="", file=outfp)
        nowstamp = datetime.now().astimezone().isoformat(sep=" ", timespec="seconds")
        # TODO: Colorize the final line:
        if nonempty:
            print(f"[MOTD generated at {nowstamp}]", file=outfp)
        else:
            print(f"[No news as of {nowstamp}]", file=outfp)


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
        return "\x1b[33mcheckupdates program not found; please install the pacman-contrib package.\x1b[m"
    except subprocess.CalledProcessError as e:
        if e.returncode == 2 and not e.stdout and not e.stderr:
            log.info(" ⤷ No updates available")
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
            log.info(" ⤷ No updates available")
            return None
        elif update_qty <= MAX_CHECKUPDATES_LINES:
            return (
                f"{update_qty} package update{'s' if update_qty > 1 else ''} available:"
                + textwrap.indent(r.stdout, " " * 4)
            )
        else:
            return f"{update_qty} package updates available"


def check_reboot_for_kernel() -> str | None:
    log.info("Fetching currently-installed kernel version ...")
    r = subprocess.run(
        ["pacman", "-Q", "--print-format=%v", "linux"],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
        encoding="utf-8",
    )
    installed_version = r.stdout.strip()
    log.info(" ⤷ Got %s", installed_version)
    log.info("Fetching currently-running kernel version ...")
    running_version = os.uname().release
    log.info(" ⤷ Got %s", running_version)
    if running_version != installed_version:
        return "[!] Reboot to upgrade kernel"
    else:
        return None


def check_mailboxes() -> str | None:
    log.info("Checking for nonempty mailboxes ...")
    nonempty = [p.name for p in MAIL_DIR.iterdir() if p.stat().st_size > 0]
    log.info(" ⤷ Found %d nonempty mailbox(es)", len(nonempty))
    if nonempty:
        nonempty.sort()
        return "Mail for: " + " ".join(nonempty)
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
                f"\x1b[33mWARNING: Disk usage on {mntpoint} at {pctused}%\x1b[m"
            )
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


if __name__ == "__main__":
    main()
