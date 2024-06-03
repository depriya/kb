"""
Copyright (C) Microsoft Corporation.
The `scp file` extension.
"""

from dataclasses import dataclass, field
from typing import Optional

from extension import BaseMetamodelExtension


class ScpFile(BaseMetamodelExtension):
    """The `ScpFile` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `ScpFile` extension parameters."""

        username: str
        password: str
        file_to_copy_src: str  # This file must exist at runtime of the model
        file_to_copy_dst: str
        recursive_copy: Optional[bool] = field(default=False)

        # Will be initialized in the __post_init__
        scp_args: str = field(init=False, default="")

        def __post_init__(self) -> None:
            """Post initializer of `ScpFile.Parameters`."""
            self.scp_args += " -r" if self.recursive_copy else ""

    @property
    def _depends_on(self) -> list[str]:  # noqa: D102
        return ["symphony campaign"]

    @property
    def name(self) -> str:  # noqa: D102
        return "scp file"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["scp file"]

    @property
    def description(self) -> str:  # noqa: D102
        return "scp a file to a target machine"

    @property
    def config_name(self) -> str:  # noqa: D102
        return "scp file"
