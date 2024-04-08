"""
Copyright (C) Microsoft Corporation.

Extension provider for the toolchain.
Implementation for the local file system provider.
"""

import os.path
import shutil

from . import ExtensionProvider


class LocalFileSystemExtensionProvider(ExtensionProvider):
    """Implementation of the ExtensionProvider, which works with a local filesystem."""

    @staticmethod
    def provider_type() -> str:  # noqa: D102
        return "local filesystem"

    def stage_extensions(self, source_location: str, destination: str) -> None:  # noqa: D102
        source_location = self.abs_path(source_location)
        destination = self.abs_path(destination)

        if not os.path.isdir(source_location):
            raise ValueError(f"source_location '{source_location}' is not a directory")

        if os.path.exists(destination):
            # Do nothing if the source and destination are the same
            if os.path.samefile(source_location, destination):
                return

            # Destination exists and it is not the same as the source
            raise ValueError(f"destination '{destination}' already exists")

        # Copy the source to the destination
        shutil.copytree(source_location, destination)
