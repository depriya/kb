terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"  
    }
    random = {
      source = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
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


data "azurerm_storage_account" "tfstate" {
    name = "xmew1dopc${var.customerOEMsuffix}${var.environmentStage}st"
    resource_group_name = data.azurerm_resource_group.example.name

}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = data.azurerm_storage_account.tfstate.name
  container_access_type = "private"
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

resource "azurerm_windows_virtual_machine_scale_set" "example" {
  name                = "xmew1-dop-c-${var.customerOEMsuffix}-p-${var.projectname}-${var.environmentStage}-vmss-001"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = var.location
  sku                 = "Standard_B2als_v2"
  instances           = 1
  admin_username      = var.admin_username
  admin_password      = random_password.vmss_password.result
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
    "commandToExecute" : "powershell.exe -ExecutionPolicy Unrestricted -Command \"net user localuser Password123 /add; net localgroup administrators localuser /add; Set-LocalUser -Name localuser -PasswordNeverExpires 0\""
  })
}

}
