"""
Copyright (C) Microsoft Corporation.

The `GithubDispatchWorkflow` extension.
"""

from dataclasses import dataclass, field
from extension import BaseMetamodelExtension
from typing import Any, Optional, Union
import re

GITHUB_FORMAT_REGEX = re.compile(r"^[a-zA-Z0-9._-]+$")

# ref: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftkeyvault
KEY_VAULT_NAME_REGEX = re.compile(r"^[a-zA-Z](?!.*--)[a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$")
KEY_VAULT_KEY_REGEX = re.compile(r"^[a-zA-Z0-9-]{1,127}$")


class GithubDispatchWorkflow(BaseMetamodelExtension):
    """The `GithubDispatchWorkflow` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `GithubDispatchWorkflow` extension parameters."""

        repo_owner: str = field(metadata={BaseMetamodelExtension.Parameters.REGEX_METADATA: GITHUB_FORMAT_REGEX})
        repo_name: str = field(metadata={BaseMetamodelExtension.Parameters.REGEX_METADATA: GITHUB_FORMAT_REGEX})
        workflow_id: str = field(metadata={BaseMetamodelExtension.Parameters.REGEX_METADATA: GITHUB_FORMAT_REGEX})
        ref: str

        keyvault_name: str = field(metadata={BaseMetamodelExtension.Parameters.REGEX_METADATA: KEY_VAULT_NAME_REGEX})
        keyvault_key: str = field(metadata={BaseMetamodelExtension.Parameters.REGEX_METADATA: KEY_VAULT_KEY_REGEX})

        # This is an optional field and will not be required in the config.yml or in the command line
        # It is of type 'str' when it comes from the command line
        # and of type 'dict[str, Any]' when it comes from the config.yml
        inputs: Optional[Union[str, dict[str, Any]]] = field(default=None)

    @property
    def _depends_on(self) -> list[str]:  # noqa: D102
        return ["symphony campaign"]

    @property
    def name(self) -> str:  # noqa: D102
        return "github dispatch workflow"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["github dispatch workflow"]

    @property
    def description(self) -> str:  # noqa: D102
        return "Dispatches a GitHub workflow."

    @property
    def config_name(self) -> str:  # noqa: D102
        return "github dispatch workflow"
