#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

source $(dirname $0)/symphony_stage_script_provider.sh

#region declare command variables & functions
command=""
_command_output=""
_command_status=0

function clear_command_variables() {
    command=""
    _command_output=""
    _command_status=0
}
#endregion declare command variables & functions

#region Declare Constants
DEV_CENTER_CATALOG_NAME="catalog"            
ENVIRONMENT_DEFINITION_NAME="vmss"           
ENVIRONMENT_TYPE="sandbox"                   
ADMIN_USER="environmentuser"                       
#MYOID="7cc6c11b-ad9c-43cc-a7d5-2a0a0e4f3648" #TODO: Discuss. How to get this value? As of now hardcoded objectid of AKS

MYOID=$(az account get-access-token --query "accessToken" -o tsv | jq -R -r 'split(".") | .[1] | @base64d | fromjson | .oid')
echo "Object ID of the service principal or managed identity: $MYOID"
#endregion Declare Constants

#region Getting config from metamodel config yaml
configEncoded="{{ parameters.input_parameter_to_script }}"
config=$(echo $configEncoded | base64 -d)
#endregion Getting config from metamodel config yaml

#region parameters - get from config
echo "getting parameters from config"
resource_name_primary_prefix=$(echo $config | jq -r '.config.resource_name_primary_prefix')
resource_name_secondary_prefix=$(echo $config | jq -r '.config.resource_name_secondary_prefix')
oem_identifier=$(echo $config | jq -r '.project_config.oem_identifier')
project_name=$(echo $config | jq -r '.project_config.project_name')
environment_stage_short=$(echo $config | jq -r '.customer_stamp_config.environment_stage_short')
description=$(echo $config | jq -r '.project_config.description')
vmsssuffix=$(echo $config | jq -r '.ade_config.vmsssuffix')
target_subscription_id=$(echo $config | jq -r '.customer_stamp_config.target_subscription_id')
compute_gallery_managedid=$(echo $config | jq -r '.shared_stamp_config.compute_gallery_managedid')
compute_gallery_name=$(echo $config | jq -r '.shared_stamp_config.compute_gallery_name')

#endregion parameters - get from config

#region Set the variables
echo "setting the variables"
SHARED_RESOURCE_GROUP="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-s-stamp-${environment_stage_short}-rg-001"
echo "setting shared resource group $SHARED_RESOURCE_GROUP"
RESOURCE_GROUP="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-${environment_stage_short}-rg-001"
echo "setting resource group $RESOURCE_GROUP"
DEV_CENTER_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-${environment_stage_short}-dc"
echo "setting dev center $DEV_CENTER_NAME"
ENVIRONMENT_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-p-${project_name}-${environment_stage_short}-vmss-${vmsssuffix}"
echo "setting vmss name $ENVIRONMENT_NAME"
PROJECT="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-p-${project_name}-001"
echo "setting project name $PROJECT"
KEY_VAULT_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-${environment_stage_short}-kv"
echo "setting key vault name $KEY_VAULT_NAME"
#endregion Set the variables

#region Install Azure Dev Center extension
echo "Installing the Azure Dev Center extension"
clear_command_variables
command="az extension add --name devcenter --upgrade"
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Extension installation complete!"
#endregion Install Azure Dev Center extension

az configure --defaults group=

#region Get Role Id for the Subscription Owner
echo "Getting Role Id for the Subscription Owner"
clear_command_variables
command="az role definition list -n \"Owner\" --scope \"/subscriptions/$target_subscription_id\" --query [].name -o tsv"
commandGetOwnerRoleId_output=""
execute_command_exit_on_failure "$command" commandGetOwnerRoleId_output _command_status
echo "Got Subscritpion Owner Role ID: $commandGetOwnerRoleId_output"
#endregion Get Role Id for the Subscription Owner

az configure --defaults group=$RESOURCE_GROUP

#region Get Dev Center ID, Object ID
echo "Getting Azure Dev Center Resource ID"
clear_command_variables
command="az devcenter admin devcenter show -n \"$DEV_CENTER_NAME\" --query id -o tsv"
commandGetDevCenterId_output=""
execute_command_exit_on_failure "$command" commandGetDevCenterId_output _command_status
echo "Got Azure Dev Center Resource ID: $commandGetDevCenterId_output"


#region Get Managed Identity ID, Object ID
echo "Getting Managed Identity Resource ID"
clear_command_variables
command="az identity show --name \"$compute_gallery_managedid\" --resource-group \"$SHARED_RESOURCE_GROUP\" --query id -o tsv"
commandGetManagedIdentityId_output=""
execute_command_exit_on_failure "$command" commandGetManagedIdentityId_output _command_status
echo "Got Managed Identity Resource ID: $commandGetManagedIdentityId_output"

