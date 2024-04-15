terraform {
  backend "azurerm" {
    resource_group_name  = "xmew1-dop-c-avl-d-rg-001"
    storage_account_name = "xmew1dopcavldst"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}