"""
Copyright (C) Microsoft Corporation.

The `BaseExtension` extension. Abstract class.
"""

import abc
import argparse
import dataclasses
import os
import re
import shutil
import typing
import weakref
from typing import TYPE_CHECKING, Any, Iterable, NamedTuple

from jinja2 import Template

if TYPE_CHECKING:
    from core.application import Application


def get_output_filename(filepath: str) -> str:
    """Return output filename for the given `filepath`."""
    filename = os.path.basename(filepath)
    file_extension = os.path.splitext(filename)[1]
    output_filename = os.path.splitext(filename)[0] if file_extension == ".j2" else filename
    return output_filename


class BaseExtension(abc.ABC):
    """
    The `BaseExtension` extension. Abstract class.

    `Application` will load `Extensions` from a given directory. An `Extension` should
    derive from `BaseExtension` and implement non-optional abstract interfaces.
    """

    def __init__(self, application: "Application", absolute_file_path: str) -> None:
        """
        Construct a final implementation of `BaseExtension`.

        `application` is the application that loaded this extension. This object will keep a `weakref.ref(application)`.

        `file_path` is the absolute path to this extension.
        """
        self.__application = weakref.ref(application)
        self.__absolute_file_path = absolute_file_path

    @property
    def application(self) -> "Application":
        """Return `Application` that loaded this extension."""
        app = self.__application()
        if app is None:
            raise ValueError("self.__application is None. Deallocated?")
        return app

    @property
    def file_path(self) -> str:
        """Return absolute file path to the file from which this extension was loaded."""
        return self.__absolute_file_path

    @property
    def _depends_on(self) -> list[str]:
        """
        List of extension names that this extension depends on.

        See the description of `self.depends_on` for more information.
        """
        return []

    @property
    def depends_on(self) -> Iterable["BaseExtension"]:
        """
        An Iterable collection of extensions that this extension depends on.

        This is a computed method that takes the list of extension names from `self._depends_on`
        and returns an iterable collection of `BaseExtension` instances for the names.

        The final class should not override this method, instead, it should override
        `_depends_on()` property to return the list of string names, if necessary.

        The default behavior is to return an emtpy collection - no dependencies.

        Raises `KeyError` if extension is not found by name.
        """
        unique_names = set(self._depends_on)
        extensions = (self.application.extensions.get_extension_by_alias(name) for name in unique_names)
        return extensions

    @property
    @abc.abstractmethod
    def name(self) -> str:
        """Return the name of the extension."""
        pass

    @property
    @abc.abstractmethod
    def aliases(self) -> list[str]:
        """
        Return aliases of the extension.

        Aliases define how the extension can be called from a command line.
        """
        pass

    @property
    @abc.abstractmethod
    def description(self) -> str:
        """User-friendly description of the extension."""
        pass

    @abc.abstractmethod
    def execute(self, args: list[str]) -> None:
        """Call the extension with optional `args`."""
        raise NotImplementedError()


