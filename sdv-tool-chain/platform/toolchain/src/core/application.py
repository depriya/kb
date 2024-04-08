"""
Copyright (C) Microsoft Corporation.

General logic of the main application of Toolchain Metadata Services.
"""

import os
from typing import Mapping

from core.extension_provider import ExtensionProvider
from core.extension_provider.local_filesystem_extension_provider import LocalFileSystemExtensionProvider

from .extensions import Extensions, load_extensions

EXTENSIONS_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "extension")
EXTENSIONS_BASE_PACKAGE = "extension"


class Application:
    """The class that represents a running application."""

    def __init__(self, app_filepath: str) -> None:
        """Construct application and load all extensions from `EXTENSIONS_DIR`."""
        self.__app_filepath = app_filepath
        self.__extensions = Extensions()

    def run(self, args: list[str]) -> None:
        """Run the application with given `args`."""
        str_args = " ".join(args[1:])
        try:
            extension, alias = self.extensions.find_extension_by_command_line_string(str_args)
            args_for_extension = str_args[len(alias) :].strip()
            extension.execute(args_for_extension.split())
        except IndexError:
            print(f"No match found for args: '{str_args}'")
            self.extensions.help.execute([])

    def load_extensions(self, extensions_dir: str = EXTENSIONS_DIR) -> None:
        """Load extensions from the `extensions_dir` and make them available to the application."""
        extensions = load_extensions(self, extensions_dir, EXTENSIONS_BASE_PACKAGE)
        self.__extensions.register_extensions(extensions)

    @property
    def extension_providers(self) -> Mapping[str, type[ExtensionProvider]]:
        """Return all registered extension providers."""
        extension_providers = {LocalFileSystemExtensionProvider.provider_type(): LocalFileSystemExtensionProvider}
        return extension_providers

    @property
    def extensions(self) -> Extensions:
        """Return `Extensions` loaded in this application."""
        return self.__extensions

    @property
    def app_filename(self) -> str:
        """Return `basename` of the application file."""
        return os.path.basename(self.__app_filepath)

    @property
    def base_dir(self) -> str:
        """Return `dirname` of the application file."""
        return os.path.dirname(self.__app_filepath)
