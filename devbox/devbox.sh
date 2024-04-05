#!/bin/bash

# Set variables
customerOEMsuffix="avl"
location="westeurope"
image="/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-c-avl-d-rg-001/providers/Microsoft.DevCenter/devcenters/xmew1-dop-c-avl-d-dc/galleries/default/images/microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os"
projectname="pjdb"
project="xmew1-dop-c-${customerOEMsuffix}-p-${projectname}-001"
DEV_CENTER_NAME="xmew1-dop-c-${customerOEMsuffix}-d-dc"
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
    --devbox-definition-name "xmew1-dop-c-${customerOEMsuffix}-devboxdef" \
    --image-reference '{"id": "'$image'"}' \
    --os-storage-type $osstoragetype \
    --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" \
    --sku "{\"capacity\": $capacity, \"family\": \"$family\", \"name\": \"$compute\", \"size\": \"$size\", \"tier\": \"$tier\"}" \
    --hibernate-support "Enabled" \
    --location "$location"

# Create network connection
az devcenter admin network-connection create \
    --domain-join-type "AzureADJoin" \
    --name "xmew1-dop-c-${customerOEMsuffix}-ntwkcon-001" \
    --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" \
    --subnet-id "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-c-avl-d-rg-001/providers/Microsoft.Network/virtualNetworks/xmew1-dop-c-avl-d-vnet-001/subnets/OEMSubnet" \
    --location "$location" \
    --networking-resource-group-name "xmew1-dop-c-${customerOEMsuffix}-d-rg-networkconnection-001"

# Create attached network
az devcenter admin attached-network create \
    --attached-network-connection-name "xmew1-dop-c-${customerOEMsuffix}-ntwk-001" \
    --dev-center $DEV_CENTER_NAME \
    --network-connection-id "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-c-avl-d-rg-001/providers/Microsoft.DevCenter/networkConnections/xmew1-dop-c-avl-d-ntwkcon-001" \
    --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001"

# Create pool
az devcenter admin pool create \
    --devbox-definition-name "xmew1-dop-c-${customerOEMsuffix}-devboxdef" \
    --local-administrator "Enabled" \
    --name "xmew1-dop-c-${customerOEMsuffix}-pools-001" \
    --project $project \
    --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" \
    --location "$location" \
    --network-connection-name "xmew1-dop-c-${customerOEMsuffix}-ntwk-001"
