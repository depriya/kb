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

data "azurerm_shared_image_gallery" "example" {
  name                = "xmew1dopsstampdcomputegallery001"
  resource_group_name = "xmew1-dop-s-stamp-d-rg-001"
}

data "azurerm_shared_image" "example" {
  for_each = data.azurerm_shared_image_gallery.example

  name                = each.value.name
  gallery_name        = data.azurerm_shared_image_gallery.example.name
  resource_group_name = data.azurerm_shared_image_gallery.example.resource_group_name
}

locals {
  matching_images = [
    for name, img in data.azurerm_shared_image.example :
    img.id if contains(upper(name), "SMS")
  ]

  selected_image = length(local.matching_images) > 0 ? local.matching_images[0] : null

  image_info = length(local.matching_images) > 0 ? split("/", local.selected_image) : null

  publisher = length(local.matching_images) > 0 ? local.image_info[6] : null
  offer     = length(local.matching_images) > 0 ? local.image_info[8] : null
  sku       = length(local.matching_images) > 0 ? local.image_info[10] : null
  version   = length(local.matching_images) > 0 ? local.image_info[12] : null
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

  source_image_reference {
    publisher = local.publisher
    offer     = local.offer
    sku       = local.sku
    version   = local.version
  }

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
      script = "net user localuser Password123 /add && net localgroup administrators localuser /add && powershell -Command \"Set-LocalUser -Name localuser -PasswordNeverExpires 0\""
    })
  }
}
