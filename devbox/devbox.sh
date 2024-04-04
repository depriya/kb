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


#!/bin/bash

# Copyright (C) Microsoft Corporation.

# The name of your Azure dev center.
customerOEMsuffix="avl" #comes from metamodel

projectname="pjdb" #comes from metamodel

projectdescription="my devbox proj" #comes from metamodel

RESOURCE_GROUP="xmew1-dop-c-${customerOEMsuffix}-d-rg-001"

SUBID="db401b47-f622-4eb4-a99b-e0cebc0ebad4"

MYOID="f0e04b27-58c5-49a7-b142-5cc5296a4261" #comes from metamodel

DEV_CENTER_NAME="xmew1-dop-c-${customerOEMsuffix}-d-dc"

# The name to use for the new environment to be created.
ENVIRONMENT_NAME="xmew1-dop-c-${customerOEMsuffix}-p-${projectname}-db-001"

# The environment type to use for this environment.
ENVIRONMENT_TYPE="Test"

# The name of your Azure dev center project.
project="xmew1-dop-c-${customerOEMsuffix}-p-${projectname}-001"

# The name of your catalog.
DEV_CENTER_CATALOG_NAME="catalog"

# The name of the ARM template to deploy (specified in the evironment.yaml).
ENVIRONMENT_DEFINITION_NAME="devbox"

# The name of the ARM template parameters file to use for the deployment.
#PARAMETERS_FILE="parameters.json"

# Load the variables from the config file
#source create_environment.config.sh

# Function to handle errors
handle_error() {
    echo "ERROR: $1"
    exit 1
}

set +x  # Disable tracing for this section

echo "Starting environment creation process..."


# # # Retrieve your own Object ID
#  MYOID=$(az ad signed-in-user show --query id -o tsv)
#  echo $MYOID



echo "Installing the devcenter extension..."
az extension add --name devcenter --upgrade || handle_error "Failed to install the devcenter extension."
echo "Extension installation complete!"


# Start of new commands

az configure --defaults group=$RESOURCE_GROUP

# Retrieve dev center resource ID
DEVCID=$(az devcenter admin devcenter show -n $DEV_CENTER_NAME --query id -o tsv)
echo $DEVCID

# # Retrieve the Object ID of the dev center's identity
DEVC_OBJ_ID=$(az devcenter admin devcenter show -n $DEV_CENTER_NAME --query identity.principalId -o tsv)
echo "DevCenter Object ID: $DEVC_OBJ_ID"


# Retrieve the user-assigned identity resource ID
IDENTITY_RESOURCE_ID=$(az identity show --name Computegalleryid --resource-group xmew1-dop-s-stamp-d-rg-001 --query id -o tsv)

# Retrieve the object ID of the user-assigned identity
USER_ASSIGNED_IDENTITY_OBJ_ID=$(az resource show --ids $IDENTITY_RESOURCE_ID --query properties.principalId -o tsv)
echo "User Assigned Identity Object ID: $USER_ASSIGNED_IDENTITY_OBJ_ID"

# Create project in dev center
az devcenter admin project create -n $project \
--description $projectdescription \   #it will be fetched from metamodel
--dev-center-id $DEVCID

# Confirm project creation
az devcenter admin project show -n $projectname

# Assign the Owner role to a managed identity

# # Retrieve the Object ID of the dev center's identity
# OID=$(az ad sp list --display-name $DEV_CENTER_NAME --query [].id -o tsv)
# echo $OID


 # Assign the role of Owner to the dev center on the subscription
 az role assignment create \
  --role "Owner" \
  --assignee-object-id $DEVC_OBJ_ID \
  --scope "/subscriptions/$SUBID"

az role assignment create \
  --role "Owner" \
  --assignee-object-id $USER_ASSIGNED_IDENTITY_OBJ_ID \
  --scope "/subscriptions/$SUBID"

# Configure a project

# Remove group default scope for next command. Leave blank for group.
az configure --defaults group=

# Retrieve the Role ID for the Owner of the subscription
ROID=$(az role definition list -n "Owner" --scope /subscriptions/$SUBID --query [].name -o tsv)
echo $ROID

# Set default resource group again
az configure --defaults group=$RESOURCE_GROUP

# Show allowed environment type for the project
az devcenter admin project-allowed-environment-type list --project $projectname --query [].name

# # Choose an environment type and create it for the project
# az devcenter admin project-environment-type create -n $ENVIRONMENT_TYPE \
# --project $DEV_CENTER_PROJECT_NAME \
# --identity-type "SystemAssigned" \
# --roles "{\"${ROID}\":{}}" \
# --deployment-target-id "/subscriptions/${SUBID}" \
# --status Enabled

# # Choose an environment type and create it for the project
objectId=$(az devcenter admin project-environment-type create -n $ENVIRONMENT_TYPE \
--project $projectname \
--identity-type "SystemAssigned" \
--roles "{\"${ROID}\":{}}" \
--deployment-target-id "/subscriptions/${SUBID}" \
--status Enabled \
--query 'identity.principalId' \
--output tsv)
echo Test objectid is $objectId


az role assignment create \
    --role "Contributor" \
    --assignee-object-id $objectId \
    --scope /subscriptions/$SUBID
    #----assignee-principal-type "ServicePrincipal" \
echo "role sucessfully added"

# Assign environment access

 # Assign admin access
 az role assignment create --assignee $MYOID \
 --role "DevCenter Project Admin" \
 --scope "/subscriptions/$SUBID"

# Optionally, assign the Dev Environment User role
az role assignment create --assignee $MYOID \
 --role "Deployment Environments User" \
 --scope "/subscriptions/$SUBID"


# End of new commands

 echo "List all the Azure Deployment Environments projects you have access to:"
 az graph query -q "Resources | where type =~ 'microsoft.devcenter/projects'" -o table || handle_error "Failed to list projects."

 az account set --subscription $SUBID

# # Remove group default scope for next command. Leave blank for group.
 az configure --defaults group=

# # Set default resource group again
 az configure --defaults group=$RESOURCE_GROUP
 echo "Configure the default resource group as the resource group that contains the project:"


 echo "Creating environment..."
 az devcenter dev environment create \
     --environment-name $ENVIRONMENT_NAME \
     --environment-type $ENVIRONMENT_TYPE \
     --dev-center-name $DEV_CENTER_NAME \
     --project-name $projectname \
     --catalog-name $DEV_CENTER_CATALOG_NAME \
     --environment-definition-name $ENVIRONMENT_DEFINITION_NAME \
     #--parameters $PARAMETERS_FILE || handle_error "Failed to create environment." \
     #--debug
    

 echo "Environment creation complete!"

# # Disable tracing
 set +x
