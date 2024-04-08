"""
Copyright (C) Microsoft Corporation.

Extension provider for the toolchain.
"""

import abc
import os


class ExtensionProvider(abc.ABC):
    """
    The extension provider interface.

    See platform/toolchain/doc/design/README.md#extension-discovery for more details.
    """

    def __init__(self, cwd: str = "/"):
        """
        Construct a new instance of the ExtensionProvider.

        `cwd` is a current working directory for the new instance.
        It should be an absolute path to a directory in a local file system.
        It is used to resolve relative paths in `stage_extension()`.

        Raises `ValueError` if `cwd` is not a directory, or is not an absolute path.
        """
        self._cwd = cwd
        if not os.path.isdir(self._cwd):
            raise ValueError(f"cwd '{self._cwd}' is not a directory")

        if not os.path.isabs(self._cwd):
            raise ValueError(f"cwd '{self._cwd}' is not an absolute path")

    def abs_path(self, path: str) -> str:
        """
        Return an absolute path for the given `path`.

        `path` is a path to a file or a directory in a local file system.
        It can be either absolute or relative to the `cwd` of this instance.
        """
        if os.path.isabs(path):
            return path
        return os.path.normpath(os.path.join(self._cwd, path))

    @staticmethod
    @abc.abstractmethod
    def provider_type() -> str:
        """Return a unique name of the provider."""
        pass

    @abc.abstractmethod
    def stage_extensions(self, source_location: str, destination: str) -> None:
        """
        Stages one or more extensions from the `source_location` to the `destination`.

        `source_location` is an implementation-specific location of the extension.
        `destination` is a directory on a local file system where the extension will be staged to.

        Example:
        -------
        1. On a local file system `source_location` is a path to the extension
           and `destination` can be the same, which could result in a no-op
           implementation of this function for a local file system provider.
        2. For an HTTP provider `source_location` is a URL to the location where the extension can be downloaded from.

        Notes:
        -----
        1. `destination` is a directory, not a file, because there may be content to accompany extensions.
           Every extension must implement the `BaseExtension` class.
        2. The application of Toolchain Metadata Services must have read-write permissions to
           the `destination` directory.

        """
        pass