echo "Getting Managed Identity Object ID"
clear_command_variables
command="az resource show --ids \"$commandGetManagedIdentityId_output\" --query properties.principalId -o tsv"
commandGetManagedIdentityObjId_output=""
execute_command_exit_on_failure "$command" commandGetManagedIdentityObjId_output _command_status
echo "Got Managed Identity Object ID: $commandGetManagedIdentityObjId_output"
#endregion Get Managed Identity ID, Object ID

#region Create Project in Dev Center
echo "Creating Project in Azure Dev Center"
clear_command_variables
command="az devcenter admin project create -n \"$PROJECT\" --description \"$description\" --dev-center-id \"$commandGetDevCenterId_output\""
execute_command_exit_on_failure "$command" _command_output _command_status
#endregion Create Project in Dev Center


echo "Assigning Owner role to the Managed Identity Object Id on the subscription"
clear_command_variables
command="az role assignment create --role \"Owner\" --assignee-object-id \"$commandGetManagedIdentityObjId_output\" --scope \"/subscriptions/$target_subscription_id\""
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Assigned Owner role to the Managed Identity Object Id on the subscription"
#endregion Assign Owner role to the Dev Center and Managed Identity, on the subscription

#region Create Environment Type for the Project, assign Contributor role on the subscription
echo "Creating Project Environment Type"
clear_command_variables
command="az devcenter admin project-environment-type create \
             -n \"$ENVIRONMENT_TYPE\" \
             --project \"$PROJECT\" \
             --identity-type \"SystemAssigned\" \
             --roles \"{\"${commandGetOwnerRoleId_output}\":{}}\" \
             --deployment-target-id \"/subscriptions/${target_subscription_id}\" \
             --status Enabled \
             --query 'identity.principalId' \
             --output tsv"
commandCreateProjectEnvType_output=""
execute_command_exit_on_failure "$command" commandCreateProjectEnvType_output _command_status
echo "Created Project Environment Type with Object ID: $commandCreateProjectEnvType_output"

echo "Assigning Contributor role to the Project Environment Type Object Id on the subscription"
clear_command_variables
command="az role assignment create --role \"Contributor\" --assignee-object-id $commandCreateProjectEnvType_output --scope \"/subscriptions/$target_subscription_id\""
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Assigned Contributor role to the Project Environment Type Object Id on the subscription"
#endregion Create Environment Type for the Project, assign Contributor role on the subscription

echo "Assigning Key Vault Secrets Officer role to the Project Environment Type Object Id on the subscription"
clear_command_variables
command="az role assignment create --role \"Key Vault Secrets Officer\" --assignee-object-id $commandCreateProjectEnvType_output --scope \"/subscriptions/$target_subscription_id/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME\""
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Assigned Key Vault Secrets Officer role to the Project Environment Type Object Id on the subscription"
#endregion Create Environment Type for the Project, assign Contributor role on the subscription


#region Assign Dev Center Project Admin role, Deployment Environments User to MYOID
echo "Assigning Dev Center Project Admin role, Deployment Environments User to $MYOID"
clear_command_variables
command="az role assignment create --assignee \"$MYOID\" --role \"DevCenter Project Admin\" --scope \"/subscriptions/$target_subscription_id\""
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Assigned Dev Center Project Admin role to $MYOID"

echo "Assigning Deployment Environments User role to $MYOID"
clear_command_variables
command="az role assignment create --assignee \"$MYOID\" --role \"Deployment Environments User\" --scope \"/subscriptions/$target_subscription_id\""
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Assigned Deployment Environments User role to $MYOID"
#endregion Assign Dev Center Project Admin role, Deployment Environments User to MYOID

#region Create Dev Environment
echo "Creating Dev Environment"
clear_command_variables
command="az devcenter dev environment create \
            --environment-name \"$ENVIRONMENT_NAME\" \
            --environment-type \"$ENVIRONMENT_TYPE\" \
            --dev-center-name \"$DEV_CENTER_NAME\" \
            --project-name \"$PROJECT\" \
            --catalog-name \"$DEV_CENTER_CATALOG_NAME\" \
            --environment-definition-name \"$ENVIRONMENT_DEFINITION_NAME\" \
            --parameters '{\"customerOEMsuffix\":\"${oem_identifier}\",\"admin_username\":\"${ADMIN_USER}\",\"environmentStage\":\"${environment_stage_short}\",\"vmss_uniquesuffix\":\"${vmsssuffix}\",\"compute_gallery_name\":\"${compute_gallery_name}\",\"SHARED_RESOURCE_GROUP\":\"${SHARED_RESOURCE_GROUP}\",\"projectname\":\"${project_name}\"}'"
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Created Dev Environment: $ENVIRONMENT_NAME"
#endregion Create Dev Environment

echo_output_dictionary_to_output_file