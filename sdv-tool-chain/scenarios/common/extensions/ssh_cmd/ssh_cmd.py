"""
Copyright (C) Microsoft Corporation.
The `ssh cmd` extension.
"""

import re
from dataclasses import dataclass, field

from extension import BaseMetamodelExtension

"""
The regex for that the bash command must follow. Excludes:
- `"`: quote operator
- `&`: background operator
- `!`: history operator
- `$`: variable subsitution operator
"""
BASH_CMD_REGEX = re.compile(r"^([^\"\&\!\$]+)$")

"""Regex that the working dir path must follow."""
WORKING_DIR_REGEX = re.compile(r"^([a-zA-Z0-9\_\-\/\.\~]+)$")


class SshCmd(BaseMetamodelExtension):
    """The `SshCmd` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `SshCmd` extension parameters."""

        username: str
        password: str
        bash_command: str = field(
            metadata={
                BaseMetamodelExtension.Parameters.REGEX_METADATA: BASH_CMD_REGEX,
            }
        )
        working_dir: str = field(
            metadata={
                BaseMetamodelExtension.Parameters.REGEX_METADATA: WORKING_DIR_REGEX,
            }
        )

    @property
    def _depends_on(self) -> list[str]:  # noqa: D102
        return ["symphony campaign"]

    @property
    def name(self) -> str:  # noqa: D102
        return "ssh cmd"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["ssh cmd"]

    @property
    def description(self) -> str:  # noqa: D102
        return "run a command on a target machine via ssh"

    @property
    def config_name(self) -> str:  # noqa: D102
        return "ssh cmd"
