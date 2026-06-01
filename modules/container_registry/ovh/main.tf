
# https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_containerregistry#iam_enabled-1

resource "ovh_cloud_project_containerregistry" "registry" {
  service_name = var.ovh_project_id
  region       = var.container_registry.region
  name         = var.container_registry.name
}

resource "ovh_cloud_project_containerregistry_ip_restrictions_management" "ip_restrictions" {
  # Only deploy if the list contains 1 or more items
  count        = length(var.ip_restrictions) > 0 ? 1 : 0

  service_name = ovh_cloud_project_containerregistry.registry.service_name
  registry_id  = ovh_cloud_project_containerregistry.registry.id

  # We pass the entire list of objects directly into the resource
  ip_restrictions = var.ip_restrictions
}

// IAM can be used instead.  Not both...
resource "ovh_cloud_project_containerregistry_user" "user" {
  for_each = { for user in var.registry_users : user.login => user }

  service_name = ovh_cloud_project_containerregistry.registry.service_name
  registry_id  = ovh_cloud_project_containerregistry.registry.id
  
  login        = each.value.login
  email        = each.value.email
}
