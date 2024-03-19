variable "rgName" {
  description = "Resource Group Name"
  type        = string
}

variable "devcenter" {
  description = "Dev Center Name"
  type        = string
}

variable "projectname" {
  description = "Project Name"
  type        = string
}

variable "location" {
  description = "location"
  type        = string
  default     = "West Europe"
}