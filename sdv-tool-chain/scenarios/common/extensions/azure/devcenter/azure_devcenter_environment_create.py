"""
Copyright (C) Microsoft Corporation.

The `AzureDevcenterEnvironmentCreate` extension.
"""

from dataclasses import dataclass, field
from extension import BaseMetamodelExtension, get_output_filename
import os
from typing import Any, Iterable, Optional


class AzureDevcenterEnvironmentCreate(BaseMetamodelExtension):
    """The `AzureDevcenterEnvironmentCreate` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `AzureDevcenterEnvironmentCreate` extension parameters."""

        # RG with this name will be created by the 'az devcenter environment create' command.
        # It will also be the name of the environment, under the Environments pane of the devcenter resource.
        azure_devcenter_environment_name: str

        # Environment type as configured at
        # https://ms.portal.azure.com/{tenant}/resource/subscriptions/{subscription}/resourceGroups/{resource_group}/providers/Microsoft.DevCenter/projects/{project_name}/project_environment_types  # noqa: E501
        azure_devcenter_environment_type: str

        # The name of the 'devcenter' Azure resource that will be used to create the environment.
        azure_devcenter_name: str

        # The name of the 'project' Azure resource that will be used to create the environment.
        # This is the 'project' associated with the 'devcenter'.
        azure_devcenter_project_name: str

        # The catalog directory name.
        azure_devcenter_catalog_name: str

        # The name of the ARM template to deploy which is specified in the manifest.yaml.
        # The ARM template is located in the repository associated with the 'catalog'.
        azure_devcenter_environment_definition_name: str

        # The parameters file for the ARM template. The ARM template is located in the
        # repository associated with the 'catalog'.
        azuredeploy_parameters_file: str

        azuredeploy_parameters_file_input: Optional[dict[str, Any]] = field(default=None)

        # Will be initialized in __post_init__
        azuredeploy_parameters_file_path: str = field(init=False)

        def __post_init__(self) -> None:
            """Post initializer of `AzureDevcenterEnvironmentCreate.Parameters`."""
            self.azuredeploy_parameters_file_path = os.path.abspath(
                os.path.join(self.metamodel_directory_path, self.azuredeploy_parameters_file)
            )
            assert os.path.exists(self.azuredeploy_parameters_file_path)
            assert os.path.isfile(self.azuredeploy_parameters_file_path)

            self.azuredeploy_parameters_file = get_output_filename(filepath=self.azuredeploy_parameters_file_path)

    @property
    def _depends_on(self) -> list[str]:  # noqa: D102
        return ["symphony campaign"]

    @property
    def name(self) -> str:  # noqa: D102
        return "Azure Devcenter Environment Create"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["azure devcenter environment create", "az devcenter environment create"]

    @property
    def description(self) -> str:  # noqa: D102
        return (
            "Outputs a bash script that calls 'az devcenter dev environment create' command.\n"
            "It is used to create a new environment in Azure Devcenter."
        )

    @property
    def config_name(self) -> str:  # noqa: D102
        return "azure devcenter environment create"

    def _execute_referenced_template_with_parameters(
        self, params: "BaseMetamodelExtension.Parameters"
    ) -> Iterable[BaseMetamodelExtension.ExecuteWithParametersOutput]:  # noqa: D102
        if not isinstance(params, self.Parameters):
            raise ValueError(f"Expected '{self.Parameters.__name__}' but got '{type(params).__name__}'.")

        yield self._execute_template_file_with_parameters(
            filepath=params.azuredeploy_parameters_file_path, params=params.azuredeploy_parameters_file_input or {}
        )
