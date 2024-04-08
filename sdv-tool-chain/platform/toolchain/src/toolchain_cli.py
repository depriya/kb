#! /usr/bin/env python3

"""
Copyright (C) Microsoft Corporation.

The main file of the Toolchain Metadata Services CLI Tool.

$ python3 ./toolchain_cli.py arg1 arg2 ...
"""

import os
import sys

from core.application import Application


def main(argv: list[str]):
    """Run application."""
    application = Application(os.path.abspath(__file__))
    application.load_extensions()
    application.run(sys.argv)


if __name__ == "__main__":
    main(sys.argv)
