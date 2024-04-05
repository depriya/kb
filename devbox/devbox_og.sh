#!/bin/bash

# Set variables
customerOEMsuffix="avl"
location="westeurope"
projectname="pjdb"
project="xmew1-dop-c-${customerOEMsuffix}-p-${projectname}-001"
image="microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os"
DEV_CENTER_NAME="xmew1-dop-c-${customerOEMsuffix}-d-dc"
RESOURCE_GROUP="xmew1-dop-c-${customerOEMsuffix}-d-rg-001"
devbox_definition_name="xmew1-dop-c-${customerOEMsuffix}-devboxdef"
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

# Create devbox definition
az devcenter admin devbox-definition create \
    --dev-center $DEV_CENTER_NAME \
    --devbox-definition-name $devbox_definition_name \
    --image-reference "{\"id\": \"/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/devcenters/$DEV_CENTER_NAME/galleries/default/images/$image\"}" \
    --os-storage-type $osstoragetype \
    --resource-group $RESOURCE_GROUP \
    --sku "{\"capacity\": $capacity, \"family\": \"$family\", \"name\": \"$compute\", \"size\": \"$size\", \"tier\": \"$tier\"}" \
    --hibernate-support "Enabled" \
    --location "$location"

# Fetch subnet ID
subnet_id=$(az network vnet subnet show --name OEMSubnet --vnet-name xmew1-dop-c-${customerOEMsuffix}-d-vnet-001 --resource-group xmew1-dop-c-${customerOEMsuffix}-d-rg-001 --query id --output tsv)

# Create network connection
az devcenter admin network-connection create \
    --domain-join-type "AzureADJoin" \
    --name "xmew1-dop-c-${customerOEMsuffix}-ntwkcon-001" \
    --resource-group $RESOURCE_GROUP \
    --subnet-id "$subnet_id" \
    --location "$location" \
    --networking-resource-group-name "xmew1-dop-c-${customerOEMsuffix}-d-rg-networkconnection-001"

# Fetch network connection ID
network_connection_id=$(az devcenter admin network-connection show --name "xmew1-dop-c-${customerOEMsuffix}-ntwkcon-001" --resource-group "$RESOURCE_GROUP" --query id --output tsv)

# Create attached network
az devcenter admin attached-network create \
    --attached-network-connection-name "xmew1-dop-c-${customerOEMsuffix}-ntwk-001" \
    --network-connection-id "$network_connection_id" \
    --resource-group $RESOURCE_GROUP \
    --dev-center $DEV_CENTER_NAME

# Create pool
az devcenter admin pool create \
    --devbox-definition-name $devbox_definition_name \
    --local-administrator "Enabled" \
    --name "xmew1-dop-c-${customerOEMsuffix}-pools-001" \
    --project "$project" \
    --resource-group $RESOURCE_GROUP \
    --location "$location" \
    --network-connection-name "xmew1-dop-c-${customerOEMsuffix}-ntwk-001"
