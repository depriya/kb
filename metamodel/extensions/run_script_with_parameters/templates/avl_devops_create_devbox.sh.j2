#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

source $(dirname $0)/symphony_stage_script_provider.sh

echo "getting config from metamodel" 
#region Getting config from metamodel config yaml
configEncoded="{{ parameters.input_parameter_to_script }}"
config=$(echo $configEncoded | base64 -d)
#endregion Getting config from metamodel config yaml

echo "parameters from config"
#region parameters - get from config
resource_name_primary_prefix=$(echo $config | jq -r '.config.resource_name_primary_prefix')
resource_name_secondary_prefix=$(echo $config | jq -r '.config.resource_name_secondary_prefix')
oem_identifier=$(echo $config | jq -r '.project_config.oem_identifier')
project_name=$(echo $config | jq -r '.project_config.project_name')
environment_stage_short=$(echo $config | jq -r '.customer_stamp_config.environment_stage_short')
target_subscription_id=$(echo $config | jq -r '.customer_stamp_config.target_subscription_id')
suffix=$(echo $config | jq -r '.devbox_sku.suffix')
azure_region=$(echo $config | jq -r '.customer_stamp_config.azure_region')
devbox_image_name=$(echo $config | jq -r '.devbox_sku.devbox_image_name')
capacity=$(echo $config | jq -r '.devbox_sku.capacity')
family=$(echo $config | jq -r '.devbox_sku.family')
compute=$(echo $config | jq -r '.devbox_sku.compute')
size=$(echo $config | jq -r '.devbox_sku.size')
tier=$(echo $config | jq -r '.devbox_sku.tier')
osstoragetype=$(echo $config | jq -r '.devbox_sku.osstoragetype')
compute_gallery_name=$(echo $config | jq -r '.shared_stamp_config.compute_gallery_name')

#endregion parameters - get from config
echo "setting the variables"
#region Set the variables
RESOURCE_GROUP="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-${environment_stage_short}-rg-001"
DEV_CENTER_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-${environment_stage_short}-dc"
PROJECT="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-p-${project_name}-001"
DEVBOX_DEF_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-${project_name}-devboxdef-${suffix}"
VNET_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-${environment_stage_short}-vnet-001"
DEV_CENTER_NETWORK_CONNECTION_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-${project_name}-ntwkcon-${suffix}"
NETWORK_CONNECTION_RG_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-${environment_stage_short}-${project_name}-rg-ntcon-${suffix}"
DEV_CENTER_POOL_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-${project_name}-pools-${suffix}"
OEM_Subnet="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-${environment_stage_short}-vnet-001-subnet"
network_connection_name="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-c-${oem_identifier}-${project_name}-ntwk-${suffix}"

#endregion Set the variables

#region Install Azure Dev Center extension
echo "Installing the Azure Dev Center extension"
commandInstallDevCenterExt="az extension add --name devcenter --upgrade"
commandInstallDevCenterExt_output=""
commandInstallDevCenterExt_status=0
execute_command_with_status_code "$commandInstallDevCenterExt" commandInstallDevCenterExt_output commandInstallDevCenterExt_status
if [ $commandInstallDevCenterExt_status -ne 0 ]; then
    echo "Failed to install the Azure Dev Center extension."
    echo_output_dictionary_to_output_file
    exit 0
fi
echo "Extension installation complete!"
#endregion Install Azure Dev Center extension

#region Create Dev Box definition
echo "Creating Dev Box definition"
commandCreateDevboxDef="az devcenter admin devbox-definition create \
    --dev-center $DEV_CENTER_NAME \
    --devbox-definition-name $DEVBOX_DEF_NAME \
	--image-reference \"{\\\"id\\\": \\\"/subscriptions/$target_subscription_id/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/devcenters/$DEV_CENTER_NAME/galleries/$compute_gallery_name/images/$devbox_image_name\\\"}\" \
    --os-storage-type $osstoragetype \
    --resource-group $RESOURCE_GROUP \
	--sku \"{\\\"capacity\\\": $capacity, \\\"family\\\": \\\"$family\\\", \\\"name\\\": \\\"$compute\\\", \\\"size\\\": \\\"$size\\\", \\\"tier\\\": \\\"$tier\\\"}\" \
    --hibernate-support \"Disabled\" \
    --location \"$azure_region\""
commandCreateDevboxDef_output=""
commandCreateDevboxDef_status=0
execute_command_with_status_code "$commandCreateDevboxDef" commandCreateDevboxDef_output commandCreateDevboxDef_status
if [ $commandCreateDevboxDef_status -ne 0 ]; then
    echo "Failed to create Dev Box definition."
    echo_output_dictionary_to_output_file
    exit 0
