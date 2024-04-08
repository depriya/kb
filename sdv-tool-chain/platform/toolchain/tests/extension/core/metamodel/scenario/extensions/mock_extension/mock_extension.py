"""
Copyright (C) Microsoft Corporation.

The `mock` extension.

This extension is needed to test the case when 'templates' directory contains '*.py' files,
in which case those files should be ignored. The `templates/some_python_file.py` file
contains a reference to a non-existent module and a function, which should not be executed.
A successful execution of the `mock` extension means that the `templates/some_python_file.py`
is ignored and the extension is loaded successfully.
"""

from extension import BaseMetamodelExtension


class MockExtension(BaseMetamodelExtension):
    """The `Mock` extension."""

    @property
    def _depends_on(self) -> list[str]:  # noqa: D102
        return ["mock nested common"]

    @property
    def name(self) -> str:  # noqa: D102
        return "mock"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["mock"]

    @property
    def description(self) -> str:  # noqa: D102
        return (
            "Mock extension for testing. Does nothing, but validates a case when 'templates' "
            "directory contains '*.py' files."
        )

    @property
    def config_name(self) -> str:  # noqa: D102
        return "mock"
