_Copyright (C) Microsoft Corporation_

# Azure Deployment Environments Setup

To get started with Azure Deployment Environments (ADE), you will create a new resource group with a **dev center**, a **project**, and **environment types**.

To assist you in doing so, this directory contains an ARM template, an ARM template parameters file, and a script that deploys the ARM template with its parameters. The ARM template creates the following resources:
* An ADE **dev center** with a system assigned managed identity. A dev center is a collection of projects that require similar settings.
* `Dev` and `Test` **environment types** within the dev center.
* A **project** associated with the dev center. You are assigned the `DevCenter Project Admin` role for this project.
* `Dev` and `Test` **project environment types**. These specify which environment types can be used in this particular project.
    * The environment creator roles are set such that whenever a user creates an environment of either of these types, that user will be assigned a Contributor role for that environment.

## Steps to setup your resources

1. Retrieve your Azure user principal ID (Object ID). You can find this by navigating to Microsoft Entra ID in Azure Portal, or by running the following commands outside of your devcontainer:
    ```bash
    az login
    az ad signed-in-user show --query id
    ```
    > Run these commands outside of your devcontainer to avoid running into Conditional Access policies that some tenants have that prevent unmanaged devices (like your devcontainer) from running `az ad` commands.

   Copy the ID and paste it in [`DevCenter.ARM.template.parameters.json`](./DevCenter.ARM.template.parameters.json) as the value for the `userPrincipalID` parameter.
1. Replace the placeholder values in [`setup_ade.config.sh`](setup_ade.config.sh) with your own values.
1. Fill in the remaining parameter values in [`DevCenter.ARM.template.parameters.json`](./DevCenter.ARM.template.parameters.json) with your own values. Metadata about these parameters can be found in [`DevCenter.ARM.template.json`](./DevCenter.ARM.template.json).
1. If you are not already logged in to the Azure CLI, run the following commands in the devcontainer terminal (with your Azure Subscription ID):
    ```bash
    az login --use-device-code --output none
    az account set --subscription <SUBSCRIPTION_ID>
    ```
    You will be prompted to use a web browser to authenticate to Azure.
1. In your devcontainer terminal, run the setup ade script:
    ```bash
    bash setup_ade.sh
    ```

> Next steps: To use the environment types you have just created, you will need to attach at least one catalog to your dev center. See [Catalog Setup](../catalog_setup/README.md) for more information.
