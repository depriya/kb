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

variable "devbox_properties" {
  description = "Properties of the DevBox definition"
  type        = map(any)
  default = {
    hibernateSupport = "enabled"
    imageReference_id = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-s-stamp-d-rg-001/providers/Microsoft.Compute/galleries/xmew1dopsstampdcomputegallery001/images/DevopsPilot_TestImage"
    osStorageType = "standard"
    sku_capacity = 1
    sku_family   = "standard"
    sku_name     = "DS1_v2"
    sku_size     = "Standard_DS1_v2"
    sku_tier     = "Standard"
  }
}

resource "azapi_resource" "devbox" {
  type      = "Microsoft.DevCenter/devcenters/devboxdefinitions@2023-04-01"
  name      = var.devbox_name
  location  = var.devbox_location
  tags      = var.devbox_tags
  parent_id = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-c-tstoem-d-rg-001/providers/Microsoft.DevCenter/devcenters/xmew1-dop-c-tstoem-d-dc"
  body      = jsonencode({ properties = var.devbox_properties })
}
