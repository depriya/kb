_Copyright (C) Microsoft Corporation_

# SDV Toolchain Platform: Azure Deployment Environment

Azure Deployment Environments (ADE) allow a team to quickly and easily deploy consistent and secure environments.

Platform engineers use ARM templates describing Azure resources to provide **environment definitions**. The templates that are available for a team's project are stored in a **catalog**. When a developer needs a new environment, they specify:
* An environment definition from the catalog
* The type of environment (i.e. dev, testing, staging, prod)

An environment with all of the configurations that developer needs is then created.

See the [Azure Deployment Environments public documentation](https://learn.microsoft.com/en-us/azure/deployment-environments/concept-environments-key-concepts) for more information.

## ADE for SDV Toolchain

Azure Deployment Environments can be used to host any compute targets for SDV Toolchain scenarios.

See [Azure Deployment Environments Setup](./ade_setup/README.md) for instructions for setting up your ADE resources.

See [Catalog Setup](./catalog_setup/README.md) for instructions for attaching a catalog with environment definitions to your dev center.

Once your setup is done, see [Creating a Deployment Environment](./create_environment_sample/README.md) for instructions on how to create a new environment.
