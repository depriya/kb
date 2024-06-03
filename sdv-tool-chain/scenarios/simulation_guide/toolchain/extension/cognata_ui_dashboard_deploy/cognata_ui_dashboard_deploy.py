"""
Copyright (C) Microsoft Corporation.

The `CognataUIDashboardDeploy` extension.
"""

from dataclasses import dataclass

from extension import BaseMetamodelExtension


class CognataUIDashboardDeploy(BaseMetamodelExtension):
    """The `CognataUIDashboardDeploy` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `CognataUIDashboardDeploy` extension parameters."""

        toolchain_output_path: str
        user_docker_defined_network: str

        simulation_proxy_alias: str
        simulation_proxy_port: int

        simulation_symphony_alias: str
        simulation_symphony_port: int

        simulation_ui_frontend_alias: str
        simulation_ui_frontend_port: int

        simulation_ui_backend_alias: str
        simulation_ui_backend_port: int

        def __post_init__(self) -> None:
            """Post initializer of `CognataSimulationScripts.Parameters`."""

            assert (
                self.simulation_proxy_port
                >= BaseMetamodelExtension.Parameters.MIN_PORT_NUM
                and self.simulation_proxy_port
                <= BaseMetamodelExtension.Parameters.MAX_PORT_NUM
            )

            assert (
                self.simulation_symphony_port
                >= BaseMetamodelExtension.Parameters.MIN_PORT_NUM
                and self.simulation_symphony_port
                <= BaseMetamodelExtension.Parameters.MAX_PORT_NUM
            )

            assert (
                self.simulation_ui_frontend_port
                >= BaseMetamodelExtension.Parameters.MIN_PORT_NUM
                and self.simulation_ui_frontend_port
                <= BaseMetamodelExtension.Parameters.MAX_PORT_NUM
            )

            assert (
                self.simulation_ui_backend_port
                >= BaseMetamodelExtension.Parameters.MIN_PORT_NUM
                and self.simulation_ui_backend_port
                <= BaseMetamodelExtension.Parameters.MAX_PORT_NUM
            )

    @property
    def name(self) -> str:  # noqa: D102
        return "cognata ui dashboard deploy"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["cognata ui dashboard deploy"]

    @property
    def description(self) -> str:  # noqa: D102
        return "Creates a startup script to run the e2e scenario in a containerized environment"

    @property
    def config_name(self) -> str:  # noqa: D102
        return "cognata ui dashboard deploy"
