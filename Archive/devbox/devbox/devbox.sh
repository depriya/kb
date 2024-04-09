#!/bin/bash

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

source $(dirname $0)/symphony_stage_script_provider.sh

# Function to execute commands and handle errors
execute_command_with_status_code() {
    local command="$1"
    local output_var="$2"
    local status_var="$3"
    eval "$command" > "$output_var" 2>&1
    status_var="$?"
    if [ "$status_var" -ne 0 ]; then
        echo "Error executing command: $command"
        echo "Command output: $(<"$output_var")"
        exit "$status_var"
    fi
}

# Function to handle errors
handle_error() {
    local error_message="$1"
    echo "$error_message"
    exit 1
}

 #region Getting config from metamodel config yaml
 configEncoded="{{ parameters.input_parameter_to_script }}"
 config=$(echo $configEncoded | base64 -d)
 #endregion Getting config from metamodel config yaml

 #region parameters - get from config
 customer_OEM_suffix=$(echo $config | jq -r '.customer_OEM_suffix')
 project_name=$(echo $config | jq -r '.project_name')
 environment_stage_short=$(echo $config | jq -r '.environment_stage_short')
 #endregion parameters - get from config

# Set variables
location="westeurope"
project="xmew1-dop-c-${customer_OEM_suffix}-p-${project_name}-001"
image="microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os"
DEV_CENTER_NAME="xmew1-dop-c-${customer_OEM_suffix}-d-dc"
RESOURCE_GROUP="xmew1-dop-c-${customer_OEM_suffix}-d-rg-001"
devbox_definition_name="xmew1-dop-c-${customer_OEM_suffix}-devboxdef"

# Install the devcenter extension
echo "Installing the devcenter extension..."
commandInstallDevCenterExt="az extension add --name devcenter --upgrade"
commandInstallDevCenterExt_output=""
commandInstallDevCenterExt_status=0
execute_command_with_status_code "$commandInstallDevCenterExt" commandInstallDevCenterExt_output commandInstallDevCenterExt_status || handle_error "Failed to install the devcenter extension."
if [ $commandInstallDevCenterExt_status -ne 0 ]; then
  echo_output_dictionary_to_output_file
  exit 0
fi
echo "Extension installation complete!"


##Parameter details##
capacity=1
family="Standard"
compute="general_i_8c32gb256ssd_v2"
size="Standard_DS1_v2"
tier="Standard"
osstoragetype="ssd_256gb"

# Create devbox definition
echo "Creating devbox definition..."
commandCreateDevboxDef="az devcenter admin devbox-definition create \
    --dev-center $DEV_CENTER_NAME \
    --devbox-definition-name $devbox_definition_name \
    --image-reference \"{\\\"id\\\": \\\"/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/devcenters/$DEV_CENTER_NAME/galleries/default/images/$image\\\"}\" \
    --os-storage-type $osstoragetype \
    --resource-group $RESOURCE_GROUP \
    --sku \"{\\\"capacity\\\": $capacity, \\\"family\\\": \\\"$family\\\", \\\"name\\\": \\\"$compute\\\", \\\"size\\\": \\\"$size\\\", \\\"tier\\\": \\\"$tier\\\"}\" \
    --hibernate-support \"Enabled\" \
    --location \"$location\""
commandCreateDevboxDef_output=""
commandCreateDevboxDef_status=0
execute_command_with_status_code "$commandCreateDevboxDef" commandCreateDevboxDef_output commandCreateDevboxDef_status
if [ $commandCreateDevboxDef_status -ne 0 ]; then
    echo "Failed to create devbox definition."
    exit 0
fi
echo "Devbox definition created successfully."

# Fetch subnet ID
echo "Fetching subnet ID..."
subnet_id=$(az network vnet subnet show --name OEMSubnet --vnet-name xmew1-dop-c-${customer_OEM_suffix}-d-vnet-001 --resource-group xmew1-dop-c-${customer_OEM_suffix}-d-rg-001 --query id --output tsv)
if [ $? -ne 0 ]; then
    echo "Failed to fetch subnet ID."
    exit 0
fi
echo "Subnet ID fetched successfully."

# Create network connection
echo "Creating network connection..."
commandCreateNetworkConnection="az devcenter admin network-connection create \
    --domain-join-type \"AzureADJoin\" \
    --name \"xmew1-dop-c-${customer_OEM_suffix}-ntwkcon-001\" \
    --resource-group $RESOURCE_GROUP \
    --subnet-id \"$subnet_id\" \
    --location \"$location\" \
    --networking-resource-group-name \"xmew1-dop-c-${customer_OEM_suffix}-d-rg-networkconnection-001\""
commandCreateNetworkConnection_output=""
commandCreateNetworkConnection_status=0
execute_command_with_status_code "$commandCreateNetworkConnection" commandCreateNetworkConnection_output commandCreateNetworkConnection_status
if [ $commandCreateNetworkConnection_status -ne 0 ]; then
    echo "Failed to create network connection."
    exit 0
fi
echo "Network connection created successfully."

# Fetch network connection ID
echo "Fetching network connection ID..."
network_connection_id=$(az devcenter admin network-connection show --name "xmew1-dop-c-${customer_OEM_suffix}-ntwkcon-001" --resource-group "$RESOURCE_GROUP" --query id --output tsv)
if [ $? -ne 0 ]; then
    echo "Failed to fetch network connection ID."
    exit 0
fi
echo "Network connection ID fetched successfully."

# Create attached network
echo "Creating attached network..."
commandCreateAttachedNetwork="az devcenter admin attached-network create \
    --attached-network-connection-name \"xmew1-dop-c-${customer_OEM_suffix}-ntwk-001\" \
    --network-connection-id \"$network_connection_id\" \
    --resource-group $RESOURCE_GROUP \
    --dev-center $DEV_CENTER_NAME"
commandCreateAttachedNetwork_output=""
commandCreateAttachedNetwork_status=0
execute_command_with_status_code "$commandCreateAttachedNetwork" commandCreateAttachedNetwork_output commandCreateAttachedNetwork_status
if [ $commandCreateAttachedNetwork_status -ne 0 ]; then
    echo "Failed to create attached network."
    exit 0
fi
echo "Attached network created successfully."

# Create pool
echo "Creating pool..."
commandCreatePool="az devcenter admin pool create \
    --devbox-definition-name $devbox_definition_name \
    --local-administrator \"Enabled\" \
    --name \"xmew1-dop-c-${customer_OEM_suffix}-pools-001\" \
    --project \"$project\" \
    --resource-group $RESOURCE_GROUP \
    --location \"$location\" \
    --network-connection-name \"xmew1-dop-c-${customer_OEM_suffix}-ntwk-001\""
commandCreatePool_output=""
commandCreatePool_status=0
execute_command_with_status_code "$commandCreatePool" commandCreatePool_output commandCreatePool_status
if [ $commandCreatePool_status -ne 0 ]; then
    echo "Failed to create pool."
    exit 0
fi
echo "Pool created successfully."
