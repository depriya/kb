"""
Copyright (C) Microsoft Corporation.

The common logic for working with metamodels
"""

import os
from dataclasses import dataclass
from types import MappingProxyType
from typing import Any, NamedTuple, Optional, Union

import yaml
from common.helpers import update_dictionary_deep
from core.application import Application
from core.extension_provider import ExtensionProvider
from extension import BaseMetamodelExtension
from jinja2 import Template


class MetamodelExtensionProviders:
    """
    The class is responsible for managing metamodel extension providers.

    It initializes the providers based on a given configuration and provides methods to stage and load extensions.
    """

    def __init__(self, application: Application, cwd: str, extension_providers_config: list[dict[str, Any]]) -> None:
        """
        Create a new MetamodelExtensionProviders and initialize the providers.

        `application` is an instance of the `Application` class.
        `cwd` is a current working directory for the extension providers.
        `extension_providers_config` is a list of dictionaries with the configuration of the extension providers
            (`metamodel_dict["extensions"]`).
        """
        self.__application = application
        self.__cwd = cwd or "/"

        ExtensionProviderConfig = NamedTuple(
            "ExtensionProviderConfig", [("provider", str), ("location", str), ("staging_directory", str)]
        )
        ExtensionProviderWithConfig = NamedTuple(
            "ExtensionProviderWithConfig", [("provider", ExtensionProvider), ("config", ExtensionProviderConfig)]
        )

        self.__extension_providers: list[ExtensionProviderWithConfig] = [
            ExtensionProviderWithConfig(
                provider=self.__init_extension_provider(provider_config["provider"]),
                config=ExtensionProviderConfig(**provider_config),
            )
            for provider_config in extension_providers_config
        ]

    def __init_extension_provider(self, name: str) -> ExtensionProvider:
        provider_class = self.__application.extension_providers.get(name)
        if provider_class is None:
            raise NotImplementedError(f"ExtensionProvider.provider_type() = '{name}' is not implemented.")

        provider = provider_class(cwd=self.__cwd)
        return provider

    def stage_extensions(self) -> None:
        """Stage all extensions of all providers."""
        for extension_provider in self.__extension_providers:
            extension_provider.provider.stage_extensions(
                source_location=extension_provider.config.location,
                destination=extension_provider.config.staging_directory,
            )

    def load_extensions(self) -> None:
        """Load all extensions of all providers into the application."""
        for extension_provider in self.__extension_providers:
            self.__application.load_extensions(
                extensions_dir=extension_provider.provider.abs_path(extension_provider.config.staging_directory)
            )


@dataclass(frozen=True)
class MetamodelTarget:
    """A metamodel target."""

    name: str
    description: str
    type: str
    extension: BaseMetamodelExtension
    parameters: BaseMetamodelExtension.Parameters
    depends_on: list[str]


MetamodelConfig = dict[str, Any]


class Metamodel:
    """A metamodel."""

    def __init__(self, config: MetamodelConfig, targets: dict[str, MetamodelTarget]) -> None:
        """
        Create a new metamodel. The created metamodel is guaranteed to be valid.

        Raises a `ValueError` if the metamodel is invalid.
        """
        self.__config = config
        self.__targets = MappingProxyType(targets)
        self.__validate()

    @property
    def config(self) -> MetamodelConfig:
        """Get the config of the metamodel."""
        return self.__config

    @property
    def targets(self) -> MappingProxyType[str, MetamodelTarget]:
        """Get the targets of the metamodel."""
        return self.__targets

    def __validate(self) -> None:
        self.__validate_metamodel_unknown_dependencies()

    def __validate_metamodel_unknown_dependencies(self) -> None:
        Dependency = NamedTuple("Dependency", [("target_name", str), ("depends_on", str)])

        # Validate that all dependencies are known
        unknown_dependencies = [
            Dependency(target_name, dependency_name)
            for target_name, target_object in self.targets.items()
            for dependency_name in target_object.depends_on
            if dependency_name not in self.targets.keys()
        ]

        if len(unknown_dependencies) > 0:
            raise ValueError(f"Unknown dependencies: {unknown_dependencies}")


