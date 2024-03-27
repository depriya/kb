variable "OEM" {
  type        = string
}
variable "project"{
  type = string
}
variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group in which to create the Dev Center project."
  //default = "/subscriptions/${var.target_subscription_id}/resourceGroups/xmew1-dop-c-${var.OEM}-d-rg-001"
}

variable "location" {
  type        = string
  description = "The location/region in which to create the Dev Center project."
  //default = "west europe"
}

variable "devcenter_id" {
  type        = string
  description = "The ID of the Dev Center project."
  //default = "/subscriptions/${var.target_subscription_id}/resourceGroups/xmew1-dop-c-${var.OEM}-d-rg-001/providers/Microsoft.DevCenter/devcenters/xmew1-dop-c-${var.OEM}-d-dc"
}

variable "project_description" {
  type        = string
  description = "The description of the Dev Center project."
  //default = "The description of the Dev Center project."
}

variable "project_members" {
  type        = list(string)
  description = "The members of the Dev Center project."
  //default = [ "b9082dac-d369-4435-a4b9-9779f666c1e0" ]  //Alex's objectid
}

variable "environment_types" {
  type = map(object({
    name                   = string
    description            = string
    target_subscription_id = string
  }))
  description = "The environment types to create on the Dev Center project."
#   //default = {
#     "Test" = {
#       name                   = "Test"
#       description            = "Description for Test environment"
#       target_subscription_id = "db401b47-f622-4eb4-a99b-e0cebc0ebad4"
#     }
#   }
}


variable "project_name" {
  type        = string
  description = "The name of the Dev Center project."
  //default = "xmew1-dop-c-${var.OEM}-p-${var.project}-001"
}



variable "environment_name" {
  type        = string
  description = "The name of the Dev Center project."
  //default = "Test"
}

variable "target_subscription_id" {
  type        = string
  description = "The subscription ID of the target subscription."
  //default = "db401b47-f622-4eb4-a99b-e0cebc0ebad4"
}