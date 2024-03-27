terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}


provider "azapi" {
    skip_provider_registration = true
}
variable OEM{
  description = "The OEM Value in three letters"
}

variable "location"{
  default = "westeurope"
}
variable "imagename"{
    default = "imagedef"
}
# Define image and compute variables
# #variable "image" {
#   type = map(string)
#   default = {
#     win11-ent-base   = "microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os"
#   }
# }

variable "image" {
  default = "microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os"
}

variable "vnet" {
  default = "xmew1-dop-c-oem-vnet-001"
}

variable "project"{}

variable "subnet"{
   default = "OEMSubnet"
}
#variable "gallery" {
 #   default = "xmew1dopsstampdcomputegallery001"
  #  }

data "azapi_resource" "existing_rg" {
  type = "Microsoft.Resources/resourceGroups@2022-09-01"
  name = "xmew1-dop-c-${var.OEM}-d-rg-001"
}

data "azapi_resource" "existing_vnet" {
  type = "Microsoft.Network/virtualNetworks@2022-07-01"
  name = var.vnet
  parent_id = data.azapi_resource.existing_rg.id
}

data "azapi_resource" "existing_subnet" {
  type = "Microsoft.Network/virtualNetworks/subnets@2023-04-01"
  name = var.subnet
  parent_id = data.azapi_resource.existing_vnet.id
}

# Data sources to fetch IDs of existing resources
data "azapi_resource" "existing_devcenter" {
  type = "Microsoft.DevCenter/devcenters@2023-04-01"
  name = "xmew1-dop-c-${var.OEM}-d-dc"
  parent_id = data.azapi_resource.existing_rg.id
}

# #data "azapi_resource" "existing_gallery" {
#   type = "Microsoft.DevCenter/devcenters/galleries@2023-04-01"
#   name = var.gallery
#   parent_id = data.azapi_resource.existing_devcenter.id
# }

data "azapi_resource" "existing_project" {
  type = "Microsoft.DevCenter/projects@2023-04-01"
  name = "xmew1-dop-c-${var.OEM}-p-${var.project}-001"
  parent_id = data.azapi_resource.existing_rg.id
}


# Define devbox definitions
resource "azapi_resource" "devbox_definition" {
  type = "Microsoft.DevCenter/devcenters/devboxdefinitions@2023-04-01"
  name = "xmew1-dop-c-${var.OEM}-devboxdef"
  parent_id = data.azapi_resource.existing_devcenter.id
  body = jsonencode({
    location = "${var.location}"
    properties = {
      hibernateSupport = "Enabled"
      "imageReference": {
      //id = "${data.azapi_resource.existing_devcenter.id}/galleries/${var.gallery}/images/${var.imagename}"
    id = "${data.azapi_resource.existing_devcenter.id}/galleries/default/images/${var.image}"
}

      osStorageType = "ssd_256gb"
      sku = {
        capacity = 1
        family = "Standard"
        name = "general_i_8c32gb256ssd_v2"
        size = "Standard_DS1_v2"
        tier = "Standard"
      }
    }
  })
}

# Define pools
resource "azapi_resource" "pool" {
  type = "Microsoft.DevCenter/projects/pools@2023-04-01"
  name = "xmew1-dop-c-${var.OEM}-pools-001"
  parent_id = data.azapi_resource.existing_project.id
  body = jsonencode({
    location = "${var.location}"
    properties = {
      devBoxDefinitionName = "xmew1-dop-c-${var.OEM}-devboxdef"
      licenseType = "Windows_Client"
      localAdministrator = "Enabled"
      networkConnectionName = "xmew1-dop-c-${var.OEM}-ntwk-001"
      
    }
  })
   depends_on = [azapi_resource.networkConnection]
}

# Define attached network
resource "azapi_resource" "networkConnection" {
  type = "Microsoft.DevCenter/networkConnections@2023-01-01-preview"
  name = "xmew1-dop-c-${var.OEM}-ntwkcon-001"
  parent_id = data.azapi_resource.existing_rg.id
  body = jsonencode({
    location = "${var.location}"
    properties = {
      domainJoinType = "AzureADJoin"
      subnetId = "${data.azapi_resource.existing_subnet.id}"
      //subnetId = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-c-abc-d-rg-001/providers/Microsoft.Network/virtualNetworks/xmew1-dop-c-oem-vnet-001/subnets/OEMSubnet"
      networkingResourceGroupName = "xmew1-dop-c-${var.OEM}-d-rg-networkconnection-001"
    }
  })
}

resource "azapi_resource" "attachedNetworks" {
  type = "Microsoft.DevCenter/devcenters/attachednetworks@2023-01-01-preview"
  name = "xmew1-dop-c-${var.OEM}-ntwk-001"
  parent_id = data.azapi_resource.existing_devcenter.id
  body = jsonencode({
    properties = {
      networkConnectionId = "${azapi_resource.networkConnection.id}"
    }
  })
   depends_on = [azapi_resource.networkConnection]
}




