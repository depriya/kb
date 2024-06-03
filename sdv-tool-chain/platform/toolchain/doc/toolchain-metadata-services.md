_Copyright (C) Microsoft Corporation_

# Toolchain Metadata Services

Toolchain Metadata Services, which includes a REST Service and a CLI tool, are a set of components that enable the creation and development of metamodels. See [metamodel](./metamodel.md) for the details on what a metamodel is.

Toolchain Metadata Services can be easily extended with custom extensions. See [extension](./extension.md) for more information.

Please, reference the [.vscode/launch.json](../../../.vscode/launch.json) for examples of how to run the Toolchain Metadata Services.

## Types of the Toolchain Metadata Services

There are two types of the Toolchain Metadata Services:

1. **Toolchain Metadata Services CLI Tool** - a command-line interface to run the Toolchain Metadata Services.
1. **Toolchain Metadata Services REST Service** - a RESTful service to run the Toolchain Metadata Services.

## How To Run

The easiest way to run the Toolchain Metadata Services is from the [Dev Container](#dev-container). Please refer to [.devcontainer/devcontainer.json](../../../.devcontainer/devcontainer.json) to see what prerequisites are required to run the Toolchain Metadata Services locally.

### Dev Container

[Dev container](https://code.visualstudio.com/docs/devcontainers/containers) is a Docker container that has all the prerequisites installed to run the Toolchain Metadata Services. The Dev container will run the same way on any platform (Windows, Linux, Mac), and on any computer.

Run [VSCode](https://code.visualstudio.com/docs), open the root folder of the project, and run the Dev Container. See [VSCode documentation](https://code.visualstudio.com/docs/remote/containers) for the details. The setup should be automatic and VSCode will ask you to install the recommended extensions. Please, install them. The only pre-requisite that must be installed outside of VSCode is [Docker](https://docs.docker.com/get-docker/). You can install it on WSL2, if you run Windows, or directly on MacOS, or Linux.

Inside the Dev Container:

1. Select the `Toolchain CLI` or the `Toolchain Service` from `Run and Debug` tab on the left.
1. Run the Toolchain Metadata Services by pressing `F5`, which will launch commands from [.vscode/launch.json](../../../.vscode/launch.json).

## Supported Commands

1. Toolchain Metadata Services CLI Tool - [.vscode/launch.json](../../../.vscode/launch.json) declares a list of commands that can be run directly from the VSCode by pressing `F5`.
1. Toolchain Metadata Services REST Service - [toolchain_service.http](../../../toolchain_service.http) contains a list of requests that Toolchain Metadata REST Service can be called with.

See [vECU Builder Guide](../../../scenarios/vecu_builder_guide/README.md) for the details on the metamodel.

Below is the list of commands that can be run with the Toolchain Metadata Services CLI Tool. The same commands can be run with the Toolchain Metadata Services REST Service. See [toolchain_service.http](../../../toolchain_service.http) for the details.

### Validate Metamodel

```bash
$ ./toolchain_cli.py metamodel validate --from-file ${workspaceFolder}/metamodel/vecu/vecu.yaml \
    [--override OVERRIDE]
```

### Execute Metamodel

```bash
$ ./toolchain_cli.py metamodel execute --from-file ${workspaceFolder}/metamodel/vecu/vecu.yaml \
    [--override OVERRIDE] \
    [--output-dir OUTPUT_DIR="./output"]
```

### Call a single command/extension

```bash
$ ./toolchain_cli.py mock deploy --source http://domain.com/file --destination /tmp/file
```

To see other commands, run

```bash
$ ./toolchain_cli.py help
```

This will list all core and custom [extensions](./extension.md).

To see help for a specific command, for example `metamodel execute`, run

```bash
$ ./toolchain_cli.py metamodel execute --help
usage: metamodel execute [-h] --from-file FROM_FILE [--override OVERRIDE] [--output-dir OUTPUT_DIR]

Executes a metamodel.

options:
  -h, --help            show this help message and exit
  --from-file FROM_FILE
                        File containing a metamodel to execute.
  --override OVERRIDE   (Optional) File containing custom overrides for the metamodel. Parameters in this file will override existing parameters of the metamodel. Adding new parameters or removing existing parameters is not allowed. This is done to ensure that the metamodel is valid before and after applying.
  --output-dir OUTPUT_DIR
                        (Optional) The output will be placed in this directory. Defaults to '/workspaces/sdv-toolchain/apps/toolchain/src/output'.
```
