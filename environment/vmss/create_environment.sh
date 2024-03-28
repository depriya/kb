#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

# Enable tracing for debugging
set -x

# Change the current directory to the location of the script
cd "$(dirname "$0")"

# Load the variables from the config file
source create_environment.config.sh

# Function to handle errors
handle_error() {
    echo "ERROR: $1"
    exit 1
}

set +x  # Disable tracing for this section

echo "Starting environment creation process..."

echo "Installing the devcenter extension..."
az extension add --name devcenter --upgrade || handle_error "Failed to install the devcenter extension."
echo "Extension installation complete!"

echo "Assigning owner role to DevCenter identity..."
az role assignment create --assignee eb47c23a-720a-4576-b494-5491e1f134ca --role Owner --scope /subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4 || handle_error "Failed to assign owner role to DevCenter identity."
echo "Role assignment complete!"

# Add your new commands here
# Start of new commands

az configure --defaults group=$RESOURCE_GROUP

# Retrieve dev center resource ID
DEVCID=$(az devcenter admin devcenter show -n $DEV_CENTER_NAME --query id -o tsv)
echo $DEVCID

# Create project in dev center
az devcenter admin project create -n $DEV_CENTER_PROJECT_NAME \
--description "My first project." \
--dev-center-id $DEVCID

# Confirm project creation
az devcenter admin project show -n $DEV_CENTER_PROJECT_NAME

# Assign the Owner role to a managed identity

# # Retrieve Subscription ID
# SUBID=$(az account show --name $SUBSCRIPTIONNAME --query id -o tsv)
# echo $SUBID

# # Retrieve the Object ID of the dev center's identity
# OID=$(az ad sp list --display-name $DEV_CENTER_NAME --query [].id -o tsv)
# echo $OID

# # Assign the role of Owner to the dev center on the subscription
# az role assignment create --assignee $OID \
# --role "Owner" \
# --scope "/subscriptions/$SUBID"

# Configure a project

# Remove group default scope for next command. Leave blank for group.
az configure --defaults group=

# Retrieve the Role ID for the Owner of the subscription
ROID=$(az role definition list -n "Owner" --scope /subscriptions/$SUBID --query [].name -o tsv)
echo $ROID

# Set default resource group again
az configure --defaults group=$RESOURCE_GROUP

# Show allowed environment type for the project
az devcenter admin project-allowed-environment-type list --project $DEV_CENTER_PROJECT_NAME --query [].name

# Choose an environment type and create it for the project
az devcenter admin project-environment-type create -n $ENVIRONMENT_TYPE \
--project $DEV_CENTER_PROJECT_NAME \
--identity-type "SystemAssigned" \
--roles "{\"${ROID}\":{}}" \
--deployment-target-id "/subscriptions/${SUBID}" \
--status Enabled


az role assignment create \
    --role "Contributor" \
    --assignee-object-id $CLIENTID \
    --scope /subscriptions/$SUBID

# Assign environment access

# # Retrieve your own Object ID
# MYOID=$(az ad signed-in-user show --query id -o tsv)
# echo $MYOID

# # Assign admin access
# az role assignment create --assignee $MYOID \
# --role "DevCenter Project Admin" \
# --scope "/subscriptions/$SUBID"

# Optionally, assign the Dev Environment User role
az role assignment create --assignee $MYOID \
--role "Deployment Environments User" \
--scope "/subscriptions/$SUBID"

# End of new commands

echo "List all the Azure Deployment Environments projects you have access to:"
az graph query -q "Resources | where type =~ 'microsoft.devcenter/projects'" -o table || handle_error "Failed to list projects."

az account set --subscription $SUBID

# Remove group default scope for next command. Leave blank for group.
az configure --defaults group=

# Set default resource group again
az configure --defaults group=$RESOURCE_GROUP
echo "Configure the default resource group as the resource group that contains the project:"
#az configure set defaults.group=$RESOURCE_GROUP || handle_error "Failed to set default resource group."

echo "List the type of environments you can create in a specific project:"
az devcenter dev environment-type list --dev-center $DEV_CENTER_NAME --project-name $DEV_CENTER_PROJECT_NAME -o table || handle_error "Failed to list environment types."

echo "List the environment definitions that are available to a specific project:"
az devcenter dev environment-definition list --dev-center $DEV_CENTER_NAME --project-name $DEV_CENTER_PROJECT_NAME -o table || handle_error "Failed to list environment definitions."


echo "Creating environment..."
az devcenter dev environment create \
    --environment-name $ENVIRONMENT_NAME \
    --environment-type $ENVIRONMENT_TYPE \
    --dev-center-name $DEV_CENTER_NAME \
    --project-name $DEV_CENTER_PROJECT_NAME \
    --catalog-name $DEV_CENTER_CATALOG_NAME \
    --environment-definition-name $ENVIRONMENT_DEFINITION_NAME \
    --debug
    #--parameters '{"resource_name":"xmew1-dop-c-oem-rrr-vmss-001","OEM":"rrr","admin_username":"dkpriya","admin_password":"Azure@123456"}' \
    
    #--parameters $PARAMETERS_FILE || handle_error "Failed to create environment."
    #--name $ENVIRONMENT_NAME \

echo "Environment creation complete!"

# Disable tracing
set +x
