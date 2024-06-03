#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

# Change the current directory to the location of the script
cd "$(dirname "$0")"

# Load the variables from the config file
source setup_ade.config.sh

# Constants
DEV_CENTER_TEMPLATE_FILE="DevCenter.ARM.template.json"
DEV_CENTER_TEMPLATE_PARAMETERS_FILE="DevCenter.ARM.template.parameters.json"

echo "Creating resource group $RESOURCE_GROUP_NAME in location $RESOURCE_GROUP_LOCATION..."
az group create --name $RESOURCE_GROUP_NAME --location $RESOURCE_GROUP_LOCATION

echo "Deploying ARM template for dev center resources to resource group $RESOURCE_GROUP_NAME..."
az deployment group create \
    --resource-group $RESOURCE_GROUP_NAME \
    --template-file $DEV_CENTER_TEMPLATE_FILE \
    --parameters $DEV_CENTER_TEMPLATE_PARAMETERS_FILE

echo "Assigning subscription Owner role to DevCenter service principal..."
# A dev center needs permissions to assign roles on subscriptions associated with environment types.
# Must assign role outside of ARM template because it is scoped to the subscription, not the resource group
dev_center_name=$(cat $DEV_CENTER_TEMPLATE_PARAMETERS_FILE | jq -r '.parameters.devCenterName.value')
dev_center_principal_id=$(az devcenter admin devcenter show --name $dev_center_name --resource-group $RESOURCE_GROUP_NAME --query identity.principalId --output tsv)
az role assignment create \
    --scope /subscriptions/$AZURE_SUBSCRIPTION_ID \
    --role Owner \
    --assignee-object-id $dev_center_principal_id \
    --assignee-principal-type ServicePrincipal

echo "Dev center setup complete!"
