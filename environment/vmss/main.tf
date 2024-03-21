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

variable "resource_group_name" {}

variable "resource_name" {}

variable "vnet" {}

variable "location" {}

data "azurerm_resource_group" "example" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "example" {
  name                = var.vnet
  resource_group_name = data.azurerm_resource_group.example.name
  #location            = data.azurerm_resource_group.example.location
  #address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "Vmsssubnet"
  resource_group_name  = data.azurerm_resource_group.example.name
  virtual_network_name = data.azurerm_virtual_network.example.name
  address_prefixes     = ["10.6.3.0/24"]
}

resource "azurerm_windows_virtual_machine_scale_set" "example" {
  name                 = "xmew1-dop-c-tstoem-d-vmss-001"
  resource_group_name  = data.azurerm_resource_group.example.name
  location             = data.azurerm_resource_group.example.location
  sku                  = "Standard_F2"
  instances            = 1
  admin_password       = "P@55w0rd1234!"
  admin_username       = "adminuser"
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
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }
}