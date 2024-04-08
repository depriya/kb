_Copyright (C) Microsoft Corporation_

# Creating a Deployment Environment

Prerequisites:
* [Azure Deployment Environment Setup](../ade_setup/README.md)
* [Catalog Setup](../catalog_setup/README.md)

To create a deployment environment, you will need to provide parameter values for the ARM template in your catalog. To assist you in doing so, this directory provides the following:
* Two templates of parameter files that can be used with the ARM template to create different environments:
  * [`new-vnet.ARM.template.parameters.json`](./new-vnet.ARM.template.parameters.json): A new VNet is created and attached to the VM.
  * [`existing-vnet.ARM.template.parameters.json`](./existing-vnet.ARM.template.parameters.json): An existing VNet in a different resource group is attached to the VM.
* A [script](./create_environment.sh) that creates a new environment using one of the parameters files, and the script's [config file](./create_environment.config.sh).

## Steps to create your deployment environment

1. In whichever parameters file you wish to use, replace the placeholder values with your own. Metadata about these parameters can be found in the ARM template in your catalog.
1. Replace the placeholder values in [`create_environment.config.sh`](create_environment.config.sh) with your own values. Two example values are provided to show how it should look if you want to create a Test environment using an existing vnet.
1. If you are not already logged in to the Azure CLI, run the following commands in the devcontainer terminal (with your Azure Subscription ID):
    ```bash
    az login --use-device-code --output none
    az account set --subscription <SUBSCRIPTION_ID>
    ```
    You will be prompted to use a web browser to authenticate to Azure.
1. Give the project environment type that you are using the access it needs to any resources that you reference in your parameters file:
    * Use the the following commands (with your own values) to get your project environment type's principal ID:
      ```bash
      PROJECT_NAME="MyProjectName"
      ENVIRONMENT_TYPE_NAME="Test"
      PROJECT_RESOURCE_GROUP_NAME="MyProjectResourceGroupName"
      env_type_principal_id=$(az devcenter admin project-environment-type show \
        --project-name $PROJECT_NAME \
        --environment-type-name $ENVIRONMENT_TYPE_NAME \
        --resource-group $PROJECT_RESOURCE_GROUP_NAME \
        --query identity.principalId \
        --output tsv)
      ```
    * To reference a virtual machine image from your Azure Compute Gallery, assign your environment type the `Reader` role for your gallery.
      ```bash
      AZURE_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
      GALLERY_RESOURCE_GROUP_NAME="MyGalleryResourceGroupName"
      GALLERY_NAME="MyGalleryName"
      az role assignment create \
        --scope /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$GALLERY_RESOURCE_GROUP_NAME/providers/Microsoft.Compute/galleries/$GALLERY_NAME \
        --role Reader \
        --assignee-object-id $env_type_principal_id \
        --assignee-principal-type ServicePrincipal
      ```
    * To reference a virtual network like in [`existing-vnet.ARM.templates.parameters.json`](./existing-vnet.ARM.template.parameters.json), assign your environment type the `Network Contributor` role for the vnet.
      ```bash
      AZURE_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
      VNET_RESOURCE_GROUP_NAME="MyVNetResourceGroupName"
      VNET_NAME="MyVNetName"
      az role assignment create \
        --scope /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$VNET_RESOURCE_GROUP_NAME/providers/Microsoft.Network/virtualNetworks/$VNET_NAME \
        --role "Network Contributor" \
        --assignee-object-id $env_type_principal_id \
        --assignee-principal-type ServicePrincipal
      ```
1. In your devcontainer terminal, run the create environment script:
    ```bash
    bash create_environment.sh
    ```

Navigate to your dev center project in Azure portal to see your new environment.
