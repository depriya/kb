import base64
import json
from dataclasses import dataclass, field
from typing import Any

from extension import BaseMetamodelExtension


class RunScriptWithParamsExtension(BaseMetamodelExtension):
    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        input_parameter: dict[str, Any]
        input_parameter_to_script: str = field(init=False)

        def __post_init__(self) -> None:
            # set the value of input_parameter_to_script to the value of input_parameter converted to a json string that is encoded in base64 format
            self.input_parameter_to_script = base64.b64encode(
                json.dumps(self.input_parameter).encode("ascii")
            ).decode("ascii")

    @property
    def _depends_on(self) -> list[str]:
        return ["symphony campaign"]

    @property
    def name(self) -> str:
        return "avl devops custom extension run script with parameters"

    @property
    def aliases(self) -> list[str]:
        return ["avl devops custom extension run script with parameters"]

    @property
    def description(self) -> str:
        return "This extension runs a script with parameters"

    @property
    def config_name(self) -> str:
        return "avl devops custom extension run script with parameters"
