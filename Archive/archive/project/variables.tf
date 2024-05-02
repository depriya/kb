variable "OEM" {
  type        = string
}
variable "project"{
  type = string
}
# variable "resource_group_id" {
#   type        = string
#   description = "The ID of the resource group in which to create the Dev Center project."
#   //default = "/subscriptions/${var.target_subscription_id}/resourceGroups/xmew1-dop-c-${var.OEM}-d-rg-001"
# }

variable "location" {
  type        = string
  description = "The location/region in which to create the Dev Center project."
  default = "west europe"
}

# variable "devcenter_id" {
#   type        = string
#   description = "The ID of the Dev Center project."
#   //default = "/subscriptions/${var.target_subscription_id}/resourceGroups/xmew1-dop-c-${var.OEM}-d-rg-001/providers/Microsoft.DevCenter/devcenters/xmew1-dop-c-${var.OEM}-d-dc"
# }

variable "project_description" {
  type        = string
  description = "The description of the Dev Center project."
  default = "The description of the Dev Center project."
}

variable "project_members" {
  type        = list(string)
  description = "The members of the Dev Center project."
  default = [ "7cc6c11b-ad9c-43cc-a7d5-2a0a0e4f3648"]  //Alex's objectid
}#"70608667-2dc3-4b2a-a433-30d6ca41e377",08408703-0c5a-47a8-a4d7-d54ceab09f03","70608667-2dc3-4b2a-a433-30d6ca41e377", "e7b48204-dac0-43a3-8f54-ed628b0d62d5", "f572bcfa-fa8e-4624-ae2f-a31177a929aa"
#e7b48204-dac0-43a3-8f54-ed628b0d62d5", "08408703-0c5a-47a8-a4d7-d54ceab09f03"  "f572bcfa-fa8e-4624-ae2f-a31177a929aa", 

# #variable "environment_types" {
#   type = map(object({
#     name                   = string
#     description            = string
#     target_subscription_id = string
#   }))
#   description = "The environment types to create on the Dev Center project."
#     default = {
#     "Test" = {
#      name                   = "Test"
#      description            = "Description for Test environment"
#      target_subscription_id = "db401b47-f622-4eb4-a99b-e0cebc0ebad4"
#     }
#        }
# }


# variable "project_name" {
#   type        = string
#   description = "The name of the Dev Center project."
#   //default = "xmew1-dop-c-${var.OEM}-p-${var.project}-001"
# }



# variable "environment_name" {
#   type        = string
#   description = "The name of the Dev Center project."
#   //default = "Test"
# }

variable "target_subscription_id" {
  type        = string
  description = "The subscription ID of the target subscription."
  default = "db401b47-f622-4eb4-a99b-e0cebc0ebad4"
}