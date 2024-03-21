provider "azurerm" {
  features {}  # Adding features block to enable experimental features
}
resource "azurerm_dev_center" "dc" {
  name                = var.devcenter
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}
resource "azurerm_resource_group" "rg" {
  name     = var.rgName
  location = "West Europe"
}
resource "azurerm_dev_center_project" "project" {
  dev_center_id       = azurerm_dev_center.dc.id
  location            = azurerm_resource_group.rg.location
  name                = var.projectname
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "example-uai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_shared_image_gallery" "example" {
  name                = "xmew1dopsstampdcomputegallery001"
  location = azurerm_resource_group.rg.location
  resource_group_name = "xmew1-dop-s-stamp-d-rg-001"
}

resource "null_resource" "link_gallery_to_devcenter" {
  provisioner "local-exec" {
    command = "az devcenter gallery update --name ${azurerm_dev_center.dc.name} --gallery-name ${azurerm_shared_image_gallery.example.name} --resource-group ${azurerm_dev_center.dc.resource_group_name} --subscription db401b47-f622-4eb4-a99b-e0cebc0ebad4"
  }
  depends_on = [azurerm_dev_center.dc, azurerm_shared_image_gallery.example]
}
