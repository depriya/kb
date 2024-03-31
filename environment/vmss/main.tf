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

variable "customerOEMsuffix" {
}
variable "projectname" {
}
variable "admin_username" {
}
variable "admin_password" {
  sensitive = true
}

variable "location" {
  default = "west europe"
}

variable "environmentStage"{
  
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

resource "azurerm_network_security_group" "example" {
  name                = "xmew1-dop-c-${var.customerOEMsuffix}-p-${var.projectname}-${var.environmentStage}-vmss-nsg"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
}

resource "azurerm_windows_virtual_machine_scale_set" "example" {
  name                 = "xmew1-dop-c-${var.customerOEMsuffix}-p-${var.projectname}-${var.environmentStage}-vmss-001"
  resource_group_name  = data.azurerm_resource_group.example.name
  location             = data.azurerm_resource_group.example.location
  sku                  = "Standard_F2"
  instances            = 1
  admin_password       = var.admin_password
  admin_username       = var.admin_username
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
    name    = "xmew1-dop-c-${var.customerOEMsuffix}-p-${var.projectname}-${var.environmentStage}-vmss-nic"
    primary = true

    ip_configuration {
      name      = "${var.customerOEMsuffix}${var.projectname}${var.environmentStage}ip"
      primary   = true
      subnet_id = data.azurerm_subnet.internal.id
    }
# Attach the NSG to the VMSS
    network_security_group_id = azurerm_network_security_group.example.id    
  }
}