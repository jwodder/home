#!/usr/bin/env python3
# https://packaging.python.org/en/latest/specifications/externally-managed-environments/
import os.path
import sys
import sysconfig

if sys.prefix != sys.base_prefix:
    sys.exit("Current Python environment is a virtualenv")

marker = os.path.join(
    sysconfig.get_path("stdlib", sysconfig.get_default_scheme()), "EXTERNALLY-MANAGED"
)

if os.path.isfile(marker):
    # Externally managed
    print("yes")
else:
    print("no")