class MetamodelFactory:
    """A factory for creating Metamodel instances."""

    def __init__(self, application: Application) -> None:
        """Create a new MetamodelFactory."""
        self.__application = application
        self.__metamodel_filename = None
        self.__user_overrides_file = None

    def __load_metamodel_targets_from_dict(self, targets: dict[str, Any]) -> dict[str, MetamodelTarget]:
        targets = {
            target_name: MetamodelTarget(
                name=target_name,
                description=target_object["description"],
                type=target_object["type"],
                extension=extension,
                parameters=extension.create_parameters(
                    metamodel_dir=self.metamodel_dir, params=target_object.get("parameters", {})
                ),
                depends_on=target_object.get("depends_on", []),
            )
            for target_name, target_object in targets.items()
            for extension in [self.__application.extensions.get_extension_by_config_name(target_object["type"])]
        }
        return targets

    def __load_metamodel_targets(
        self, config: MetamodelConfig, targets: Union[str, dict[str, Any]]
    ) -> dict[str, MetamodelTarget]:
        if isinstance(targets, str):
            filename = os.path.join(self.metamodel_dir, targets)
            with open(filename, "r") as fd:
                payload = fd.read()
            file_extension = os.path.splitext(filename)[1]
            if file_extension == ".j2":
                payload = Template(payload).render(env=os.environ, config=config)

            targets_dict = yaml.safe_load(payload)

        else:
            # Parse as dictionary
            targets_dict = targets

        return self.__load_metamodel_targets_from_dict(targets=targets_dict)

    @property
    def metamodel_filename(self) -> Optional[str]:
        """
        Get the absolute path to filename of the metamodel that was last loaded.

        return None if the metamodel was not loaded from a file.
        """
        return self.__metamodel_filename

    @metamodel_filename.setter
    def metamodel_filename(self, value: Optional[str]) -> None:
        self.__metamodel_filename = value
        if value:
            self.__metamodel_filename = os.path.abspath(value)

    @property
    def metamodel_dir(self) -> str:
        """Get the directory of the metamodel that was last loaded."""
        return "" if not self.metamodel_filename else os.path.dirname(self.metamodel_filename)

    def with_user_overrides(self, from_file: Optional[str]) -> "MetamodelFactory":
        """
        Set the user overrides file.

        `from_file` is the absolute path to the YAML file containing the user overrides.
        The user overrides can only override existing parameters. It cannot add new parameters or remove existing
        parameters.

        Returns `self`.
        """
        self.__user_overrides_file = from_file
        return self

    def load_metamodel_from_yaml_file(self, yaml_filename: str) -> Metamodel:
        """
        Load a metamodel from a YAML file referenced by `yaml_filename`.

        See `load_metamodel_from_yaml` for more information.
        """
        with open(yaml_filename, "r") as yaml_file:
            payload = yaml_file.read()

        metamodel = self.load_metamodel_from_yaml(yaml_string=payload, metamodel_file=yaml_filename)
        return metamodel

    def load_metamodel_from_yaml(self, yaml_string: str, metamodel_file: str = "") -> Metamodel:
        """
        Load a metamodel from a YAML string.

        See `load_metamodel` for more information.

        Raises a `ValueError` if the metamodel is invalid, or cannot apply the user overrides.
        """
        self.metamodel_filename = metamodel_file
        metamodel_dict = yaml.safe_load(yaml_string)

        if self.__user_overrides_file:
            with open(self.__user_overrides_file, "r") as fd:
                user_overrides = yaml.safe_load(fd.read())
            update_dictionary_deep(metamodel_dict, user_overrides)

        metamodel = self.load_metamodel(metamodel_dict)

        return metamodel

    def load_metamodel(self, metamodel_dict: dict[str, Any]) -> Metamodel:
        """
        Load a metamodel from a dictionary object.

        The metamodel may reference extension providers. The extension providers will be initialized, the extensions
        will be staged and loaded into the application.

        Returns a loaded metamodel. All targets of the metamodel are resolved and an extension is assigned to each.
        The returned metamodel is guaranteed to be valid.

        Raises a `ValueError` if the metamodel is invalid.
        """
        extension_providers = MetamodelExtensionProviders(
            application=self.__application,
            cwd=self.metamodel_dir,
            extension_providers_config=metamodel_dict.get("extensions", {}).get("providers", []),
        )
        extension_providers.stage_extensions()
        extension_providers.load_extensions()

        try:
            config = MetamodelConfig(metamodel_dict.get("config", {}))
            targets = self.__load_metamodel_targets(config=config, targets=metamodel_dict["targets"])
            metamodel = Metamodel(config=config, targets=targets)
        except KeyError as e:
            raise ValueError(f"Invalid metamodel: unknown key '{e.args[0]}'") from e

        return metamodel
