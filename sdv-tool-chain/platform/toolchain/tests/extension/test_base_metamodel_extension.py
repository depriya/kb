"""
Copyright (C) Microsoft Corporation.

Tests for the BaseMetalmodelExtension.
"""

import os
import re
import tempfile
from dataclasses import dataclass, field

import pytest
from core.application import Application
from extension import BaseMetamodelExtension

MOCK_REGEX = re.compile(r"^[a-zA-Z]+$")


class MockExtension(BaseMetamodelExtension):
    """Mock extension for testing."""

    @dataclass
    class Parameters(BaseMetamodelExtension.Parameters):
        """Mock parameters for extension for testing."""

        mock_field_with_regex_1: str = field(metadata={BaseMetamodelExtension.Parameters.REGEX_METADATA: MOCK_REGEX})
        mock_field_with_regex_2: str = field(metadata={BaseMetamodelExtension.Parameters.REGEX_METADATA: MOCK_REGEX})

    @property
    def name(self) -> str:  # noqa: D102
        return "mock"

    @property
    def aliases(self) -> list[str]:  # noqa: D102
        return ["mock"]

    @property
    def description(self) -> str:  # noqa: D102
        return "Mock."

    @property
    def config_name(self) -> str:  # noqa: D102
        return "mock"


def test_create_and_validate_parameters_regex():  # noqa: D103
    application = Application(os.path.abspath(__file__))
    mock_instance = MockExtension(application, os.path.abspath(__file__))

    params = {"mock_field_with_regex_1": "hello", "mock_field_with_regex_2": "world"}
    mock_instance.create_parameters("", params)


def test_create_and_validate_parameters_regex_invalid():  # noqa: D103
    application = Application(os.path.abspath(__file__))
    mock_instance = MockExtension(application, os.path.abspath(__file__))

    params = {"mock_field_with_regex_1": "1234", "mock_field_with_regex_2": "5678"}
    with pytest.raises(
        ValueError,
        match=("Invalid value for mock_field_with_regex_1: 1234\n" "Invalid value for mock_field_with_regex_2: 5678"),
    ):
        mock_instance.create_parameters("", params)


def test_execute():  # noqa: D103
    filepath = os.path.abspath(__file__)

    application = Application(filepath)
    application.load_extensions(f"{application.base_dir}/core/metamodel/scenario/extensions/mock_nested_extension")
    ext = application.extensions.get_extension_by_alias("mock nested")

    with tempfile.TemporaryDirectory() as temp_directory:
        output_directory = os.path.join(temp_directory, "toolchain-cli-output")

        # A successful execution should not raise any exceptions
        ext.execute(
            [
                "--message",
                "hello world",
                "--output-dir",
                output_directory,
            ]
        )

        # Assert that the output directory exists and contains the expected files
        result_files: list[str] = []
        for root, _dirs, files in os.walk(output_directory):
            sub_dir = os.path.relpath(root, output_directory)
            result_files.extend([os.path.join(sub_dir, file) for file in files])
        expected_files = [
            "folder_1/some_file.sh",
            "folder_2/folder_3/some_file_2.sh",
        ]
        print(result_files)

        assert set(result_files) == set(expected_files)
