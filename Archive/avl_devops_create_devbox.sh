#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

source $(dirname $0)/symphony_stage_script_provider.sh

#region Declare Constants
echo "variable declation"
LOCATION="westeurope"  
IMAGE="microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os" 
OEM_Subnet="OEMSubnet"  
echo "declare a SKU"
#endregion Declare Constants
echo "SKU Details"
capacity=1
family="Standard"
compute="general_i_8c32gb256ssd_v2"
size="Standard_DS1_v2"
tier="Standard"
osstoragetype="ssd_256gb"
echo "getting config from metamodel" 
#region Getting config from metamodel config yaml
configEncoded="{{ parameters.input_parameter_to_script }}"
config=$(echo $configEncoded | base64 -d)
#endregion Getting config from metamodel config yaml

echo "parameters from config"
#region parameters - get from config
resource_name_primary_prefix=$(echo $config | jq -r '.resource_name_primary_prefix')
resource_name_secondary_prefix=$(echo $config | jq -r '.resource_name_secondary_prefix')
resource_name_shared_short=$(echo $config | jq -r '.resource_name_shared_short')
resource_name_customer_short=$(echo $config | jq -r '.resource_name_customer_short')
customer_OEM_suffix=$(echo $config | jq -r '.customer_OEM_suffix')
project_name=$(echo $config | jq -r '.project_name')
environment_stage_short=$(echo $config | jq -r '.environment_stage_short')
subscription_id=$(echo $config | jq -r '.subscription_id')
#endregion parameters - get from config
echo "setting the variables"
#region Set the variables
RESOURCE_GROUP="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_customer_short}-${customer_OEM_suffix}-${environment_stage_short}-rg-001"
DEV_CENTER_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_customer_short}-${customer_OEM_suffix}-${environment_stage_short}-dc"
PROJECT="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_customer_short}-${customer_OEM_suffix}-p-${project_name}-001"
DEVBOX_DEF_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_customer_short}-${customer_OEM_suffix}-${project_name}-devboxdef"
VNET_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_customer_short}-${customer_OEM_suffix}-${environment_stage_short}-vnet-001"
DEV_CENTER_NETWORK_CONNECTION_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_customer_short}-${customer_OEM_suffix}-${project_name}-ntwkcon-001"
NETWORK_CONNECTION_RG_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_customer_short}-${customer_OEM_suffix}-${environment_stage_short}-${project_name}-rg-ntcon-001"
DEV_CENTER_POOL_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_customer_short}-${customer_OEM_suffix}-${project_name}-pools-001"
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
    --image-reference \"{\\\"id\\\": \\\"/subscriptions/$subscription_id/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/devcenters/$DEV_CENTER_NAME/galleries/default/images/$IMAGE\\\"}\" \
    --os-storage-type $osstoragetype \
    --resource-group $RESOURCE_GROUP \
	--sku \"{\\\"capacity\\\": $capacity, \\\"family\\\": \\\"$family\\\", \\\"name\\\": \\\"$compute\\\", \\\"size\\\": \\\"$size\\\", \\\"tier\\\": \\\"$tier\\\"}\" \
    --hibernate-support \"Enabled\" \
    --location \"$LOCATION\""
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
    --location \"$LOCATION\" \
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
    --attached-network-connection-name \"xmew1-dop-c-${customer_OEM_suffix}-${project_name}-ntwk-001\" \
    --network-connection-id \"/subscriptions/$subscription_id/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/networkConnections/$DEV_CENTER_NETWORK_CONNECTION_NAME\" \
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
    --location \"$LOCATION\" \
    --network-connection-name \"xmew1-dop-c-${customer_OEM_suffix}-${project_name}-ntwk-001\""
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