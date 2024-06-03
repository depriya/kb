"""
Copyright (C) Microsoft Corporation.

The `symphony campaign` extension.
"""

import os
from dataclasses import dataclass, field
from typing import Any, Iterable, Optional

from extension import BaseMetamodelExtension


class SymphonyCampaign(BaseMetamodelExtension):
    """The `SymphonyCampaign` extension."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """The `SymphonyCampaign` extension parameters."""

        campaign_name: str
        campaign_activation_name: str
        campaign_start_stage_inputs: Optional[dict[str, Any]]

        campaign_file_name: str

        symphony_campaign_parameters_file: str
        symphony_campaign_parameters_file_input: Optional[dict[str, Any]]

        # Will be initialized in __post_init__
        symphony_campaign_parameters_file_path: str = field(init=False)

        symphony_base_url: str = field(
            metadata={
                BaseMetamodelExtension.Parameters.REGEX_METADATA: BaseMetamodelExtension.Parameters.URL_REGEX
            }
        )

        def __post_init__(self) -> None:
            """Post initializer of `SymphonyCampaign.Parameters`."""
            self.symphony_campaign_parameters_file_path = os.path.abspath(
                os.path.join(
                    self.metamodel_directory_path,
                    self.symphony_campaign_parameters_file,
                )
            )
            assert os.path.exists(self.symphony_campaign_parameters_file_path)
            assert os.path.isfile(self.symphony_campaign_parameters_file_path)

    @property
    def name(self) -> str:  # noqa: D102
        return "symphony campaign"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["symphony campaign"]

    @property
    def description(self) -> str:  # noqa: D102
        return (
            "Creates a campaign object and the campaign activation object for Symphony."
        )

    @property
    def config_name(self) -> str:  # noqa: D102
        return "symphony campaign"

    def _execute_referenced_template_with_parameters(
        self, params: "BaseMetamodelExtension.Parameters"
    ) -> Iterable[BaseMetamodelExtension.ExecuteWithParametersOutput]:  # noqa: D102
        if not isinstance(params, self.Parameters):
            raise ValueError(
                f"Expected '{self.Parameters.__name__}' but got '{type(params).__name__}'."
            )

        yield self._execute_template_file_with_parameters(
            filepath=params.symphony_campaign_parameters_file_path,
            params=params.symphony_campaign_parameters_file_input or {},
        )
