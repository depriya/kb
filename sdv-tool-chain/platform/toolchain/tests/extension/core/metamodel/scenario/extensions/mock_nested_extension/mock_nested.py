"""
Copyright (C) Microsoft Corporation.

The `mock nested` extension.

This extension is needed to test the case when 'templates' directory contains subfolders with '*.j2' template files.
A successful execution of the `mock nested` extension means that the nested '*.j2' template files are evaluated.
"""

from dataclasses import dataclass

from extension import BaseMetamodelExtension


class MockNestedExtension(BaseMetamodelExtension):
    """The `MockNestedExtension` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `MockNested` extension parameters."""

        message: str

    @property
    def name(self) -> str:  # noqa: D102
        return "mock nested"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["mock nested"]

    @property
    def description(self) -> str:  # noqa: D102
        return (
            "Mock nested extension for testing. Does nothing, but validates a case when 'templates' "
            "directory contains subfolders with '*.j2' files."
        )

    @property
    def config_name(self) -> str:  # noqa: D102
        return "mock nested"
