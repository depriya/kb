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
}

variable "customerOEMsuffix" {
    default = "avl"
}
variable "projectname" {
    default = "pj"
}
variable "admin_username" {
    default = "devipriya"
}
variable "admin_password" {
  sensitive = true
  default = "Azure@1234"
}
variable "location" {
  default = "west europe"
}
variable "environmentStage" {
    default = "d"
}

resource "azurerm_resource_group" "example" {
  name     = "xmew1-dop-c-${var.customerOEMsuffix}-${var.environmentStage}-rg-001"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "xmew1-dop-c-${var.customerOEMsuffix}-${var.environmentStage}-vnet-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "OEMSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "example" {
  name                = "xmew1-dop-c-${var.customerOEMsuffix}-p-${var.projectname}-${var.environmentStage}-vmss-nsg12"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_windows_virtual_machine_scale_set" "example" {
  name                = "xmew1-dop-c-${var.customerOEMsuffix}-p-${var.projectname}-${var.environmentStage}-vmss-012"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard_F2"
  instances           = 1
  admin_password      = var.admin_password
  admin_username      = var.admin_username
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
    name    = "xmew1-dop-c-${var.customerOEMsuffix}-p-${var.projectname}-${var.environmentStage}-vmss-nic12"
    primary = true

    ip_configuration {
      name      = "${var.customerOEMsuffix}${var.projectname}${var.environmentStage}ip12"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
    # Attach the NSG to the VMSS
    network_security_group_id = azurerm_network_security_group.example.id
  }

  provisioner "remote-exec" {
    inline = [
      # Download and install Azure CLI
      "Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile AzureCLI.msi",
      "Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'",
      # Add Azure CLI to the PATH environment variable
      "$env:Path += ';C:\\Program Files (x86)\\Microsoft SDKs\\Azure\\CLI2\\wbin'"
    ]

    connection {
      type     = "winrm"
      user     = var.admin_username
      password = var.admin_password
      # Use the private IP address of the VMSS instances
      host     = azurerm_virtual_machine_scale_set_vm.example[0].private_ip_address
      timeout  = "5m"

      # Configure WinRM connection options
      insecure = true
      port     = 5986
    }
  }
}
