_Copyright (C) Microsoft Corporation_

# Virtual ECU Builder Scenario Setup

- [1. Create a GitHub Classic Personal Access Token for the repo that contains your Yocto OS build workflow](#1-create-a-github-classic-personal-access-token-pat-for-the-repo-that-contains-your-yocto-os-build-workflow)
- [2. Setup your Azure Deployment Environments dev center](#2-setup-your-azure-deployment-environments-dev-center)
- [3. Deploy Azure resources](#3-deploy-azure-resources)

### 1. Create a GitHub Classic Personal Access Token (PAT) for the repo that contains your Yocto OS build workflow

1. Follow this link to your [GitHub personal access tokens](https://github.com/settings/tokens).
1. Generate a classic token with `repo`, `workflow`, and `read:org` permissions. This will be used to dispatch the workflow and check its status.
    >Note: Your organization may impose a policy on a PAT lifetime. Make sure to select a PAT lifetime that does not exceed the limit set by your organization.
1. Copy the token and paste it in [`vECU.resources.ARM.template.parameters.json`](./vECU.resources.ARM.template.parameters.json) as the value for the `workflowGithubPATSecretValue` parameter.
1. Authorize SSO: Go back to the `Personal access tokens (classic)` page. Click the drop down `Configure SSO` and select the org containing the workflow you wish to dispatch.
    > This has to be re-done every time the token is regenerated.
1. Set the PAT expiry date in ISO 8601 datetime format as the value for the `workflowGithubPATSecretExpiry` parameter. Example: '2023-12-31T00:00:00Z'

### 2. Setup your Azure Deployment Environments dev center

See [Azure Deployment Environment](../../../../platform/azure_deployment_environment/README.md) if you are not already familiar with how SDV Toolchain uses ADE.

1. Follow [Azure Deployment Environment Setup](../../../../platform/azure_deployment_environment/ade_setup/README.md) to set up your dev center.

1. Follow [Catalog Setup](../../../../platform/azure_deployment_environment/catalog_setup/README.md) to attach a catalog to your dev center. Use the [catalog sample](../../../../platform/azure_deployment_environment/catalog_setup/catalog_sample/) provided.

### 3. Deploy Azure resources

This scenario uses and depends on a variety of Azure resources. To help you deploy the resources needed to run these samples, this directory provides an ARM template, an ARM template parameters file, and a script that deploys the ARM template with its parameters.

The ARM template creates the following resources:
- An **Email Communication Service** with an **Azure managed domain**. This domain is configured with a custom **MailFrom address**, which is the email address that will be used to send the notification for the completion of deploy vECU campaign.
- A **Communication Service** that is connected to the domain in your Email Communication Service. This enables sending an email triggered by a remote command.
- A **KeyVault**. You are assigned the `Key Vault Administrator` role for the vault. The vault contains:
    - A **secret** that stores a PAT for your GitHub repo that has the workflow you want to run.
    - A **secret** that stores the connection string to your Communication Service, which will be used to send emails.

The ARM template and its deploy script also assign multiple roles to ensure that when the campaigns run their custom scripts, the scripts are able to access the Azure resources described above. In this example, you will be logging in to the Azure CLI before any of the scripts execute. Therefore, you are assigned all of the roles needed for access. However, if you were to adapt this sample to run on a VM, you could configure the VM to have a managed idenity and assign these roles to that identity. The roles needed for access are:
- The `Key Vault Secrets User` role scoped to only the `toolchain-workflow-github-pat` secret. This is needed to allow reading the secret value.
- The `Key Vault Secrets User` role scoped to only the `toolchain-email-connection-string` secret. This is needed to allow reading the secret value.
- The `Reader` and `Deployment Environments User` roles scoped to your ADE project. These are needed to allow creating a new deployment environment.
    > *These roles are scoped to a resource outside of the resource group being deployed to and therefore cannot be assigned within the ARM template. The roles are assigned in [`deploy_azure_resources.sh`](./deploy_azure_resources.sh) after the ARM template is deployed.*
- The `Virtual Machine Contributor` role scoped to your Azure subscription. This is needed to allow reading the IP address of your vECU VM.
    > *This role is scoped to the whole subscription and therefore cannot be assigned within the ARM template. The role is assigned in [`deploy_azure_resources.sh`](./deploy_azure_resources.sh) after the ARM template is deployed.*

> Note: This ARM template assumes that the resources are being deployed to the same Azure subscription as your dev center.

#### Steps to deploy your Azure resources:

1. Retrieve your Azure user principal ID (Object ID). You can find this by navigating to Microsoft Entra ID in Azure Portal, or by running the following commands outside of your devcontainer:
    ```bash
    az login
    az ad signed-in-user show --query id
    ```
    > Run these commands outside of your devcontainer to avoid running into Conditional Access policies that some tenants have that prevent unmanaged devices (like your devcontainer) from running `az ad` commands.

   Copy the ID and paste it as the value for the `userPrincipalID` in [`vECU.resources.ARM.template.parameters.json`](./vECU.resources.ARM.template.parameters.json)  parameter AND in [`deploy_azure_resources.config.sh`](./deploy_azure_resources.config.sh).
1. Replace the remaining placeholder values in [`deploy_azure_resources.config.sh`](./deploy_azure_resources.config.sh) with your own values.
1. Replace the remaining placeholder values in [`vECU.resources.ARM.template.parameters.json`](./vECU.resources.ARM.template.parameters.json) with your own values. Metadata about these parameters can be found in [`vECU.resources.ARM.template.json`](./vECU.resources.ARM.template.json).
1. Check if you are already assigned any of the three roles that will be assigned to you in [`deploy_azure_resources.sh`](./deploy_azure_resources.sh) after the ARM template is deployed. *If the script attempts to reassign you to existing roles, it may fail with a confusing error saying `Your device is required to be managed to access this resource`*. To avoid this, for any of the roles you are already assigned to, remove the role assignment from [`deploy_azure_resources.sh`](./deploy_azure_resources.sh).
1. If you are not already logged in to the Azure CLI, run the following commands in the devcontainer terminal (with your Azure Subscription ID):
    ```bash
    az login --use-device-code --output none
    az account set --subscription <SUBSCRIPTION_ID>
    ```
    You will be prompted to use a web browser to authenticate to Azure.
1. In your devcontainer terminal, run the deploy resources script:
    ```bash
    bash deploy_azure_resources.sh
    ```
