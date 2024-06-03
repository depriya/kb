"""
Copyright (C) Microsoft Corporation.

The `metamodel execute` extension.
"""

import argparse
import os
import shutil

from extension import BaseExtension, BaseMetamodelExtension

from . import MetamodelFactory


class MetamodelExecute(BaseExtension):
    """The `MetamodelExecute` extension."""

    @property
    def name(self) -> str:  # noqa: D102
        return "metamodel execute"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["metamodel execute"]

    @property
    def description(self) -> str:  # noqa: D102
        return (
            "Executes a metamodel.\n"
            f"See '{self.application.app_filename} {self.aliases[0]} --help' for more information."
        )

    def execute(self, args: list[str]):  # noqa: D102
        parser = argparse.ArgumentParser(
            prog="metamodel execute", allow_abbrev=False, description="Executes a metamodel."
        )
        parser.add_argument("--from-file", type=str, required=True, help="File containing a metamodel to execute.")
        parser.add_argument(
            "--override",
            type=str,
            required=False,
            help="(Optional) File containing custom overrides for the metamodel. "
            "Parameters in this file will override existing parameters of the metamodel. "
            "Adding new parameters or removing existing parameters is not allowed. This is "
            "done to ensure that the metamodel is valid before and after applying.",
        )
        default_output_dir = os.path.join(self.application.base_dir, "output")
        parser.add_argument(
            "--output-dir",
            type=str,
            default=default_output_dir,
            required=False,
            help=f"(Optional) The output will be placed in this directory. Defaults to '{default_output_dir}'.",
        )
        params = vars(parser.parse_args(args))
        metamodel_file = params.pop("from_file")
        metamodel = (
            MetamodelFactory(self.application)
            .with_user_overrides(from_file=params.get("override"))
            .load_metamodel_from_yaml_file(yaml_filename=metamodel_file)
        )

        output_dir = params.pop("output_dir")
        os.makedirs(output_dir, exist_ok=True)

        count = 0
        for target_object in metamodel.targets.values():
            target_output_dir = os.path.join(output_dir, target_object.name)

            for output in target_object.extension.execute_with_parameters(params=target_object.parameters):
                artifact_output_dir = os.path.join(target_output_dir, os.path.dirname(output.name))
                os.makedirs(artifact_output_dir, exist_ok=True)
                with open(os.path.join(target_output_dir, output.name), "w") as f:
                    f.write(output.payload)
                print(f"Wrote '{output.name}' to '{target_output_dir}'.")
                count += 1

            for dependency in target_object.extension.depends_on:
                if not isinstance(dependency, BaseMetamodelExtension):
                    continue

                for filename in os.listdir(dependency.common_dir):
                    src_path = os.path.join(dependency.common_dir, filename)
                    dst_path = os.path.join(target_output_dir, filename)

                    if os.path.isdir(src_path):
                        shutil.copytree(src=src_path, dst=dst_path, dirs_exist_ok=True)
                    else:
                        shutil.copyfile(src=src_path, dst=dst_path)
                    print(f"Wrote '{src_path}' to '{target_output_dir}'.")
                    count += 1

        print(f"'{self.name} ({metamodel_file})' produced {count} output(s), which were written to '{output_dir}'.")
