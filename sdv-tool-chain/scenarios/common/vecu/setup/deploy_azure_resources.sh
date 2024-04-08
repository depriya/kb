#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

# Change the current directory to the location of the script
cd "$(dirname "$0")"

# Load the variables from the config file
source deploy_azure_resources.config.sh

# Constants
VECU_RESOURCES_TEMPLATE_FILE="vECU.resources.ARM.template.json"
VECU_RESOURCES_TEMPLATE_PARAMETERS_FILE="vECU.resources.ARM.template.parameters.json"

echo "Creating resource group $RESOURCE_GROUP_NAME in location $RESOURCE_GROUP_LOCATION..."
az group create --name $RESOURCE_GROUP_NAME --location $RESOURCE_GROUP_LOCATION

echo "Deploying ARM template to resource group $RESOURCE_GROUP_NAME..."
az deployment group create \
    --resource-group $RESOURCE_GROUP_NAME \
    --template-file $VECU_RESOURCES_TEMPLATE_FILE \
    --parameters $VECU_RESOURCES_TEMPLATE_PARAMETERS_FILE

echo "Assigning Reader role scoped to $DEV_CENTER_PROJECT_NAME to user principal..."
# Must assign role outside of ARM template because it is scoped to a resource in a different resource group
az role assignment create \
    --scope /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$DEV_CENTER_PROJECT_RESOURCE_GROUP_NAME/providers/Microsoft.DevCenter/projects/$DEV_CENTER_PROJECT_NAME \
    --role "Reader" \
    --assignee-object-id $USER_PRINCIPAL_ID \
    --assignee-principal-type User

echo "Assigning Deployment Environments User role scoped to $DEV_CENTER_PROJECT_NAME to user principal..."
# Must assign role outside of ARM template because it is scoped to a resource in a different resource group
az role assignment create \
    --scope /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$DEV_CENTER_PROJECT_RESOURCE_GROUP_NAME/providers/Microsoft.DevCenter/projects/$DEV_CENTER_PROJECT_NAME \
    --role "Deployment Environments User" \
    --assignee-object-id $USER_PRINCIPAL_ID \
    --assignee-principal-type User

echo "Assigning Virtual Machine Contributor role scoped to subscription to user principal..."
# Must assign role outside of ARM template because it is scoped to the whole subscription
az role assignment create \
  --scope /subscriptions/$AZURE_SUBSCRIPTION_ID \
  --role "Virtual Machine Contributor" \
  --assignee-object-id $USER_PRINCIPAL_ID \
  --assignee-principal-type User

echo "Azure resource setup complete!"
