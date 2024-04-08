"""
Copyright (C) Microsoft Corporation.

The `CognataUIDashboardBackend` extension.
"""

from dataclasses import dataclass, field

from extension import BaseMetamodelExtension


class CognataUIDashboardBackend(BaseMetamodelExtension):
    """The `CognataUIDashboardBackend` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `CognataUIDashboardBackend` extension parameters."""

        toolchain_output_path: str
        jwt_secret: str
        azure_cosmos_db_primary_key: str
        azure_cosmos_db_uri: str = field(
            metadata={
                BaseMetamodelExtension.Parameters.REGEX_METADATA: BaseMetamodelExtension.Parameters.URL_REGEX
            }
        )
        environment: str
        database_id: str
        jobs_container: str
        users_container: str
        projects_container: str
        port: int
        simulation_proxy_alias: str
        simulation_proxy_port: int
        simulation_ui_backend_port: int

        def __post_init__(self) -> None:
            """Post initializer of `CognataUIDashboardBackend.Parameters`."""

            assert (
                self.port >= BaseMetamodelExtension.Parameters.MIN_PORT_NUM
                and self.port <= BaseMetamodelExtension.Parameters.MAX_PORT_NUM
            )
            assert (
                self.simulation_proxy_port
                >= BaseMetamodelExtension.Parameters.MIN_PORT_NUM
                and self.simulation_proxy_port
                <= BaseMetamodelExtension.Parameters.MAX_PORT_NUM
            )
            assert (
                self.simulation_ui_backend_port
                >= BaseMetamodelExtension.Parameters.MIN_PORT_NUM
                and self.simulation_ui_backend_port
                <= BaseMetamodelExtension.Parameters.MAX_PORT_NUM
            )

    @property
    def _depends_on(self) -> list[str]:  # noqa: D102
        return ["cognata ui dashboard frontend"]

    @property
    def name(self) -> str:  # noqa: D102
        return "cognata ui dashboard backend"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["cognata ui dashboard backend"]

    @property
    def description(self) -> str:  # noqa: D102
        return "The backend code for the simulation dashboard."

    @property
    def config_name(self) -> str:  # noqa: D102
        return "cognata ui dashboard backend"
