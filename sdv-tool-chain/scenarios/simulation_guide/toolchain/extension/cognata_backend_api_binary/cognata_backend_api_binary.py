"""
Copyright (C) Microsoft Corporation.

The `CognataBackendApiBinary` extension.
"""


from extension import BaseMetamodelExtension


class CognataBackendApiBinary(BaseMetamodelExtension):
    """The `CognataBackendApiBinary` extension."""

    @property
    def name(self) -> str:  # noqa: D102
        return "cognata backend api binary"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["cognata backend api binary"]

    @property
    def description(self) -> str:  # noqa: D102
        return "Provides a binary of Cognata's backend APIs"

    @property
    def config_name(self) -> str:  # noqa: D102
        return "cognata backend api binary"
