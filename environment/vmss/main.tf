terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
}

variable "oem" {
  default = "rrr"
}
variable "resource_name" {
  default = "xmew1-dop-c-oem-rrr-vmss-001"
}
variable "admin_username" {
  default = "dkpriya"
}
variable "admin_password" {
  default = "Admin@123456"
  sensitive = true
}

# #variable "vnet" {
#   default = "xmew1-dop-c-oem-vnet-001"
# }

variable "location" {
  default = "west europe"
}

# #variable "subnet" {
#   default = "OEMSubnet"
# }

data "azurerm_resource_group" "example" {
  name = "xmew1-dop-c-rrr-d-rg-001"
}

data "azurerm_virtual_network" "example" {
  name                = "xmew1-dop-c-oem-vnet-001"
  resource_group_name = data.azurerm_resource_group.example.name
}

data "azurerm_subnet" "internal" {
  name                 = "OEMSubnet"
  resource_group_name  = data.azurerm_resource_group.example.name
  virtual_network_name = data.azurerm_virtual_network.example.name
}

resource "azurerm_network_security_group" "example" {
  name                = "xmew1-dop-c-rrr-vmss-nsg"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
}

resource "azurerm_windows_virtual_machine_scale_set" "example" {
  name                 = "xmew1-dop-c-oem-rrr-vmss-008"
  resource_group_name  = data.azurerm_resource_group.example.name
  location             = data.azurerm_resource_group.example.location
  sku                  = "Standard_F2"
  instances            = 1
  admin_password       = "Azure@1234"
  admin_username       = "devipriya"
  computer_name_prefix = "vm-"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "xmew1-dop-c-rrr-vmss-nic"
    primary = true

    ip_configuration {
      name      = "rrrip"
      primary   = true
      subnet_id = data.azurerm_subnet.internal.id
    }
# Attach the NSG to the VMSS
    network_security_group_id = azurerm_network_security_group.example.id    
  }
}