terraform {
  backend "azurerm" {
    resource_group_name  = data.azurerm_storage_account.tfstate.resource_group_name
    storage_account_name = data.azurerm_storage_account.tfstate.name
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}