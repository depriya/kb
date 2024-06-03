_Copyright (C) Microsoft Corporation_

# Toolchain Metadata Services Extension

## Table of Contents

1. [Summary](#summary)
1. [BaseExtension](#baseextension)
1. [BaseMetamodelExtension](#basemetamodelextension)
    1. [Parameters](#parameters)
1. [Extensions Dependencies](#extensions-dependencies)

## Summary

A Toolchain Metadata Services extension is the business logic of a single unit of a [metamodel](./metamodel.md).

Run the command below to get a list of avaliable extensions:

```bash
$ ./toolchain_cli.py help
```

Run the command below to get help on a specific extension:

```bash
$ ./toolchain_cli.py extension <extension-name> --help
```

All extensions are implemented as Python classes under [toolchain/src/extension](../src/extension) directory.

There are two base classes for extensions: [BaseExtension](#baseextension) and [BaseMetamodelExtension](#basemetamodelextension). See [toolchain/src/extension/\_\_init\_\_.py](../src/extension/__init__.py) file for the details on implementation.


## BaseExtension

A final implementation of this base class will introduce a general purpose extension for the Toolchain Metadata Services. An extension based on this class is not meant to be used in a metamodel, but can be used as a command to the Toolchain Metadata Services. An example of such an extension is the `help` extension, or `metamodel validate` extension, or `metamodel execute` extension. See [Supported Commands for the Toolchain Metadata Services](./toolchain-metadata-services.md#supported-commands) for more information. Currently, the extensions implementing `BaseExtension` are located under [toolchain/src/extension/core](../src/extension/core) directory.

Required methods to implement are:

```python
@property
def name(self) -> str:
    """Return the name of the extension."""
    pass

@property
def aliases(self) -> list[str]:
    """
    Return aliases of the extension.

    Aliases define how the extension can be called from a command line.
    """
    pass

@property
def description(self) -> str:
    """User-friendly description of the extension."""
    pass

@abc.abstractmethod
def execute(self, args: list[str]) -> None:
    """Call the extension with optional `args`."""
```

See the [help extension](../src/extension/core/help.py) for an example of the implementation.


## BaseMetamodelExtension

An extension based on this class is a metamodel extension. It is used to implement a target of a metamodel. A class that implements this base can be used directly in a yaml configuration of a metamodel. See [metamodel](./metamodel.md) for the details about metamodel definition and configuration.

See [test_metamodel_validate.py](../tests/extension/core/metamodel/test_metamodel_validate.py) for an example of metamodel implementation and how a metamodel extension is used.

`BaseMetamodelExtension` is based on `BaseExtension`, inherits all of its methods and properties, and implements the `execute` method, so a final class is not required to implement it. A class based on `BaseMetamodelExtension` must implement the following methods:

```python
@property
def name(self) -> str:
    """Return the name of the extension."""
    pass

@property
def aliases(self) -> list[str]:
    """
    Return aliases of the extension.

    Aliases define how the extension can be called from a command line.
    """
    pass

@property
def description(self) -> str:
    """User-friendly description of the extension."""
    pass

@property
def config_name(self) -> str:
    """
    Name of config section for this extension.

    Example:
    -------
    targets:
        description: sdv-toolchain deploy
        type: mock deploy local
        parameters:
            destination: /home/toolchain/app/
            source: https://<SDVTOOLCHAIN>.blob.core.windows.net/sdvtoolchain/sdv-toolchain-0.1.0.tar.gz

    """
    pass
```

See [toolchain/src/extension/core/mock_deploy_local.py](../src/extension/metamodel/mock/deploy_local/mock_deploy_local.py) for an example of the implementation.

An implementation of `BaseMetamodelExtension` can have one or more templates. See [extension template](./extension-template.md) for more information.

### Parameters

An extension based on the `BaseMetamodelExtension` class can implement `Parameters` class if it needs to accept parameters from a metamodel.

There is support to add regex validation for a parameter. When defining the parameter in the implementation of `BaseMetamodelExtension.Parameters`, give it metadata named `BaseMetamodelExtension.Parameters.REGEX_METADATA` with the compiled regex as the value. See the [github_dispatch_workflow extension](../../../scenarios/common/extensions/github_dispatch_workflow/github_dispatch_workflow.py) for a complete example.

```python
...
@dataclass
class Parameters(BaseMetamodelExtension.Parameters):
    """The `GithubDispatchWorkflow` extension parameters."""

    repo_owner: str = field(metadata={BaseMetamodelExtension.Parameters.REGEX_METADATA: GITHUB_FORMAT_REGEX})
    repo_name: str = field(metadata={BaseMetamodelExtension.Parameters.REGEX_METADATA: GITHUB_FORMAT_REGEX})
...
```


## Extensions Dependencies

An extension can declare dependencies on other extensions. To do that, an extension must override the `_depends_on()` method and return a list of extension names that it depends on. The Toolchain Metadata Services will verify that all dependencies are loaded before the extension is executed.

When an extension with dependencies is executed, all common content from the extensions it depends on will be copied to the output directory. The common content of an extension is defined by the `common_dir` property of the extension. An extension that another extension depends on *must* have common content. See [BaseMetamodelExtension.common_dir](../src/extension/__init__.py) and [MetamodelExecute.execute()](../src/extension/core/metamodel/metamodel_execute.py) for implementation details.

An example of extension depenedency can be found in the [`github_dispatch_workflow`](../../../scenarios/common/extensions/github_dispatch_workflow/github_dispatch_workflow.py) extension, which depends on the [`symphony campaign`](../../../scenarios/common/extensions/symphony/campaign/symphony_campaign.py) extension. To see how files are copied to the output directory, execute the `github dispatch workflow` extension using the [Toolchain Metadata Services CLI Tool](toolchain-metadata-services.md#call-a-single-commandextension) and check the output directory.
