"""
Copyright (C) Microsoft Corporation.

The `CognataSimulationProxy` extension.
"""

from dataclasses import dataclass

from extension import BaseMetamodelExtension


class CognataSimulationProxy(BaseMetamodelExtension):
    """The `CognataSimulationProxy` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `CognataSimulationProxy` extension parameters."""

        host_authority: str
        port: int
        toolchain_output_path: str

        def __post_init__(self) -> None:
            """Post initializer of `CognataSimulationProxy.Parameters`."""

            assert (
                self.port >= BaseMetamodelExtension.Parameters.MIN_PORT_NUM
                and self.port <= BaseMetamodelExtension.Parameters.MAX_PORT_NUM
            )

    @property
    def name(self) -> str:  # noqa: D102
        return "cognata simulation proxy"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["cognata simulation proxy"]

    @property
    def description(self) -> str:  # noqa: D102
        return "The Cognata Simulation Proxy is a proxy that calls Symphony to run the simulation campaign"

    @property
    def config_name(self) -> str:  # noqa: D102
        return "cognata simulation proxy"
