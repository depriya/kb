terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"  
    }
    random = {
      source = "hashicorp/random"
    }
  }

  backend "azurerm" {
    resource_group_name  = "xmew1-dop-c-avl-d-rg-001"
    storage_account_name = "xmew1dopcavldst"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
    client_id = "13b095e6-55df-4d76-9c6d-b59404e4d506"
    tenant_id = "b4bc7e59-9a34-4622-ab54-d7a1a680f47a"
    subscription_id = "db401b47-f622-4eb4-a99b-e0cebc0ebad4"
  }
}


provider "azurerm" {
  use_oidc = true
  features {}
}

provider "random" {}

variable "customerOEMsuffix" {
  default = "avl"
}

variable "projectname" {
  default = "pj9"
}

variable "admin_username" {
  default = "avluser"
}

variable "admin_password_length" {
  description = "The length of the generated admin password"
  default     = 20
}

variable "location" {
  default = "westeurope"
}

variable "environmentStage" {
  default = "d"
}

variable "gallery_name" {
  default = "xmew1dopsstampdcomputegallery001"
}

variable "existing_key_vault_name" {
  description = "Name of the existing Azure Key Vault"
  default     = "xmew1-dop-s-d-k-v001"
}

variable "existing_key_vault_resource_group_name" {
  description = "Resource Group name of the existing Azure Key Vault"
  default     = "xmew1-dop-s-stamp-d-rg-001"
}

data "azurerm_key_vault" "example" {
  name                = var.existing_key_vault_name
  resource_group_name = var.existing_key_vault_resource_group_name
}

data "azurerm_resource_group" "example" {
  name = "xmew1-dop-c-${var.customerOEMsuffix}-${var.environmentStage}-rg-001"
}

data "azurerm_virtual_network" "example" {
  name                = "xmew1-dop-c-${var.customerOEMsuffix}-${var.environmentStage}-vnet-001"
  resource_group_name = data.azurerm_resource_group.example.name
}

data "azurerm_subnet" "internal" {
  name                 = "OEMSubnet"
  resource_group_name  = data.azurerm_resource_group.example.name
  virtual_network_name = data.azurerm_virtual_network.example.name
}
data "azurerm_shared_image_gallery" "example"{
      resource_group_name = "xmew1-dop-s-stamp-d-rg-001"
      name        = var.gallery_name
}
data "azurerm_shared_image" "all" {
  for_each = toset(data.azurerm_shared_image_gallery.example.image_names)

  name                = each.value
  resource_group_name = "xmew1-dop-s-stamp-d-rg-001"
  gallery_name        = var.gallery_name
}

locals {
  filtered_images = [
    for image in values(data.azurerm_shared_image.all) :
    image
    if image.name != null && can(regex("sms", image.name))
  ]
}
output "filtered_images" {
  value = local.filtered_images
}

resource "random_password" "vmss_password" {
  length  = var.admin_password_length
  special = true
}

resource "azurerm_key_vault_secret" "admin_password_secret" {
  name         = "vmss-admin-password"
  value        = random_password.vmss_password.result
  key_vault_id = data.azurerm_key_vault.example.id
}

resource "azurerm_windows_virtual_machine_scale_set" "example" {
  name                = "xmew1-dop-c-${var.customerOEMsuffix}-p-${var.projectname}-${var.environmentStage}-vmss-001"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = var.location
  sku                 = "Standard_B2als_v2"
  instances           = 1
  admin_username      = var.admin_username
  //admin_password      = random_password.vmss_password.result  
  admin_password      = azurerm_key_vault_secret.admin_password_secret.value
  computer_name_prefix = "vm"
  secure_boot_enabled = true
  vtpm_enabled = true

  source_image_id = local.filtered_images[0].id


#  //source_image_id = data.azurerm_gallery_image.jfrog_image[0].id
# source_image_reference {
#     publisher = local.filtered_images[0].identifier[0].publisher
#     offer     = local.filtered_images[0].identifier[0].offer
#     sku       = local.filtered_images[0].identifier[0].sku
#     version   = "latest"
//}
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "xmew1-dop-c-${var.customerOEMsuffix}-p-${var.projectname}-${var.environmentStage}-vmss-nic"
    primary = true

    ip_configuration {
      name      = "${var.customerOEMsuffix}${var.projectname}${var.environmentStage}ip"
      primary   = true
      subnet_id = data.azurerm_subnet.internal.id
    }
  }

 extension {
  name                 = "CustomScriptExtension"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({

       "commandToExecute" : "powershell.exe -ExecutionPolicy Unrestricted -Command \"New-LocalUser -Name 'TestEngineer' -Description 'devbox user.' -NoPassword\""
    // "commandToExecute" : "powershell.exe -ExecutionPolicy Unrestricted -Command \"New-LocalUser -Name TestEngineer -Password (ConvertTo-SecureString -AsPlainText 'Password123' -Force) -PasswordNeverExpires:$false -UserMayChangePassword:$true\""
    //"commandToExecute" : "powershell.exe -ExecutionPolicy Unrestricted -Command \"net user localuser Password123 /add; net localgroup administrators localuser /add; Set-LocalUser -Name localuser -PasswordNeverExpires 0\""
  })
}

}
