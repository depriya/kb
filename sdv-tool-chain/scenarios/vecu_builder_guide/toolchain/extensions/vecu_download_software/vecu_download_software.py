"""
Copyright (C) Microsoft Corporation.

The `download software` extension.
"""

import re
from dataclasses import dataclass, field

from extension import BaseMetamodelExtension

# Validates an image with its tag.
# The format should follow <registry>/<repo_name>/<image>:<tag>
# Examples of valid image URIs:
# hello-world:latest
# mcr.microsoft.com/mcr/hello-world
IMAGE_URI_REGEX = re.compile(
    r"^(?:[a-zA-Z0-9.-]+/)*[a-zA-Z0-9.-]+(?:/[a-zA-Z0-9.-]+)*:[a-zA-Z0-9.-]+$"
)


class VECUDownloadSoftware(BaseMetamodelExtension):
    """The `DownloadSoftware` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `VECUDownloadSoftware` extension parameters."""

        source_uri: str = field(
            metadata={BaseMetamodelExtension.Parameters.REGEX_METADATA: IMAGE_URI_REGEX}
        )
        source_type: str
        symphony_base_url: str = field(
            metadata={
                BaseMetamodelExtension.Parameters.REGEX_METADATA: BaseMetamodelExtension.Parameters.URL_REGEX
            }
        )
        symphony_agent_port: int
        max_retry_attempts: int
        retry_interval_secs: int

        def __post_init__(self) -> None:
            """Post initializer of `VECUDownloadSoftware.Parameters`."""

            assert (
                self.symphony_agent_port
                >= BaseMetamodelExtension.Parameters.MIN_PORT_NUM
                and self.symphony_agent_port
                <= BaseMetamodelExtension.Parameters.MAX_PORT_NUM
            )

            assert self.max_retry_attempts > 0
            assert self.retry_interval_secs >= 0

    @property
    def _depends_on(self) -> list[str]:  # noqa: D102
        return ["symphony campaign"]

    @property
    def name(self) -> str:  # noqa: D102
        return "vecu download software"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["vecu download software"]

    @property
    def description(self) -> str:  # noqa: D102
        return "Create a target vECU configuration file to install software (Docker image) onto the target machine."

    @property
    def config_name(self) -> str:  # noqa: D102
        return "vecu download software"
