provider "azurerm" {
  features {}  # Adding features block to enable experimental features
}
resource "azurerm_dev_center" "dc" {
  name                = var.devcenter
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  identity {
    type = "SystemAssigned"
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