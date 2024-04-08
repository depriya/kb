_Copyright (C) Microsoft Corporation_

# Dev Center Catalog Setup

A directory in a GitHub repository can serve as a catalog for your dev center. To set this up, you must attach a GitHub repository to your dev center.

To help you setup your catalog, this directory contains an ARM template, an ARM template parameters file, and a script that deploys the ARM template with its parameters. The ARM template creates the following resources:
* A **KeyVault** with a **secret** that stores a PAT for your GitHub repo.
    * You are assigned the `Key Vault Administrator` role for the vault.
    * Your dev center is assigned the `Key Vault Secrets User` role for the secret.
* A **catalog** within your dev center that is configured with metadata about your GitHub repo.

A [sample catalog](./catalog_sample/README.md) is also provided in the directory. You can attach this repo to your dev center to use it as your catalog.

## Steps to setup your catalog
1. Retrieve your Azure user principal ID (Object ID). You can find this by navigating to Microsoft Entra ID in Azure Portal, or by running the following commands outside of your devcontainer:
    ```bash
    az login
    az ad signed-in-user show --query id
    ```
    > Run these commands outside of your devcontainer to avoid running into Conditional Access policies that some tenants have that prevent unmanaged devices (like your devcontainer) from running `az ad` commands.

   Copy the ID and paste it in [`Catolog.Setup.ARM.template.parameters.json`](./Catalog.Setup.ARM.template.parameters.json) as the value for the `userPrincipalID` parameter.
1. Create a GitHub Classic Personal Access Token (PAT) for the GitHub repo you are using as your catalog:
    1. In GitHub, navigate to Settings -> Developer Settings -> Personal access tokens.
    1. Generate a classic token with `repo` permissions.
        >Note: Your organization may impose a policy on a PAT lifetime. Make sure to select a PAT lifetime that does not exceed the limit set by your organization.
    1. Copy the token and paste it in [`Catalog.Setup.ARM.template.parameters.json`](./Catalog.Setup.ARM.template.parameters.json) as the value for the `catalogGithubPATSecretValue` parameter.
    1. Authorize SSO: Go back to the Personal access tokens (classic) page. Click the drop down Configure SSO and select the org containing your repo.
        > This has to be re-done every time the token is regenerated.
    1. Set the PAT expiry date as the value for the `catalogGithubPatSecretExpiry` parameter.
1. Replace the placeholder values in [`setup_catalog.config.sh`](setup_catalog.config.sh) with your own values.
1. Fill in the remaining parameter values in [`Catalog.Setup.ARM.template.parameters.json`](./Catalog.Setup.ARM.template.parameters.json) with your own values. Metadata about these parameters can be found in [`Catalog.Setup.ARM.template.json`](./Catalog.Setup.ARM.template.json).
    * If you are using the provided sample catalog, use the default value for  `catalogGithubRepoDirPath`.
1. If you are not already logged in to the Azure CLI, run the following commands in the devcontainer terminal (with your Azure Subscription ID):
    ```bash
    az login --use-device-code --output none
    az account set --subscription <SUBSCRIPTION_ID>
    ```
    You will be prompted to use a web browser to authenticate to Azure.
1. In your devcontainer terminal, run the setup catalog script:
    ```bash
    bash setup_catalog.sh
    ```

Navigate to your dev center in Azure portal to confirm that your catalog is successfully synced.

> Next steps: See [Creating a Deployment Environment](../create_environment_sample/README.md).
