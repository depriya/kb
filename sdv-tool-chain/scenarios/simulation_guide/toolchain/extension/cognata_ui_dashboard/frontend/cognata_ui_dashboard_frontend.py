"""
Copyright (C) Microsoft Corporation.

The `CognataUIDashboardFrontend` extension.
"""


from extension import BaseMetamodelExtension


class CognataUIDashboardFrontend(BaseMetamodelExtension):
    """The `CognataUIDashboardFrontend` extension."""

    @property
    def name(self) -> str:  # noqa: D102
        return "cognata ui dashboard frontend"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["cognata ui dashboard frontend"]

    @property
    def description(self) -> str:  # noqa: D102
        return (
            "The frontend UI code for the simulation dashboard."
            "This extension just contains a common directory."
            "Moving the files from the common directory to the templates directory"
            "will cause an exception when running metamodel execute."
            "This is because of the _execute_template_file_with_parameters when it tries to render"
            "the static frontend files (*.js, *.png, etc)."
            "This extension is a workaround for now."
        )

    @property
    def config_name(self) -> str:  # noqa: D102
        return "cognata ui dashboard frontend"
