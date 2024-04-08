"""
Copyright (C) Microsoft Corporation.

The `mock nested common` extension.

This extension is needed to test the case when the 'common' directory contains subfolders with nested files.
The 'common' directory is a requirement for any extension that other extensions depend on.
A successful execution of the `mock nested common` extension means that the nested files in the 'common'
directory are copied over to the output of a target that depends on this extension.
"""

from dataclasses import dataclass

from extension import BaseMetamodelExtension


class MockNestedCommonExtension(BaseMetamodelExtension):
    """The `MockNestedExtension` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `MockNestedCommonExtension` extension parameters."""

        message: str

    @property
    def name(self) -> str:  # noqa: D102
        return "mock nested common"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["mock nested common"]

    @property
    def description(self) -> str:  # noqa: D102
        return (
            "Mock nested common extension for testing. Does nothing, but validates a case when the 'common' "
            "directory contains subfolders."
        )

    @property
    def config_name(self) -> str:  # noqa: D102
        return "mock nested common"