fi
echo "Dev Box definition created successfully."
#endregion Create Dev Box definition

#region Get OEM subnet ID
echo "Getting OEM subnet ID"
commandGetSubnetId="az network vnet subnet show --name $OEM_Subnet --vnet-name $VNET_NAME --resource-group $RESOURCE_GROUP --query id --output tsv"
commandGetSubnetId_output=""
commandGetSubnetId_status=0
execute_command_with_status_code "$commandGetSubnetId" commandGetSubnetId_output commandGetSubnetId_status
if [ commandGetSubnetId_status -ne 0 ]; then
    echo "Failed to get OEM subnet ID."
    echo_output_dictionary_to_output_file
    exit 0
fi
echo "Got OEM subnet ID: $commandGetSubnetId_output"
#endregion Get OEM subnet ID

#region Create Azure Dev Center Network Connection
echo "Creating Azure Dev Center Network Connection"
commandCreateNetworkConnection="az devcenter admin network-connection create \
    --domain-join-type \"AzureADJoin\" \
    --name \"$DEV_CENTER_NETWORK_CONNECTION_NAME\" \
    --resource-group $RESOURCE_GROUP \
    --subnet-id \"$commandGetSubnetId_output\" \
    --location \"$azure_region\" \
    --networking-resource-group-name \"$NETWORK_CONNECTION_RG_NAME\""
commandCreateNetworkConnection_output=""
commandCreateNetworkConnection_status=0
execute_command_with_status_code "$commandCreateNetworkConnection" commandCreateNetworkConnection_output commandCreateNetworkConnection_status
if [ $commandCreateNetworkConnection_status -ne 0 ]; then
    echo "Failed to create Azure Dev Center Network Connection."
    echo_output_dictionary_to_output_file
    exit 0
fi
echo "Azure Dev Center Network Connection created successfully."
#endregion Create Azure Dev Center Network Connection

#region Get Network Connection ID
echo "Getting Network Connection ID"
commandGetNetworkConnectionId="az devcenter admin network-connection show --name \"$DEV_CENTER_NETWORK_CONNECTION_NAME\" --resource-group "$RESOURCE_GROUP" --query id --output tsv"
commandGetNetworkConnectionId_output=""
commandGetNetworkConnectionId_status=0
if [ $commandGetNetworkConnectionId_status -ne 0 ]; then
    echo "Failed to get Network Connection ID."
    echo_output_dictionary_to_output_file
    exit 0
fi
echo "Got Network Connection ID is $commandGetNetworkConnectionId_output"

#endregion Get Network Connection ID

#region Create Dev Center Attached Network
echo "Creating Azure Dev Center attached network"
commandCreateAttachedNetwork="az devcenter admin attached-network create \
    --attached-network-connection-name $network_connection_name \
    --network-connection-id \"/subscriptions/$target_subscription_id/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/networkConnections/$DEV_CENTER_NETWORK_CONNECTION_NAME\" \
    --resource-group $RESOURCE_GROUP \
    --dev-center $DEV_CENTER_NAME"
commandCreateAttachedNetwork_output=""
commandCreateAttachedNetwork_status=0
execute_command_with_status_code "$commandCreateAttachedNetwork" commandCreateAttachedNetwork_output commandCreateAttachedNetwork_status
if [ $commandCreateAttachedNetwork_status -ne 0 ]; then
    echo "Failed to create Azure Dev Center attached network."
    echo_output_dictionary_to_output_file
    exit 0
fi
echo "Created Azure Dev Center Attached network successfully."
#endregion Create Dev Center Attached Network

#region Create Dev center pool
echo "Creating Azure Dev Center pool"
commandCreatePool="az devcenter admin pool create \
    --devbox-definition-name \"$DEVBOX_DEF_NAME\" \
    --local-administrator \"Enabled\" \
    --name \"$DEV_CENTER_POOL_NAME\" \
    --project \"$PROJECT\" \
    --resource-group \"$RESOURCE_GROUP\" \
    --location \"$azure_region\" \
    --network-connection-name \"$network_connection_name\" \
	--single-sign-on-status \"Enabled\""
commandCreatePool_output=""
commandCreatePool_status=0
execute_command_with_status_code "$commandCreatePool" commandCreatePool_output commandCreatePool_status
if [ $commandCreatePool_status -ne 0 ]; then
    echo "Failed to create Azure Dev Center pool."
    echo_output_dictionary_to_output_file
    exit 0
fi
echo "Azure Dev Center Pool created successfully."
#endregion Create Dev center pool

echo_output_dictionary_to_output_file