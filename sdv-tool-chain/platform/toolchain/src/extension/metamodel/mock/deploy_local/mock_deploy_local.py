"""
Copyright (C) Microsoft Corporation.

The `MockDeployLocal` extension.
"""

from dataclasses import dataclass
from extension import BaseMetamodelExtension


class MockDeployLocal(BaseMetamodelExtension):
    """The `MockDeployLocal` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `MockDeployLocal` extension parameters."""

        destination: str
        source: str

    @property
    def name(self) -> str:  # noqa: D102
        return "deploy local"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["mock deploy", "mock deploy local"]

    @property
    def description(self) -> str:  # noqa: D102
        return "(Mock) Deploys artifact locally."

    @property
    def config_name(self) -> str:  # noqa: D102
        return "mock deploy local"
