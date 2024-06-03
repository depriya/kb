"""
Copyright (C) Microsoft Corporation.

The `metamodel validate` extension.
"""

import argparse

from extension import BaseExtension

from . import MetamodelFactory


class MetamodelValidate(BaseExtension):
    """The `MetamodelValidate` extension."""

    @property
    def name(self) -> str:  # noqa: D102
        return "metamodel validate"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["metamodel validate"]

    @property
    def description(self) -> str:  # noqa: D102
        return (
            "Validates a metamodel.\n"
            f"See '{self.application.app_filename} {self.aliases[0]} --help' for more information."
        )

    def execute(self, args: list[str]):  # noqa: D102
        parser = argparse.ArgumentParser(
            prog="metamodel validate", allow_abbrev=False, description="Validates a metamodel."
        )
        parser.add_argument("--from-file", type=str, required=True, help="File containing a metamodel to validate.")
        parser.add_argument(
            "--override",
            type=str,
            required=False,
            help="(Optional) File containing custom overrides for the metamodel. "
            "Parameters in this file will override existing parameters of the metamodel. "
            "Adding new parameters or removing existing parameters is not allowed. This is "
            "done to ensure that the metamodel is valid before and after applying.",
        )
        params = vars(parser.parse_args(args))
        metamodel = (
            MetamodelFactory(self.application)
            .with_user_overrides(from_file=params.get("override"))
            .load_metamodel_from_yaml_file(yaml_filename=params["from_file"])
        )

        # Go through all targets and check that the dependencies are valid.
        # An invalid dependency will raise an exception.
        for target_object in metamodel.targets.values():
            _dependencies = list(target_object.extension.depends_on)

        print("Metamodel is valid.")
