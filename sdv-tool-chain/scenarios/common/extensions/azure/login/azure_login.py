"""
Copyright (C) Microsoft Corporation.

The `AzureLogin` extension.
"""

from extension import BaseMetamodelExtension


class AzureLogin(BaseMetamodelExtension):
    """The `AzureLogin` extension."""

    @property
    def _depends_on(self) -> list[str]:  # noqa: D102
        return ["symphony campaign"]

    @property
    def name(self) -> str:  # noqa: D102
        return "Azure Login"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["azure login", "az login"]

    @property
    def description(self) -> str:  # noqa: D102
        return "Runs 'az login --identity' to login to Azure using a VM's system-assigned managed identity."

    @property
    def config_name(self) -> str:  # noqa: D102
        return "azure login"
