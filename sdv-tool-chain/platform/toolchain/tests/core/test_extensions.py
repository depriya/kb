"""
Copyright (C) Microsoft Corporation.

Tests for the extensions class of the Toolchain Metadata Services.
"""

import os

import pytest
from core.application import Application
from extension import BaseExtension


class SimpleTestExtension(BaseExtension):  # noqa: D101
    @property
    def name(self) -> str:  # noqa: D102
        return "test extension"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["test extension"]

    @property
    def description(self) -> str:  # noqa: D102
        return "test extension"

    def execute(self, args: list[str]) -> None:  # noqa: D102
        pass


def test_register_extension():  # noqa: D103
    path = os.path.abspath(__file__)
    application = Application(path)
    test_extension = SimpleTestExtension(application, path)

    application.extensions.register_extensions([test_extension])
    extensions = list(application.extensions.collect_extensions(base_alias=""))

    assert len(extensions) == 1
    assert extensions[0] is test_extension


def test_register_extension_fails_collision():  # noqa: D103
    path = os.path.abspath(__file__)
    application = Application(path)
    test_extension = SimpleTestExtension(application, path)

    with pytest.raises(ValueError):
        application.extensions.register_extensions([test_extension, test_extension])
