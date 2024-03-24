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

# Define image and compute variables
variable "image" {
  type = map(string)
  default = {
    win11-ent-base   = "microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os"
  }
}



# Data sources to fetch IDs of existing resources
data "azapi_resource" "existing_devcenter" {
  type = "Microsoft.DevCenter/devcenters@2023-04-01"
  name = "xmew1-dop-c-abc-d-dc"
  parent_id = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-c-abc-d-rg-001"
}

data "azapi_resource" "existing_gallery" {
  type = "Microsoft.DevCenter/devcenters/galleries@2023-04-01"
  name = "xmew1dopsstampdcomputegallery001"
  parent_id = data.azapi_resource.existing_devcenter.id
}

data "azapi_resource" "existing_project" {
  type = "Microsoft.DevCenter/projects@2023-04-01"
  name = "xmew1-dop-c-abc-d-project-001"
  parent_id = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-c-abc-d-rg-001"
}
# Define devbox definitions
resource "azapi_resource" "devbox_definition" {
  type = "Microsoft.DevCenter/devcenters/devboxdefinitions@2023-04-01"
  name = "xmew1-dop-c-abc-devboxdef"
  parent_id = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-c-abc-d-rg-001/providers/Microsoft.DevCenter/devcenters/xmew1-dop-c-abc-d-dc"
  body = jsonencode({
    location = "westeurope"
    properties = {
      hibernateSupport = "Enabled"
      "imageReference": {
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
  name = "xmew1-dop-c-abc-pools-001"
  parent_id = data.azapi_resource.existing_project.id
  body = jsonencode({
    location = "westeurope"
    properties = {
      devBoxDefinitionName =  "xmew1-dop-c-abc-devboxdef"
      licenseType = "Windows_Client"
      localAdministrator = "Enabled"
      networkConnectionName = "xmew1-dop-c-abc-ntwk-001"
      
    }
  })
   depends_on = [azapi_resource.networkConnection]
}

# Define attached network
resource "azapi_resource" "networkConnection" {
  type = "Microsoft.DevCenter/networkConnections@2023-01-01-preview"
  name = "xmew1-dop-c-abc-ntwkcon-001"
  parent_id = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-c-abc-d-rg-001"
  body = jsonencode({
    location = "westeurope"
    properties = {
      domainJoinType = "AzureADJoin"
      subnetId = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-c-abc-d-rg-001/providers/Microsoft.Network/virtualNetworks/xmew1-dop-c-oem-vnet-001/subnets/OEMSubnet"
      networkingResourceGroupName = "xmew1-dop-c-abc-d-rg-networkconnection-001"
    }
  })
}

resource "azapi_resource" "attachedNetworks" {
  type = "Microsoft.DevCenter/devcenters/attachednetworks@2023-01-01-preview"
  name = "xmew1-dop-c-abc-ntwk-001"
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
