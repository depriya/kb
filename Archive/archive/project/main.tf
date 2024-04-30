##############################
# DevCenter project
# ##############################
# resource "azapi_resource" "project" {
#   type      = "Microsoft.DevCenter/projects@2023-04-01"
#   name      = "xmew1-dop-c-${var.OEM}-p-${var.project}-001"
#   location  = var.location
#   parent_id = "/subscriptions/${var.target_subscription_id}/resourceGroups/xmew1-dop-c-${var.OEM}-d-rg-001"
#   body = jsonencode({
#     properties = {
#       description = "${var.project_description}"
#       devCenterId = "/subscriptions/${var.target_subscription_id}/resourceGroups/xmew1-dop-c-${var.OEM}-d-rg-001/providers/Microsoft.DevCenter/devcenters/xmew1-dop-c-${var.OEM}-d-dc"
#     }
#   })
# }


#  #data "azapi_resource" "project" {
#    type      = "Microsoft.DevCenter/projects@2023-04-01"
#   name      = "xmew1-dop-c-${var.OEM}-p-${var.project}-001"
#  parent_id = "/subscriptions/${var.target_subscription_id}/resourceGroups/xmew1-dop-c-${var.OEM}-d-rg-001"

#  }

data "azapi_resource" "keyvault" {
  type = "Microsoft.KeyVault/vaults@2022-07-01"
  name      = "xmew1-dop-s-d-kv-001"
 parent_id = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-s-stamp-d-rg-001"

 }


##############################
# Environment type definition
# ##############################
# resource "azapi_resource" "environment_type_definition" {
#   type      = "Microsoft.DevCenter/projects/environmentTypes@2023-04-01"
#   name      = "sandbox"
#   location  = var.location
#   parent_id = data.azapi_resource.project.id
#   identity {
#     type = "SystemAssigned"
#     # identity_ids = [] # only used when type contains UserAssigned to reference the user assigned identity
#     identity_ids = []
#   }
#   body = jsonencode({
#     properties = {
#        creatorRoleAssignment = {
        
#           #roles = {
#            #   "Owner" = {}
                
#         #}
#        }
#       deploymentTargetId = "/subscriptions/${var.target_subscription_id}"
#       status             = "Enabled"
#       # userRoleAssignments = {}
#     }
#   })
# }

# Wait for environment type dev definition to be created and managed identity replicated to AAD
# # Doing this inmediately after would fail with a "identity not found" error
# resource "time_sleep" "wait_30_seconds" {
#   depends_on = [azapi_resource.environment_type_definition]

#   create_duration = "30s"
# }

# # Lookup principal_id for the project system assigned identity
# data "azuread_service_principal" "environment_type_smi" {
#   display_name = "${var.project_name}/environmentTypes/${var.environment_name}"

#   depends_on = [time_sleep.wait_30_seconds]
# }

##############################
# Create RBAC Assignment: grant project system assigned identity Owner access to target subscription
#   - Identity: dev center project smi
#   - Role: Owner
#   - Scope: Subscription
##############################
# #resource "azurerm_role_assignment" "project_owner_sub" {
#   scope                = "/subscriptions/${var.target_subscription_id}"
#   role_definition_name = "Owner"
#   principal_id         = data.azuread_service_principal.environment_type_smi.object_id
# }

##############################
# Allow Environment Type
# ##############################
# data "azapi_resource" "allowed_env_types" {
#   type      = "Microsoft.DevCenter/projects/allowedEnvironmentTypes@2023-04-01"
#   name      = "sandbox"
#   parent_id = data.azapi_resource.project.id

#   depends_on = [azapi_resource.environment_type_definition]
# }

##############################
# Create RBAC Assignment: grant project memebers access to the DevCenter project
#   - Identity: each project member define in root main.tf
#   - Role: Deployment Environments User
#   - Scope: Project
# ##############################
resource "azurerm_role_assignment" "devcenter_project_admin" {
   for_each = toset(var.project_members)

  scope                = data.azapi_resource.keyvault.id
#scope = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4"
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = each.key
 }

# #resource "azurerm_role_assignment" "devcenter_environment_user" {
#   for_each = toset(var.project_members)
#   #scope = "/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4"
#   scope                = data.azapi_resource.project.id
#   role_definition_name = "Deployment Environments User"
#   principal_id         = each.key
# }