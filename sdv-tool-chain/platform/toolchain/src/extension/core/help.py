"""
Copyright (C) Microsoft Corporation.

The `help` extension.
"""

from extension import BaseExtension


class Help(BaseExtension):
    """The `help` extension."""

    @property
    def name(self) -> str:  # noqa: D102
        return "help"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["help"]

    @property
    def description(self) -> str:  # noqa: D102
        return "Prints help."

    def execute(self, args: list[str]) -> None:  # noqa: D102
        for ext in self.application.extensions.collect_extensions(""):
            print(", ".join(ext.aliases))
            print("\t" + "\n\t".join(ext.description.splitlines()))
            print()
