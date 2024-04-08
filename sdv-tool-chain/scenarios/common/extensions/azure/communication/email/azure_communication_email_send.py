"""
Copyright (C) Microsoft Corporation.

The `AzureCommunicationEmailSend` extension.
"""

from dataclasses import dataclass
from extension import BaseMetamodelExtension


class AzureCommunicationEmailSend(BaseMetamodelExtension):
    """The `AzureCommunicationEmailSend` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `AzureCommunicationEmailSend` extension parameters."""

        keyvault_key: str
        keyvault_name: str

        sender: str
        subject: str
        recepients: list[str]
        text: str

    @property
    def _depends_on(self) -> list[str]:  # noqa: D102
        return ["symphony campaign"]

    @property
    def name(self) -> str:  # noqa: D102
        return "Azure Communication Email Send"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["azure communication email send", "az communication email send"]

    @property
    def description(self) -> str:  # noqa: D102
        return (
            "Outputs a bash script that calls 'az communication email send' command.\n"
            "It is used to send an email through Azure Communication Service."
        )

    @property
    def config_name(self) -> str:  # noqa: D102
        return "azure communication email send"
