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
    #win11-ent-m365   = "microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365"
    #win11-ent-vs2022 = "microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2"
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
  name = "my-devbox-definition"
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
  name = "my-pool"
  parent_id = data.azapi_resource.existing_project.id
  body = jsonencode({
    location = "West Europe"
    properties = {
      devBoxDefinitionName = "my-devbox-definition"
      licenseType = "Windows_Client"
      localAdministrator = "Enabled"
      networkConnectionName = "my-attached-network"
      stopOnDisconnect = {
        gracePeriodMinutes = 60
        status = "Enabled"
      }
    }
  })
}

# Define attached network
resource "azapi_resource" "attached_network" {
  type = "Microsoft.DevCenter/devcenters/attachednetworks@2023-04-01"
  name = "my-attached-network"
  parent_id = data.azapi_resource.existing_devcenter.id
  body = jsonencode({
    properties = {
      networkConnectionId = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-c-abc-d-rg-001/providers/Microsoft.Network/networkInterfaces/xmew1-dop-c-abc-d-pe-001.nic.dcd39cd4-3c18-4993-94a4-47a47cecb69d"
    }
  })
}

# Define environment types
resource "azapi_resource" "environment_type" {
  type = "Microsoft.DevCenter/devcenters/environmentTypes@2023-04-01"
  name = "my-environment-type"
  parent_id = data.azapi_resource.existing_devcenter.id
  body = jsonencode({
    properties = {}
  })
}
