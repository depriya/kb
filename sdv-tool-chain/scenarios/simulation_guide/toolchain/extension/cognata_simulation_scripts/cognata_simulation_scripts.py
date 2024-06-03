"""
Copyright (C) Microsoft Corporation.

The `CognataSimulationScripts` extension.
"""

from dataclasses import dataclass, field

from extension import BaseMetamodelExtension


class CognataSimulationScripts(BaseMetamodelExtension):
    """The `CognataSimulationScripts` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `CognataSimulationScripts` extension parameters."""

        username: str
        password: str
        environment: str
        cognata_api_studio_url: str = field(
            metadata={
                BaseMetamodelExtension.Parameters.REGEX_METADATA: BaseMetamodelExtension.Parameters.URL_REGEX
            }
        )
        toolchain_output_path: str
        azure_cosmos_db_primary_key: str
        azure_cosmos_db_uri: str = field(
            metadata={
                BaseMetamodelExtension.Parameters.REGEX_METADATA: BaseMetamodelExtension.Parameters.URL_REGEX
            }
        )
        database_id: str
        jobs_container: str
        projects_container: str
        symphony_port: int
        symphony_version: str

        def __post_init__(self) -> None:
            """Post initializer of `CognataSimulationScripts.Parameters`."""

            assert (
                self.symphony_port >= BaseMetamodelExtension.Parameters.MIN_PORT_NUM
                and self.symphony_port <= BaseMetamodelExtension.Parameters.MAX_PORT_NUM
            )

    @property
    def _depends_on(self) -> list[str]:  # noqa: D102
        return ["symphony campaign", "cognata backend api binary"]

    @property
    def name(self) -> str:  # noqa: D102
        return "cognata simulation scripts"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["cognata simulation scripts"]

    @property
    def description(self) -> str:  # noqa: D102
        return "The scripts needed by Cognata's simulation symphony campaign."

    @property
    def config_name(self) -> str:  # noqa: D102
        return "cognata simulation scripts"
