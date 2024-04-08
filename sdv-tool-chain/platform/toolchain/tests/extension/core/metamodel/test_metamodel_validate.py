"""
Copyright (C) Microsoft Corporation.

Tests for the `metamodel validate` extension.
"""

import os
import tempfile
from typing import Any
from unittest import mock

import extension.core.metamodel
import pytest
from core.application import Application
from extension.core.metamodel.metamodel_validate import MetamodelValidate


def test_validate():  # noqa: D103
    filepath = os.path.abspath(__file__)
    application = Application(filepath)
    application.load_extensions()
    ext = application.extensions.get_extension_by_alias("metamodel validate")
    assert isinstance(ext, MetamodelValidate)

    # A successful execution should not raise any exceptions
    ext.execute(["--from-file", os.path.join(os.path.dirname(filepath), "scenario/config.yaml")])


def test_validate_with_override():  # noqa: D103
    filepath = os.path.abspath(__file__)
    application = Application(filepath)
    application.load_extensions()
    ext = application.extensions.get_extension_by_alias("metamodel validate")
    assert isinstance(ext, MetamodelValidate)

    original_method = extension.core.metamodel.MetamodelFactory.load_metamodel

    def mock_load_metamodel(
        self: extension.core.metamodel.MetamodelFactory, metamodel_dict: dict[str, Any]
    ) -> extension.core.metamodel.Metamodel:
        assert metamodel_dict["config"]["mock"]["message"] == "hi world"
        metamodel = original_method(self, metamodel_dict)
        return metamodel

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
                os.path.join(os.path.dirname(filepath), "scenario/config.yaml"),
                "--override",
                os.path.join(os.path.dirname(filepath), "scenario/config_overrides.yaml"),
            ]
        )
        mocked.assert_called_once()


def test_validate_fails_if_target_refs_unknown_extensions():  # noqa: D103
    filepath = os.path.abspath(__file__)
    application = Application(filepath)
    application.load_extensions()
    ext = application.extensions.get_extension_by_alias("metamodel validate")
    assert isinstance(ext, MetamodelValidate)

    config_file = "scenario/config.yaml"

    original_method = extension.core.metamodel.MetamodelFactory.load_metamodel

    def mock_load_metamodel(
        self: extension.core.metamodel.MetamodelFactory, metamodel_dict: dict[str, Any]
    ) -> extension.core.metamodel.Metamodel:
        del metamodel_dict["extensions"]
        metamodel = original_method(self, metamodel_dict)
        return metamodel

    with mock.patch.object(
        extension.core.metamodel.MetamodelFactory,
        "load_metamodel",
        side_effect=mock_load_metamodel,
        autospec=True,
    ) as mocked:  # type: ignore
        with pytest.raises(ValueError, match="Invalid metamodel: unknown key 'mock'"):
            ext.execute(["--from-file", os.path.join(os.path.dirname(filepath), config_file)])
        mocked.assert_called_once()


def test_validate_fails_if_extension_refs_unknown_extension_dependency():  # noqa: D103
    # Remove the "mock nested common" extension from the list of extensions.
    # The "mock" extension depends on the "mock nested common" extension.
    original_method = extension.core.metamodel.MetamodelExtensionProviders.load_extensions
    extension_name_to_remove = "mock nested common"

    def mock_load_extensions(self: extension.core.metamodel.MetamodelExtensionProviders):
        original_method(self)
        try:
            del application.extensions._Extensions__extensions_per_alias[extension_name_to_remove]  # type: ignore
        except KeyError:
            # Must explicitly fail on this KeyError because the test case is expecting a KeyError when checking
            # dependencies.
            pytest.fail(f"Extension with alias '{extension_name_to_remove}' does not exist.")

    filepath = os.path.abspath(__file__)
    application = Application(filepath)
    application.load_extensions()
    ext = application.extensions.get_extension_by_alias("metamodel validate")
    assert isinstance(ext, MetamodelValidate)

    with mock.patch.object(
        extension.core.metamodel.MetamodelExtensionProviders,
        "load_extensions",
        side_effect=mock_load_extensions,
        autospec=True,
    ) as mocked:  # type: ignore
        with pytest.raises(KeyError, match=str(extension_name_to_remove)):
            ext.execute(["--from-file", os.path.join(os.path.dirname(filepath), "scenario/config.yaml")])

        mocked.assert_called_once()


def test_validate_with_different_staging_directory():  # noqa: D103
    filepath = os.path.abspath(__file__)
    application = Application(filepath)
    application.load_extensions()
    ext = application.extensions.get_extension_by_alias("metamodel validate")
    assert isinstance(ext, MetamodelValidate)

    config_file = "scenario/config.yaml"

    # Change the staging directory to a different location
    # The corresponding section of the `config_file` will looks like this after the change:
    # extensions:
    #   - provider: local filesystem
    #     location: ./extensions
    #     staging_directory: /tmp/{temp_dir}/staging_directory
    # Note: the {temp_dir} will be replaced with a temporary directory name
    # Note: the temp_directory will be deleted after the test. See tempfile.TemporaryDirectory.
    original_method = extension.core.metamodel.MetamodelFactory.load_metamodel

    with tempfile.TemporaryDirectory() as temp_directory:
        staging_directory = os.path.join(temp_directory, "staging_directory")

        def mock_load_metamodel(
            self: extension.core.metamodel.MetamodelFactory, metamodel_dict: dict[str, Any]
        ) -> extension.core.metamodel.Metamodel:
            metamodel_dict["extensions"]["providers"][0]["staging_directory"] = staging_directory
            metamodel = original_method(self, metamodel_dict)
            return metamodel

        with mock.patch.object(
            extension.core.metamodel.MetamodelFactory,
            "load_metamodel",
            side_effect=mock_load_metamodel,
            autospec=True,
        ) as mocked:  # type: ignore
            ext.execute(["--from-file", os.path.join(os.path.dirname(filepath), config_file)])
            mocked.assert_called_once()

            # We will only check that the staging_directory exists.
            # No need to check that the content is as it should be because
            # the successfull execution of the `metamodel validate` extension implies that
            assert os.path.isdir(staging_directory)


def test_validate_fails_if_target_refs_unknown_target_dependency():  # noqa: D103
    # Remove the "mock" target from the list of targets.
    # The "mock_nested" target depends on the "mock" target.
    original_method = extension.core.metamodel.MetamodelFactory.load_metamodel
    target_name_to_remove = "mock"

    def mock_load_metamodel(
        self: extension.core.metamodel.MetamodelFactory, metamodel_dict: dict[str, Any]
    ) -> extension.core.metamodel.Metamodel:
        del metamodel_dict["targets"][target_name_to_remove]
        metamodel = original_method(self, metamodel_dict)
        return metamodel

    filepath = os.path.abspath(__file__)
    application = Application(filepath)
    application.load_extensions()
    ext = application.extensions.get_extension_by_alias("metamodel validate")
    assert isinstance(ext, MetamodelValidate)

    with mock.patch.object(
        extension.core.metamodel.MetamodelFactory,
        "load_metamodel",
        side_effect=mock_load_metamodel,
        autospec=True,
    ) as mocked:  # type: ignore
        with pytest.raises(ValueError, match=str(target_name_to_remove)):
            ext.execute(["--from-file", os.path.join(os.path.dirname(filepath), "scenario/config.yaml")])

        mocked.assert_called_once()
