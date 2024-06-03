"""
Copyright (C) Microsoft Corporation.

Sample extension for testing.
"""

from extension import BaseExtension


class SampleExtensionTwo(BaseExtension):  # noqa: D101
    @property
    def name(self) -> str:  # noqa: D102
        return "sample extension two"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["sample extension two"]

    @property
    def description(self) -> str:  # noqa: D102
        return "sample extension two"

    def execute(self, args: list[str]) -> None:  # noqa: D102
        pass
