#!/bin/bash

# Set variables
customerOEMsuffix="avl"
location="westeurope"
#imagename="imagedef"
image="microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os"
vnet="vnetname"
projectname="pjdb"
subnet="OEMSubnet"

# Create resource group
#az group create --name "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" --location "$location"

# Create virtual network
#az network vnet create --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" --name "xmew1-dop-c-${customerOEMsuffix}-d-vnet-001" --location "$location" --address-prefixes "10.0.0.0/16"

# Create subnet
#az network vnet subnet create --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" --vnet-name "xmew1-dop-c-${customerOEMsuffix}-d-vnet-001" --name "OEMSubnet" --address-prefix "10.0.0.0/24"

# Fetch resource IDs
existing_rg=$(az resource show --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" --resource-type "Microsoft.Resources/resourceGroups" --name "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" --query "id" -o tsv)
existing_vnet=$(az resource show --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" --resource-type "Microsoft.Network/virtualNetworks" --name "xmew1-dop-c-${customerOEMsuffix}-d-vnet-001" --query "id" -o tsv)
existing_subnet=$(az resource show --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" --resource-type "Microsoft.Network/virtualNetworks/subnets" --name "OEMSubnet" --parent "$existing_vnet" --query "id" -o tsv)
existing_devcenter=$(az resource show --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" --resource-type "Microsoft.DevCenter/devcenters" --name "xmew1-dop-c-${customerOEMsuffix}-d-dc" --query "id" -o tsv)
existing_project=$(az resource show --resource-group "xmew1-dop-c-${customerOEMsuffix}-d-rg-001" --resource-type "Microsoft.DevCenter/projects" --name "xmew1-dop-c-${customerOEMsuffix}-p-${projectname}-001" --query "id" -o tsv)

# Create devbox definition
az devcenter admin devbox-definition create --dev-center "$existing_devcenter" --devbox-definition-name "xmew1-dop-c-${customerOEMsuffix}-devboxdef" --image-reference "$existing_devcenter/galleries/default/images/$image" --os-storage-type "ssd_256gb" --resource-group "$existing_rg" --sku '{"capacity": 1, "family": "Standard", "name": "general_i_8c32gb256ssd_v2", "size": "Standard_DS1_v2", "tier": "Standard"}' --hibernate-support "Enabled" --location "$location"

# Create network connection
az devcenter admin network-connection create --domain-join-type "AzureADJoin" --name "xmew1-dop-c-${customerOEMsuffix}-ntwkcon-001" --resource-group "$existing_rg" --subnet-id "$existing_subnet" --location "$location" --networking-resource-group-name "xmew1-dop-c-${customerOEMsuffix}-d-rg-networkconnection-001"

# Create attached network
az devcenter admin attached-network create --attached-network-connection-name "xmew1-dop-c-${customerOEMsuffix}-ntwk-001" --dev-center "$existing_devcenter" --network-connection-id "$existing_rg/$(az resource show --resource-group "$existing_rg" --resource-type "Microsoft.DevCenter/networkConnections" --name "xmew1-dop-c-${customerOEMsuffix}-ntwkcon-001" --query "id" -o tsv)" --resource-group "$existing_rg"

# Create pool
az devcenter admin pool create --devbox-definition-name "xmew1-dop-c-${customerOEMsuffix}-devboxdef" --local-administrator "Enabled" --name "xmew1-dop-c-${customerOEMsuffix}-pools-001" --project "$existing_project" --resource-group "$existing_rg" --location "$location" --network-connection-name "xmew1-dop-c-${customerOEMsuffix}-ntwk-001"
