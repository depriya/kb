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
  name                = var.gallery_name
  resource_group_name = "xmew1-dop-s-stamp-d-rg-001"
}
# Define the data source to list all shared images
data "azurerm_shared_image" "all" {
  resource_group_name = "xmew1-dop-s-stamp-d-rg-001"
  gallery_name        = var.gallery_name
  name                = ""
}

# Use local-exec to filter the images by name pattern
resource "null_resource" "filter_images" {
  triggers = {
    filter = jsonencode({
      images = data.azurerm_shared_image.all.names
    })
  }

  provisioner "local-exec" {
    command = <<-EOT
      filtered_images=()
      for image in $(echo '${jsonencode(data.azurerm_shared_image.all.names)}' | jq -r '.[]'); do
        if [[ $image == *"sms"* ]]; then
          filtered_images+=("$image")
        fi
      done
    EOT
  
    interpreter = ["bash", "-c"]
  }
}

# Extract the filtered image names from the local-exec output
locals {
  filtered_image_names = jsondecode(null_resource.filter_images.result)["filtered_images"]
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

 //source_image_id = data.azurerm_gallery_image.jfrog_image[0].id
  dynamic "storage_image_reference" {
    for_each = [local.filtered_image_names[count.index]]
    content {
      id = data.azurerm_shared_image.selected[count.index].id
    }
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
