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

# Data sources to fetch IDs of existing resources
data "azapi_resource" "existing_devcenter" {
  type = "Microsoft.DevCenter/devcenters@2023-04-01"
  name = "xmew1-dop-c-abc-d-dc"
  parent_id = "xmew1-dop-c-abc-d-rg-001"
}

data "azapi_resource" "existing_gallery" {
  type = "Microsoft.DevCenter/devcenters/galleries@2023-04-01"
  name = "xmew1dopsstampdcomputegallery001"
  parent_id = data.azapi_resource.existing_devcenter.id
}

data "azapi_resource" "existing_project" {
  type = "Microsoft.DevCenter/projects@2023-04-01"
  name = "xmew1-dop-c-abc-d-project-001"
  parent_id = data.azapi_resource.existing_devcenter.id
}

# Define devbox definitions
resource "azapi_resource" "devbox_definition" {
  type = "Microsoft.DevCenter/devcenters/devboxdefinitions@2023-04-01"
  name = "my-devbox-definition"
  parent_id = data.azapi_resource.existing_project.id
  body = jsonencode({
    properties = {
      hibernateSupport = "Enabled"
      imageReference = {
        id = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-s-stamp-d-rg-001/providers/Microsoft.Compute/galleries/xmew1dopsstampdcomputegallery001/images/testimage"
      }
      osStorageType = "managed"
      sku = {
        capacity = 1
        family = "Standard"
        name = "DS1_v2"
        size = "Standard_DS1_v2"
        tier = "dev"
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
    properties = {
      devBoxDefinitionName = "my-devbox-definition"
      licenseType = "Windows_Client"
      localAdministrator = "admin"
      networkConnectionName = "my-attached-network"
      stopOnDisconnect = {
        gracePeriodMinutes = 30
        status = "enabled"
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
