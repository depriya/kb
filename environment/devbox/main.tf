terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "azapi" {
}

variable "devbox_name" {
  description = "The name of the DevBox definition"
  type        = string
  default     = "my-devbox"
}

variable "devbox_location" {
  description = "The location where the DevBox definition will be created"
  type        = string
  default     = "West Europe"
}

variable "devbox_tags" {
  description = "Tags to associate with the DevBox definition"
  type        = map(string)
  default = {
    tagName1 = "tagValue1"
    tagName2 = "tagValue2"
  }
}

resource "azapi_resource" "symbolicname" {
  type = "Microsoft.DevCenter/devcenters/devboxdefinitions@2023-04-01"
  name = var.devbox_name
  location = var.devbox_location
  parent_id = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-c-tstoem-d-rg-001/providers/Microsoft.DevCenter/devcenters/xmew1-dop-c-tstoem-d-dc"
  tags = var.devbox_tags
  body = jsonencode({
    properties = {
      hibernateSupport = "Enabled"
      imageReference = {
        id = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-s-stamp-d-rg-001/providers/Microsoft.Compute/galleries/xmew1dopsstampdcomputegallery001/images/testimage"
      }
      osStorageType = "standard"
      sku = {
        capacity = 1
        family = "standard"
        name = "DS1_v2"
        size = "Standard_DS1_v2"
        tier = "Standard"
      }
    }
  })
}