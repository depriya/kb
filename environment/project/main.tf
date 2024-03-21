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
  name                = "example-image-gallery"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dev_center_gallery" "example" {
  dev_center_id     = azurerm_dev_center.dc.id
  shared_gallery_id = azurerm_shared_image_gallery.example.id
  name              = "example"
}