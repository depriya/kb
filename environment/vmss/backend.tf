terraform {
  backend "azurerm" {
    resource_group_name  = "xmew1-dop-c-${var.customerOEMsuffix}-${var.environmentStage}-rg-001"
    storage_account_name = "xmew1dopc${var.customerOEMsuffix}${var.environmentStage}st"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}