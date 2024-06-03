"""
Copyright (C) Microsoft Corporation.

Tests for the application class of the Toolchain Metadata Services.
"""

import os

from core.application import Application


def test_application_load_extension():  # noqa: D103
    path = os.path.abspath(__file__)
    application = Application(path)
    application.load_extensions(extensions_dir=os.path.join(os.path.dirname(path), "sample_extensions"))

    extensions = list(application.extensions.collect_extensions(base_alias=""))

    assert len(extensions) == 2
    assert [e.name for e in application.extensions.collect_extensions(base_alias="")] == [
        "sample extension one",
        "sample extension two",
    ]
