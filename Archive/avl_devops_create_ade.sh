#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

#source $(dirname $0)/symphony_stage_script_provider.sh

#region Declare Constants
DEV_CENTER_CATALOG_NAME="catalog"            #TODO: Discuss. Should this come from the config?
ENVIRONMENT_DEFINITION_NAME="vmss"           #TODO: Discuss. Should this come from the config?
ENVIRONMENT_TYPE="sandbox"                   #TODO: Discuss. Should this come from the config?
#PARAMETERS_FILE="existing.json"              #TODO: This should be removed, as the file is no longer used.
admin_username="admin"                       #TODO: Discuss and change, if needed
admin_password="Password@123"                #TODO: Should get this from the Key Vault or Generate a new password and save it in the Key Vault
SUBID="db401b47-f622-4eb4-a99b-e0cebc0ebad4" #TODO: Discuss. Should this come from the config?
MYOID="7cc6c11b-ad9c-43cc-a7d5-2a0a0e4f3648" #TODO: Discuss. How to get this value? As of now hardcoded objectid of AKS
#endregion Declare Constants

# #region Getting config from metamodel config yaml
# configEncoded="{{ parameters.input_parameter_to_script }}"
# config=$(echo $configEncoded | base64 -d)
# #endregion Getting config from metamodel config yaml

# #region parameters - get from config
# customer_OEM_suffix=$(echo $config | jq -r '.customer_OEM_suffix')
# project_name=$(echo $config | jq -r '.project_name')
# environment_stage_short=$(echo $config | jq -r '.environment_stage_short')
# project_description=$(echo $config | jq -r '.project_description')
# #endregion parameters - get from config

#region parameters - get from config
customer_OEM_suffix="avl"
project_name="mypj"
environment_stage_short="d"
project_description="firstproject"

#region Set the variables
#TODO: Discuss. Can the prefix and suffixes be fetched from the config? How to handle the index?
RESOURCE_GROUP="xmew1-dop-c-${customer_OEM_suffix}-${environment_stage_short}-rg-001"
DEV_CENTER_NAME="xmew1-dop-c-${customer_OEM_suffix}-${environment_stage_short}-dc"
ENVIRONMENT_NAME="xmew1-dop-c-${customer_OEM_suffix}-p-${project_name}-vmss-001"
project="xmew1-dop-c-${customer_OEM_suffix}-p-${project_name}-001".
#endregion Set the variables

