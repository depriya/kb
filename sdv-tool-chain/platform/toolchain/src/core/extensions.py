"""
Copyright (C) Microsoft Corporation.

General logic to work with extensions is hosted here.
"""

import importlib.util
import inspect
import os
import sys
import typing
from functools import reduce
from typing import TYPE_CHECKING, Iterable, Tuple

from extension import BaseExtension, BaseMetamodelExtension

if TYPE_CHECKING:
    from core.application import Application


class Extensions:
    """Extensions class exports helper methods to work with extensions declared in `./extension/` folder."""

    def __init__(self) -> None:
        """Construct `Extensions` object."""
        self.__extensions: list[BaseExtension] = []
        self.__extensions_per_alias: dict[str, BaseExtension] = {}
        self.__extensions_per_config_name: dict[str, BaseExtension] = {}

    @property
    def help(self) -> BaseExtension:
        """Retuns `help` extension."""
        return self.__extensions_per_alias["help"]

    def register_extensions(self, extensions: Iterable[BaseExtension]) -> None:
        """
        Register `extensions` and make them available through the methods of this class.

        Raises ValueError in case of name collision or if extension dependency is not met.
        """
        self.__extensions.extend(extensions)
        self.__extensions.sort(key=lambda x: x.aliases)
        all_aliases = ((attr, ext) for ext in self.__extensions for attr in ext.aliases)
        extensions_per_alias = _get_extensions_per_attribute(all_aliases)
        _detect_collisions(extensions_per_alias, "aliases")

        all_config_names = (
            (ext.config_name, ext) for ext in self.__extensions if isinstance(ext, BaseMetamodelExtension)
        )
        extensions_per_config_name = _get_extensions_per_attribute(all_config_names)
        _detect_collisions(extensions_per_config_name, "config_name")

        self.__extensions_per_alias = {k: v[0] for k, v in extensions_per_alias.items()}
        self.__extensions_per_config_name = {k: v[0] for k, v in extensions_per_config_name.items()}

        _validate_dependencies(self.__extensions)

    def get_extension_by_alias(self, alias: str) -> BaseExtension:
        """
        Return extension by a given alias. See `BaseExtension.aliases`.

        Raises `KeyError` if alias cannot be found.
        """
        return self.__extensions_per_alias[alias]

    def get_extension_by_config_name(self, config_name: str) -> BaseMetamodelExtension:
        """
        Return extension by a given config name. See `BaseExtension.config_name`.

        Raises `KeyError` if `config_name` cannot be found.
        """
        return typing.cast(BaseMetamodelExtension, self.__extensions_per_config_name[config_name])

    def find_extension_by_command_line_string(self, args: str) -> Tuple[BaseExtension, str]:
        """
        Return tuple of extension and alias (one of `BaseExtension.aliases`).

        raises IndexError if no extension found.
        """
        all_aliases = ((ext, alias) for ext in self.__extensions for alias in ext.aliases if args.startswith(alias))

        # Get the first longest match by alias or raise IndexError if no match found
        ext, alias = sorted(all_aliases, key=lambda x: len(x[1]), reverse=True)[0]

        return ext, alias

    def collect_extensions(self, base_alias: str) -> Iterable[BaseExtension]:
        """Return an iterable over extensions that start with the `base_alias`."""
        return self.__extensions


def load_extensions(
    application: "Application", extensions_dir: str, extensions_base_package: str
) -> Iterable[BaseExtension]:
    r"""
    Load all extensions from `*.py` files at a given `extensions_dir` recursivelly.

    Extension should implement the `BaseExtension` interface.
    This function loads a file and calls the constructor of the extension with
    a reference to `application`. The extension will keep a `weakref.ref` to the `application`.
    All loaded files will be inserted in `sys.modules[f'{extensions_base_package}.{relative_package}.{name}']`

    Return an iterable over `BaseExtension`.
    """
    directories_to_skip: list[str] = []

    for root, _dirs, files in os.walk(top=extensions_dir, topdown=True):
        for filename in files:
            # Skip non-python files and __init__.py
            if not filename.endswith(".py") or filename == "__init__.py":
                continue

            # Skip files in directories that are marked to be skipped.
            # This is needed to avoid loading '*.py' files from the `templates` directory of an extension.
            if root in directories_to_skip:
                continue

            full_path = os.path.join(root, filename)
            module_name = ".".join(
                (
                    extensions_base_package,
                    os.path.relpath(os.path.splitext(full_path)[0], extensions_dir).replace(os.sep, "."),
                )
            )

            mod = sys.modules.get(module_name)

            if not mod:
                spec = importlib.util.spec_from_file_location(module_name, full_path)
                if not spec:
                    raise ValueError(f"Cannot load extension from file {full_path}")
                mod = importlib.util.module_from_spec(spec)
                sys.modules[module_name] = mod
                spec_loader = spec.loader
                if not spec_loader:
                    raise ValueError(f"spec.loader is None for extension file {full_path}")
                spec_loader.exec_module(mod)

            for _class_name, class_obj in inspect.getmembers(mod, inspect.isclass):
                if issubclass(class_obj, BaseExtension) and not inspect.isabstract(class_obj):
                    try:
                        obj = class_obj(application, full_path)
                        if isinstance(obj, BaseMetamodelExtension):
                            directories_to_skip.append(obj.templates_dir)
                        yield obj
                    except TypeError as e:
                        raise TypeError(f"Failed to instantiate extension {class_obj} from file {full_path}") from e


def _get_extensions_per_attribute(
    extensions_per_attribute: Iterable[Tuple[str, BaseExtension]],
) -> dict[str, list[BaseExtension]]:
    def _add_to_dict(
        acc: dict[str, list[BaseExtension]], cur: Tuple[str, BaseExtension]
    ) -> dict[str, list[BaseExtension]]:
        attr, ext = cur
        if attr in acc:
            acc[attr].append(ext)
        else:
            acc[attr] = [ext]
        return acc

    dct = reduce(_add_to_dict, extensions_per_attribute, {})

    return dct


def _detect_collisions(extensions_per_attribute: dict[str, list[BaseExtension]], attribute_name: str):
    dups = list(filter(lambda x: len(x[1]) > 1, extensions_per_attribute.items()))

    if dups:
        raise ValueError(
            f"Multiple extensions declare the same attribute '{attribute_name}':\n" "\n".join(
                f"'{alias}', declared in extensions = {', '.join(e.file_path for e in ext)}" for alias, ext in dups
            )
        )


def _validate_dependencies(extensions: list[BaseExtension]) -> None:
    """Validate that all dependencies are present."""
    extensions_names = [ext.name for ext in extensions]
    missing_dependencies = [(ext, d) for ext in extensions for d in ext._depends_on if d not in extensions_names]  # type: ignore

    if missing_dependencies:
        raise ValueError(
            "Missing dependencies in extensions:\n" "\n".join(
                f"{ext} depends on {d}, but {d} is not present." for ext, d in missing_dependencies
            )
        )
