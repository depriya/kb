
resource_group_id   = "/subscriptions/${var.target_subscription_id}/resourceGroups/xmew1-dop-c-${var.OEM}-d-rg-001"
location            = "west europe"
devcenter_id        = "/subscriptions/${var.target_subscription_id}/resourceGroups/xmew1-dop-c-${var.OEM}-d-rg-001/providers/Microsoft.DevCenter/devcenters/xmew1-dop-c-${var.OEM}-d-dc"
project_description = "The description of the Dev Center project."
project_members     = ["b9082dac-d369-4435-a4b9-9779f666c1e0"] //Alex's objectid
environment_types = {
  Test = {
    name                   = "Test"
    description            = "Environment for development purposes"
    target_subscription_id = "db401b47-f622-4eb4-a99b-e0cebc0ebad4"
  }
}
project_name           = "xmew1-dop-c-${var.OEM}-p-${var.project}-001"
environment_name       = "Test"
target_subscription_id = "db401b47-f622-4eb4-a99b-e0cebc0ebad4"