class BaseMetamodelExtension(BaseExtension, metaclass=abc.ABCMeta):
    """
    The `BaseMetamodelExtension` extension. Abstract class.

    `BaseMetamodelExtension` is a `BaseExtension` that can work with a metamodel.

    See `BaseExtension` for more details.
    """

    ExecuteWithParametersOutput = NamedTuple("ExecuteWithParametersOutput", [("name", str), ("payload", Any)])

    @dataclasses.dataclass
    class Parameters:
        """
        Parameters for the extension.

        The final implementation of `BaseMetamodelExtension` will override `Parameters` class to define
        custom parameters for the extension.

        For example see `src/extension/metamodel/mock/deploy_local/mock_deploy_local.py`
        """

        EXCLUDE_FROM_CMD_ARGS_METADATA = "exclude_from_cmd_args"
        REGEX_METADATA = "regex"

        # URL starts with http:// or https://
        # The 'www.' is optional.
        # [-a-zA-Z0-9@:%._\+~#=]{1,256} captures the domain name
        # \b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)) captures the path or query parameters
        # Examples:
        # http://example.com/path/to/resource
        # http://localhost:8080
        URL_REGEX = re.compile(r"^(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))$")
        MIN_PORT_NUM = 1
        MAX_PORT_NUM = 65535
        # Path to the directory where the metamodel is located
        metamodel_directory_path: str = dataclasses.field(metadata={EXCLUDE_FROM_CMD_ARGS_METADATA: True})

    @property
    @abc.abstractmethod
    def config_name(self) -> str:
        """
        Name of config section for this extension.

        Example:
        -------
        ```yaml
        targets:
            sdv_toolchain_deploy:
                description: sdv-toolchain deploy
                type: mock deploy local
                parameters:
                    destination: /home/toolchain/app/
                    source: https://sdvtoolchain.blob.core.windows.net/sdvtoolchain/sdv-toolchain-0.1.0.tar.gz
        ```

        """
        pass

    @property
    def templates_dir(self) -> str:
        """Return absolute path to the templates directory for the final extension."""
        return os.path.join(os.path.dirname(self.file_path), "templates")

    @property
    def common_dir(self) -> str:
        """
        Return absolute path to the directory with common content.

        If extension `A` depends on extension `B`, then files from extension `B/common` will be
        copied to `output/A/`.
        """
        return os.path.join(os.path.dirname(self.file_path), "common")

    def _execute_template_file_with_parameters(self, filepath: str, params: dict[str, Any]):
        with open(filepath) as fd:
            payload = fd.read()
        rendered = Template(payload).render(parameters=params)
        output_filename = get_output_filename(filepath=filepath)
        return BaseMetamodelExtension.ExecuteWithParametersOutput(name=output_filename, payload=rendered)

    def _execute_referenced_template_with_parameters(
        self, params: "BaseMetamodelExtension.Parameters"
    ) -> Iterable[ExecuteWithParametersOutput]:
        """
        Execute a referenced template file with parameters.

        An implementation of BaseMetamodelExtension will look into the `templates_dir` directory and render every
        `*.j2` file with the final implementation of BaseMetamodelExtension.Parameters. This logic is common for
        all implementations of BaseMetamodelExtension and therefore is implemented here.

        Additionally, an implementation of BaseMetamodelExtension can reference other files through the parameters,
        in which case the final implementation will override this method and call
        `_execute_template_file_with_parameters` for each file that it references.

        Both types of template files will be processed in `self.execute_with_parameters`.
        """
        return []

    def execute_with_parameters(
        self, params: "BaseMetamodelExtension.Parameters"
    ) -> Iterable[ExecuteWithParametersOutput]:
        """Call the extension with `params`."""
        templates_dir = self.templates_dir
        for root, _dirs, files in os.walk(templates_dir):
            for filename in files:
                path = os.path.join(root, filename)
                output = self._execute_template_file_with_parameters(filepath=path, params=params.__dict__)
                dir_name = os.path.relpath(root, templates_dir)
                yield BaseMetamodelExtension.ExecuteWithParametersOutput(
                    name=os.path.join(dir_name, output.name), payload=output.payload
                )

        for output in self._execute_referenced_template_with_parameters(params=params):
            yield output

    def execute(self, args: list[str]) -> None:
        """
        Call the extension with optional `args`.

        This will construct `Parameters` from `args` and call `execute_with_parameters` with it.
        The output of `execute_with_parameters` will be written to the `output_dir` directory.
        """
        parser = argparse.ArgumentParser(prog=self.name, allow_abbrev=False, description=f"Executes the '{self.name}'.")
        default_output_dir = os.path.join(self.application.base_dir, "output")
        parser.add_argument(
            "--output-dir",
            type=str,
            default=default_output_dir,
            required=False,
            help=f"(Optional) The output will be placed in this directory. Defaults to '{default_output_dir}'.",
        )
        for field in dataclasses.fields(self.Parameters):
            if not field.init or field.metadata.get(self.Parameters.EXCLUDE_FROM_CMD_ARGS_METADATA, False):
                continue
            is_optional = typing.get_origin(field.type) is typing.Union and type(None) in typing.get_args(field.type)
            parser.add_argument(
                f"--{field.name}",
                type=str,
                required=not is_optional,
                help=f"{'(Optional) ' if is_optional else ' '}Parameter '{field.name}' for the extension.",
            )
        params = vars(parser.parse_args(args))
        output_dir = params.pop("output_dir")
        os.makedirs(output_dir, exist_ok=True)

        metamodel_parameters = self.create_parameters(metamodel_dir=self.application.base_dir, params=params)
        count = 0
        for output in self.execute_with_parameters(params=metamodel_parameters):
            artifact_output_dir = os.path.join(output_dir, os.path.dirname(output.name))
            os.makedirs(artifact_output_dir, exist_ok=True)
            with open(os.path.join(output_dir, output.name), "w") as f:
                f.write(output.payload)
            print(f"Wrote '{output.name}' to '{output_dir}'.")
            count += 1

        for dependency in self.depends_on:
            if not isinstance(dependency, BaseMetamodelExtension):
                continue

            for filename in os.listdir(dependency.common_dir):
                src_path = os.path.join(dependency.common_dir, filename)
                dst_path = os.path.join(output_dir, filename)
                shutil.copyfile(src=src_path, dst=dst_path)
                print(f"Wrote '{src_path}' to '{output_dir}'.")
                count += 1

        print(f"Extension '{self.name}' produced {count} output(s), which were written to '{output_dir}'.")

    def create_parameters(self, metamodel_dir: str, params: dict[str, Any]) -> "BaseMetamodelExtension.Parameters":
        """
        Validate if extension understands the `params`.

        Returns the `Parameters` object of the target implementation if `params` are valid.

        Raises `ValueError` if `params` is invalid.
        """
        try:
            parameters = self.Parameters(metamodel_directory_path=metamodel_dir, **params)
            self.validate_parameters(parameters)
        except TypeError as e:
            raise ValueError("Invalid parameters:") from e

        return parameters

    def validate_parameters(self, parameters: "BaseMetamodelExtension.Parameters") -> None:
        """
        Validate the values in the 'Parameters' object.

        Raise `ValueError` if any value is invalid.
        """
        invalid_parameters: dict[str, Any] = {}
        for field in dataclasses.fields(self.Parameters):
            val = parameters.__dict__.get(field.name)
            if val is not None:
                regex = field.metadata.get(self.Parameters.REGEX_METADATA)
                if regex is not None and re.match(regex, val) is None:
                    invalid_parameters[field.name] = val
        if len(invalid_parameters) > 0:
            raise ValueError("\n".join(f"Invalid value for {name}: {v}" for (name, v) in invalid_parameters.items()))
