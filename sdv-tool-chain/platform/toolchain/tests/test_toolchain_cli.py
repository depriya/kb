"""
Copyright (C) Microsoft Corporation.

Tests for general logic of the Toolchain Metadata Services CLI Tool.
"""

from toolchain_cli import main


def test_main():  # noqa: D103
    main(["./toolchain_cli.py", "fads"])
