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

variable "Project" {
   default = "xmew1-dop-c-${var.OEM}-d-project-001"
}

variable "devcenter" {
    default = "xmew1-dop-c-${var.OEM}-d-dc"
}

variable "definition" {
    default = "xmew1-dop-c-${var.OEM}-devboxdef"
}

variable "resourcegroup" {
    default = "xmew1-dop-c-${var.OEM}-d-rg-001"
}

variable "attachednetwork" {
    default = "xmew1-dop-c-${var.OEM}-ntwk-001"
}

variable "networkconnection"{
    default = "xmew1-dop-c-${var.OEM}-ntwkcon-001"
}

variable "networkrg" {
  default = "xmew1-dop-c-${var.OEM}-d-rg-networkconnection-001"
}
variable "location"{
  default = "westeurope"
}
variable "imagename"{
    default = "imagedef"
}
# Define image and compute variables
variable "image" {
  type = map(string)
  default = {
    win11-ent-base   = "microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os"
  }
}
variable "pool" {
    default = "xmew1-dop-c-${var.OEM}-pools-001"
}

variable "vnet" {
  default = "xmew1-dop-c-oem-vnet-001"
}

variable "subnet"{
   default = "OEMSubnet"
}
variable "gallery" {
    default = "xmew1dopsstampdcomputegallery001"
    }

data "azapi_resource" "existing_rg" {
  type = "Microsoft.Resources/resourceGroups@2022-09-01"
  name = var.resourcegroup
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
  name = var.devcenter
  parent_id = data.azapi_resource.existing_rg.id
}

data "azapi_resource" "existing_gallery" {
  type = "Microsoft.DevCenter/devcenters/galleries@2023-04-01"
  name = var.gallery
  parent_id = data.azapi_resource.existing_devcenter.id
}

data "azapi_resource" "existing_project" {
  type = "Microsoft.DevCenter/projects@2023-04-01"
  name = var.Project
  parent_id = data.azapi_resource.existing_rg.id
}
# Define devbox definitions
resource "azapi_resource" "devbox_definition" {
  type = "Microsoft.DevCenter/devcenters/devboxdefinitions@2023-04-01"
  name = var.definition
  parent_id = data.azapi_resource.existing_devcenter.id
  body = jsonencode({
    location = "${var.location}"
    properties = {
      hibernateSupport = "Enabled"
      "imageReference": {
      //id = "${data.azapi_resource.existing_devcenter.id}/galleries/${var.gallery}/images/${var.imagename}"
    id = "${data.azapi_resource.existing_devcenter.id}/galleries/default/images/${var.image["win11-ent-base"]}"
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
  name = var.pool
  parent_id = data.azapi_resource.existing_project.id
  body = jsonencode({
    location = "${var.location}"
    properties = {
      devBoxDefinitionName =  "${var.definition}"
      licenseType = "Windows_Client"
      localAdministrator = "Enabled"
      networkConnectionName = "${var.attachednetwork}"
      
    }
  })
   depends_on = [azapi_resource.networkConnection]
}

# Define attached network
resource "azapi_resource" "networkConnection" {
  type = "Microsoft.DevCenter/networkConnections@2023-01-01-preview"
  name = var.networkconnection
  parent_id = data.azapi_resource.existing_rg.id
  body = jsonencode({
    location = "${var.location}"
    properties = {
      domainJoinType = "AzureADJoin"
      subnetId = "${data.azapi_resource.existing_subnet.id}"
      //subnetId = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-c-abc-d-rg-001/providers/Microsoft.Network/virtualNetworks/xmew1-dop-c-oem-vnet-001/subnets/OEMSubnet"
      networkingResourceGroupName = "${var.networkrg}"
    }
  })
}

resource "azapi_resource" "attachedNetworks" {
  type = "Microsoft.DevCenter/devcenters/attachednetworks@2023-01-01-preview"
  name = var.attachednetwork
  parent_id = data.azapi_resource.existing_devcenter.id
  body = jsonencode({
    properties = {
      networkConnectionId = "${azapi_resource.networkConnection.id}"
    }
  })
   depends_on = [azapi_resource.networkConnection]
}



# Define environment types
resource "azapi_resource" "environment_type" {
  type = "Microsoft.DevCenter/devcenters/environmentTypes@2023-04-01"
  name = "sandbox"
  parent_id = data.azapi_resource.existing_devcenter.id
  body = jsonencode({
    properties = {}
  })
}
