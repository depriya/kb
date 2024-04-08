"""
Copyright (C) Microsoft Corporation.

Sample extension for testing.
"""

from extension import BaseExtension


class SampleExtensionOne(BaseExtension):  # noqa: D101
    @property
    def name(self) -> str:  # noqa: D102
        return "sample extension one"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["sample extension one"]

    @property
    def description(self) -> str:  # noqa: D102
        return "sample extension one"

    def execute(self, args: list[str]) -> None:  # noqa: D102
        pass
