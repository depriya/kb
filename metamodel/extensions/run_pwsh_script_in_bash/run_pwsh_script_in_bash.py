#!/usr/bin/env python

# Copyright (C) Microsoft Corporation.

import base64
import json
from dataclasses import dataclass, field
from typing import Any

from extension import BaseMetamodelExtension


class RunPwshScriptInBashExtension(BaseMetamodelExtension):
    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        input_parameter: dict[str, Any]
        input_parameter_to_script: str = field(init=False)

        def __post_init__(self) -> None:
            self.input_parameter_to_script = base64.b64encode(
                json.dumps(self.input_parameter).encode("ascii")
            ).decode("ascii")

    @property
    def _depends_on(self) -> list[str]:
        return ["symphony campaign"]

    EXTENSION_NAME = "avl devops custom extension run pwsh script in bash"

    @property
    def name(self) -> str:
        return self.EXTENSION_NAME

    @property
    def aliases(self) -> list[str]:
        return self.EXTENSION_NAME

    @property
    def description(self) -> str:
        return "This extension runs a powershell script through bash"

    @property
    def config_name(self) -> str:
        return self.EXTENSION_NAME