#region Install Azure Dev Center extension
echo "Installing the Azure Dev Center extension"
commandInstallDevCenterExt="az extension add --name devcenter --upgrade"
commandInstallDevCenterExt_output=""
commandInstallDevCenterExt_status=0
execute_command_with_status_code "$commandInstallDevCenterExt" commandInstallDevCenterExt_output commandInstallDevCenterExt_status
if [ $commandInstallDevCenterExt_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Extension installation complete!"
#endregion Install Azure Dev Center extension

az configure --defaults group=

#region Get Role Id for the Subscription Owner
echo "Getting Role Id for the Subscription Owner"
commandGetOwnerRoleId="az role definition list -n \"Owner\" --scope \"/subscriptions/$SUBID\" --query [].name -o tsv"
commandGetOwnerRoleId_output=""
commandGetOwnerRoleId_status=0
execute_command_with_status_code "$commandGetOwnerRoleId" commandGetOwnerRoleId_output commandGetOwnerRoleId_status
if [ $commandGetOwnerRoleId_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Got Subscritpion Owner Role ID: $commandGetOwnerRoleId_output"
#endregion Get Role Id for the Subscription Owner

az configure --defaults group=$RESOURCE_GROUP

#region Get Dev Center ID, Object ID
echo "Getting Azure Dev Center Resource ID"
commandGetDevCenterId="az devcenter admin devcenter show -n \"$DEV_CENTER_NAME\" --query id -o tsv"
commandGetDevCenterId_output=""
commandGetDevCenterId_status=0
execute_command_with_status_code "$commandGetDevCenterId" commandGetDevCenterId_output commandGetDevCenterId_status
if [ $commandGetDevCenterId_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Got Azure Dev Center Resource ID: $commandGetDevCenterId_output"

echo "Getting Azure Dev Center Object ID"
commandGetDevCenterObjId="az devcenter admin devcenter show -n \"$DEV_CENTER_NAME\" --query identity.principalId -o tsv"
commandGetDevCenterObjId_output=""
commandGetDevCenterObjId_status=0
execute_command_with_status_code "$commandGetDevCenterObjId" commandGetDevCenterObjId_output commandGetDevCenterObjId_status
if [ $commandGetDevCenterObjId_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Got Azure Dev Center Object ID: $commandGetDevCenterObjId_output"
#endregion Get Dev Center ID, Object ID

#region Get Managed Identity ID, Object ID
#TODO: Check why this resource group and name are hardcoded?
echo "Getting Managed Identity Resource ID"
commandGetManagedIdentityId="az identity show --name \"Computegalleryid\" --resource-group \"xmew1-dop-s-stamp-d-rg-001\" --query id -o tsv"
commandGetManagedIdentityId_output=""
commandGetManagedIdentityId_status=0
execute_command_with_status_code "$commandGetManagedIdentityId" commandGetManagedIdentityId_output commandGetManagedIdentityId_status
if [ $commandGetManagedIdentityId_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Got Managed Identity Resource ID: $commandGetManagedIdentityId_output"

echo "Getting Managed Identity Object ID"
commandGetManagedIdentityObjId="az resource show --ids \"$commandGetManagedIdentityId_output\" --query properties.principalId -o tsv"
commandGetManagedIdentityObjId_output=""
commandGetManagedIdentityObjId_status=0
execute_command_with_status_code "$commandGetManagedIdentityObjId" commandGetManagedIdentityObjId_output commandGetManagedIdentityObjId_status
if [ $commandGetManagedIdentityObjId_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Got Managed Identity Object ID: $commandGetManagedIdentityObjId_output"
#endregion Get Managed Identity ID, Object ID

#region Create Project in Dev Center
echo "Creating Project in Azure Dev Center"
commandCreateProject="az devcenter admin project create -n \"$project\" --description \"$project_description\" --dev-center-id \"$commandGetDevCenterId_output\""
commandCreateProject_output=""
commandCreateProject_status=0
execute_command_with_status_code "$commandCreateProject" commandCreateProject_output commandCreateProject_status
if [ $commandCreateProject_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Created Project: $project"
#endregion Create Project in Dev Center

#region Assign Owner role to the Dev Center and Managed Identity, on the subscription
echo "Assigning Owner role to the Dev Center Object Id on the subscription"
commandCreateDevCenterRole="az role assignment create --role \"Owner\" --assignee-object-id \"$commandGetDevCenterObjId_output\" --scope \"/subscriptions/$SUBID\""
commandCreateDevCenterRole_output=""
commandCreateDevCenterRole_status=0
execute_command_with_status_code "$commandCreateDevCenterRole" commandCreateDevCenterRole_output commandCreateDevCenterRole_status
if [ $commandCreateDevCenterRole_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Assigned Owner role to the Dev Center Object Id on the subscription"

echo "Assigning Owner role to the Managed Identity Object Id on the subscription"
commandCreateManagedIdRole="az role assignment create --role \"Owner\" --assignee-object-id \"$commandGetManagedIdentityObjId_output\" --scope \"/subscriptions/$SUBID\""
commandCreateManagedIdRole_output=""
commandCreateManagedIdRole_status=0
execute_command_with_status_code "$commandCreateManagedIdRole" commandCreateManagedIdRole_output commandCreateManagedIdRole_status
if [ $commandCreateManagedIdRole_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Assigned Owner role to the Managed Identity Object Id on the subscription"
#endregion Assign Owner role to the Dev Center and Managed Identity, on the subscription

#region Create Environment Type for the Project, assign Contributor role on the subscription
echo "Creating Project Environment Type"
commandCreateProjectEnvType="az devcenter admin project-environment-type create -n \"$ENVIRONMENT_TYPE\" --project \"$project\" --identity-type \"SystemAssigned\" --roles \"{\"${commandGetOwnerRoleId_output}\":{}}\" --deployment-target-id \"/subscriptions/${SUBID}\" --status Enabled --query 'identity.principalId' --output tsv"
commandCreateProjectEnvType_output=""
commandCreateProjectEnvType_status=0
execute_command_with_status_code "$commandCreateProjectEnvType" commandCreateProjectEnvType_output commandCreateProjectEnvType_status
if [ $commandCreateProjectEnvType_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Created Project Environment Type with Object ID: $commandCreateProjectEnvType_output"

echo "Assigning Contributor role to the Project Environment Type Object Id on the subscription"
commandCreateContributorRole=""az role assignment create --role \"Contributor\" --assignee-object-id $commandCreateProjectEnvType_output --scope \"/subscriptions/$SUBID\"""
commandCreateContributorRole_output=""
commandCreateContributorRole_status=0
execute_command_with_status_code "$commandCreateContributorRole" commandCreateContributorRole_output commandCreateContributorRole_status
if [ $commandCreateContributorRole_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Assigned Contributor role to the Project Environment Type Object Id on the subscription"
#endregion Create Environment Type for the Project, assign Contributor role on the subscription

# # Retrieve your own Object ID
# MYOID=$(az ad signed-in-user show --query id -o tsv)
# echo $MYOID

#region Assign Dev Center Project Admin role, Deployment Environments User to MYOID
echo "Assigning Dev Center Project Admin role, Deployment Environments User to $MYOID"
commandAssignProjRole="az role assignment create --assignee \"$MYOID\" --role \"DevCenter Project Admin\" --scope \"/subscriptions/$SUBID\""
commandAssignProjRole_output=""
commandAssignProjRole_status=0
execute_command_with_status_code "$commandAssignProjRole" commandAssignProjRole_output commandAssignProjRole_status
if [ $commandAssignProjRole_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Assigned Dev Center Project Admin role to $MYOID"

echo "Assigning Deployment Environments User role to $MYOID"
commandAssignEnvUserRole="az role assignment create --assignee \"$MYOID\" --role \"Deployment Environments User\" --scope \"/subscriptions/$SUBID\""
commandAssignEnvUserRole_output=""
commandAssignEnvUserRole_status=0
execute_command_with_status_code "$commandAssignEnvUserRole" commandAssignEnvUserRole_output commandAssignEnvUserRole_status
if [ $commandAssignEnvUserRole_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Assigned Deployment Environments User role to $MYOID"
#endregion Assign Dev Center Project Admin role, Deployment Environments User to MYOID

#region Create Dev Environment
echo "Creating Dev Environment"
commandCreateDevCenter="az devcenter dev environment create --environment-name \"$ENVIRONMENT_NAME\" --environment-type \"$ENVIRONMENT_TYPE\" --dev-center-name \"$DEV_CENTER_NAME\" --project-name \"$project\" --catalog-name \"$DEV_CENTER_CATALOG_NAME\" --environment-definition-name \"$ENVIRONMENT_DEFINITION_NAME\" --parameters '{"customerOEMsuffix":"${customer_OEM_suffix}","admin_username":"${admin_username}","admin_password":"${admin_password}","environmentStage":"${environment_stage_short}","projectname":"${project}"}'"
commandCreateDevCenter_output=""
commandCreateDevCenter_status=0
execute_command_with_status_code "$commandCreateDevCenter" commandCreateDevCenter_output commandCreateDevCenter_status
echo "Created Dev Environment: $ENVIRONMENT_NAME"
#endregion Create Dev Environment

echo_output_dictionary_to_output_file
