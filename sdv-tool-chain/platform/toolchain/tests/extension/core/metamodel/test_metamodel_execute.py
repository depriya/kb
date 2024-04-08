"""
Copyright (C) Microsoft Corporation.

Tests for the `metamodel execute` extension.
"""

import os
import tempfile
from typing import Any
from unittest import mock

import extension.core.metamodel
from core.application import Application
from extension.core.metamodel.metamodel_execute import MetamodelExecute


def test_execute():  # noqa: D103
    filepath = os.path.abspath(__file__)
    application = Application(filepath)
    application.load_extensions()
    ext = application.extensions.get_extension_by_alias("metamodel execute")
    assert isinstance(ext, MetamodelExecute)

    with tempfile.TemporaryDirectory() as temp_directory:
        output_directory = os.path.join(temp_directory, "toolchain-cli-output")

        # A successful execution should not raise any exceptions
        ext.execute(
            [
                "--from-file",
                os.path.join(os.path.dirname(filepath), "scenario/config.yaml"),
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
            "mock_nested/folder_1/some_file.sh",
            "mock_nested/folder_2/folder_3/some_file_2.sh",
            "mock/some_python_file.py",
            "mock/folder_1_common/folder_2/folder_3/common_file_1.sh",
            "mock/folder_4_common/folder_5/common_file_2.sh",
        ]

        assert set(result_files) == set(expected_files)


def test_execute_with_overrides():  # noqa: D103
    filepath = os.path.abspath(__file__)
    application = Application(filepath)
    application.load_extensions()
    ext = application.extensions.get_extension_by_alias("metamodel execute")
    assert isinstance(ext, MetamodelExecute)

    original_method = extension.core.metamodel.MetamodelFactory.load_metamodel

    def mock_load_metamodel(
        self: extension.core.metamodel.MetamodelFactory, metamodel_dict: dict[str, Any]
    ) -> extension.core.metamodel.Metamodel:
        assert metamodel_dict["config"]["mock"]["message"] == "hi world"
        metamodel = original_method(self, metamodel_dict)
        return metamodel

    with tempfile.TemporaryDirectory() as temp_directory:
        output_directory = os.path.join(temp_directory, "toolchain-cli-output")

        with mock.patch.object(
            extension.core.metamodel.MetamodelFactory,
            "load_metamodel",
            side_effect=mock_load_metamodel,
            autospec=True,
        ) as mocked:  # type: ignore
            # A successful execution should not raise any exceptions
            ext.execute(
                [
                    "--from-file",
                    os.path.join(os.path.dirname(filepath), "scenario/config_with_targets_file.yaml"),
                    "--override",
                    os.path.join(os.path.dirname(filepath), "scenario/config_overrides.yaml"),
                    "--output-dir",
                    output_directory,
                ]
            )
            mocked.assert_called_once()
        # Assert that the override config value was used
        with open(os.path.join(output_directory, "mock_nested/folder_1/some_file.sh"), "r") as file:
            assert "hi world" in file.read()
