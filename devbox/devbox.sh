#!/bin/bash

# Set variables
customerOEMsuffix="avl"
location="westeurope"
projectname="pjdb"
project="xmew1-dop-c-${customerOEMsuffix}-p-${projectname}-001"
##SKU details##
capacity=1
family="Standard"
compute="general_i_8c32gb256ssd_v2"
size="Standard_DS1_v2"
tier="Standard"
osstoragetype="ssd_256gb"

echo "Installing the devcenter extension..."
az extension add --name devcenter --upgrade || handle_error "Failed to install the devcenter extension."
echo "Extension installation complete!"

# Fetch image ID
image_id=$(az devcenter image show --gallery-name default --gallery-image-name microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os --gallery-image-version 1.0.0 --resource-group xmew1-dop-c-avl-d-rg-001 --query id --output tsv)

# Create devbox definition
az devcenter admin devbox-definition create \
    --dev-center "xmew1-dop-c-${customerOEMsuffix}-d-dc" \
    --devbox-definition-name "xmew1-dop-c-${customerOEMsuffix}-devboxdef" \
    --image-reference "{\"id\": \"${image_id}\"}" \
    --os-storage-type $osstoragetype \
    --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" \
    --sku "{\"capacity\": $capacity, \"family\": \"$family\", \"name\": \"$compute\", \"size\": \"$size\", \"tier\": \"$tier\"}" \
    --hibernate-support "Enabled" \
    --location "$location"

# Fetch subnet ID
subnet_id=$(az network vnet subnet show --name OEMSubnet --vnet-name xmew1-dop-c-${customerOEMsuffix}-d-vnet-001 --resource-group xmew1-dop-c-${customerOEMsuffix}-d-rg-001 --query id --output tsv)

# Create network connection
az devcenter admin network-connection create \
    --domain-join-type "AzureADJoin" \
    --name "xmew1-dop-c-${customerOEMsuffix}-ntwkcon-001" \
    --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" \
    --subnet-id "$subnet_id" \
    --location "$location" \
    --networking-resource-group-name "xmew1-dop-c-${customerOEMsuffix}-d-rg-networkconnection-001"

# Fetch network connection ID
network_connection_id=$(az devcenter admin network-connection show --name "xmew1-dop-c-${customerOEMsuffix}-ntwkcon-001" --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" --query id --output tsv)

# Create attached network
az devcenter admin attached-network create \
    --attached-network-connection-name "xmew1-dop-c-${customerOEMsuffix}-ntwk-001" \
    --network-connection-id "$network_connection_id" \
    --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001"

# Create pool
az devcenter admin pool create \
    --devbox-definition-name "xmew1-dop-c-${customerOEMsuffix}-devboxdef" \
    --local-administrator "Enabled" \
    --name "xmew1-dop-c-${customerOEMsuffix}-pools-001" \
    --project "$project" \
    --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" \
    --location "$location" \
    --network-connection-name "xmew1-dop-c-${customerOEMsuffix}-ntwk-001"
