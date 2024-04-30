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
     resource_group_name  = "xmew1-dop-s-stamp-d-rg-001"
     storage_account_name = "xmew1dopsdst"
     container_name       = "tfstate"
     key                  = "terraform.tfstate"
     #use_oidc             = true
  #   client_id = "13b095e6-55df-4d76-9c6d-b59404e4d506"
  #   tenant_id = "b4bc7e59-9a34-4622-ab54-d7a1a680f47a"
  #   subscription_id = "db401b47-f622-4eb4-a99b-e0cebc0ebad4"
   }
}


provider "azurerm" {
  #use_oidc = true
  features {}
}

provider "random" {}

variable "customerOEMsuffix" {
  //default = "avl"
}

variable "projectname" {
  //default = "pj2"
}

variable "admin_username" {
  //default = "avluser"
}
variable "vmss_uniquesuffix" {
  //default = "012"
}
variable "admin_password_length" {
  description = "The length of the generated admin password"
  default     = 20
}

variable "location" {
  //default = "westeurope"
}

variable "environmentStage" {
  //default = "d"
}

variable "gallery_name" {
  //default = "xmew1dopsstampdcomputegallery001"
}
variable "IMAGE_NAME"{
  default = "node-sms-silver-mc-concerto-generalized"
  // $image_name="$image_offer`ModelConnect$MCBaseVersion`Concerto$ConcertoVersion"
}
variable "SHARED_RESOURCE_GROUP"{
  // default = "xmew1-dop-s-stamp-d-rg-001"
}
variable "storage_account_type"{
  //default = "Standard_LRS"
}
variable "caching"{
  //default = "ReadWrite"
}
variable "sku"{
  //default = "Standard_B2als_v2"
}
variable "instances"{
  //default = "1"
}

data "azurerm_resource_group" "example" {
  name = "xmew1-dop-c-${var.customerOEMsuffix}-${var.environmentStage}-rg-001"
}

data "azurerm_key_vault" "example" {
  name                = "xmew1-dop-c-${var.customerOEMsuffix}-${var.environmentStage}-kv" 
  resource_group_name = data.azurerm_resource_group.example.name
}

data "azurerm_virtual_network" "example" {
  name                = "xmew1-dop-c-${var.customerOEMsuffix}-${var.environmentStage}-vnet-001"
  resource_group_name = data.azurerm_resource_group.example.name
}

data "azurerm_subnet" "internal" {
  name                 = "xmew1-dop-c-${var.customerOEMsuffix}-${var.environmentStage}-vnet-001-subnet"
  resource_group_name  = data.azurerm_resource_group.example.name
  virtual_network_name = data.azurerm_virtual_network.example.name
}
data "azurerm_shared_image_gallery" "example"{
      resource_group_name = var.SHARED_RESOURCE_GROUP
      name        = var.gallery_name
}

data "azurerm_shared_image" "all" {
  name                = var.IMAGE_NAME
  resource_group_name = var.SHARED_RESOURCE_GROUP
  gallery_name        = var.gallery_name
}

//data "azurerm_shared_image" "all" {
  //for_each = toset(data.azurerm_shared_image_gallery.example.image_names)

  //name                = each.value
  //resource_group_name = var.SHARED_RESOURCE_GROUP
  //gallery_name        = var.gallery_name
//}
// make it variable - sms
//locals {
  //filtered_images = [
    //for image in values(data.azurerm_shared_image.all) :
    //image
    //if image.name != null && can(regex("${var.IMAGE_NAME}", image.name))    
  //]
//}
//output "filtered_images" {
  //value = local.filtered_images
//}

resource "random_password" "vmss_password" {
  length  = var.admin_password_length
  special = true
}

resource "azurerm_key_vault_secret" "admin_password_secret" {
  name         = "vmss-admin-password-value-vmss-${var.vmss_uniquesuffix}"
  value        = random_password.vmss_password.result
  key_vault_id = data.azurerm_key_vault.example.id
}


resource "random_password" "local_user_password" {
  length  = var.admin_password_length
  special = true
}

resource "azurerm_key_vault_secret" "local_user_password_secret" {
  name         = "local-user-password-value-vmss-${var.vmss_uniquesuffix}"
  value        = random_password.local_user_password.result
  key_vault_id = data.azurerm_key_vault.example.id
}

 resource "azurerm_network_security_group" "example" {
  name                = "xmew1-dop-c-${var.customerOEMsuffix}-p-${var.projectname}-${var.environmentStage}-vmssnsg-${var.vmss_uniquesuffix}"
   location            = data.azurerm_resource_group.example.location
   resource_group_name = data.azurerm_resource_group.example.name
 }

resource "azurerm_windows_virtual_machine_scale_set" "example" {
  name                = "xmew1-dop-c-${var.customerOEMsuffix}-p-${var.projectname}-${var.environmentStage}-vmss-${var.vmss_uniquesuffix}"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = var.location
  sku                 = var.sku
  instances           = var.instances
  admin_username      = var.admin_username
  //admin_password      = random_password.vmss_password.result  
  admin_password      = azurerm_key_vault_secret.admin_password_secret.value
  computer_name_prefix = "vm"
  secure_boot_enabled = true
  vtpm_enabled = true

  source_image_id = data.azurerm_shared_image.all.id

  os_disk {
    storage_account_type = var.storage_account_type
    caching              = var.caching
  }

  network_interface {
    name    = "xmew1-dop-c-${var.customerOEMsuffix}-p-${var.projectname}-${var.environmentStage}-vmssnic-${var.vmss_uniquesuffix}"
    primary = true

    ip_configuration {
      name      = "${var.customerOEMsuffix}${var.projectname}${var.environmentStage}ip${var.vmss_uniquesuffix}"
      primary   = true
      subnet_id = data.azurerm_subnet.internal.id
    }
    # Attach the NSG to the VMSS
    network_security_group_id = azurerm_network_security_group.example.id
  }

 extension {
  name                 = "CustomScriptExtension"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    "commandToExecute" : "powershell.exe -ExecutionPolicy Unrestricted -Command \"New-LocalUser -Name Devops_Engineer -Password (ConvertTo-SecureString -AsPlainText '${azurerm_key_vault_secret.local_user_password_secret.value}' -Force) -PasswordNeverExpires:$false; Add-LocalGroupMember -Group 'Remote Desktop Users' -Member Devops_Engineer\""
  //"commandToExecute" : "powershell.exe -ExecutionPolicy Unrestricted -Command \"New-LocalUser -Name TestEngineer -Password (ConvertTo-SecureString -AsPlainText 'Password123' -Force) -PasswordNeverExpires:$false -UserMayChangePassword:$true\""
  })
}

}
