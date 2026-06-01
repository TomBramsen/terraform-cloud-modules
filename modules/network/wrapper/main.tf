module "ovh" {
  count  = var.cloud_provider == "ovh" ? 1 : 0
  source = "../ovh"

  ovh_project_id = try(var.ovh_config.project_id, "")
  network_name   = var.network_name
  vlan_id        = try(var.ovh_config.vlan_id, 0)
  no_gateway     = try(var.ovh_config.no_gateway, false)
  regions        = try(var.ovh_config.regions, [])
}

module "azure" {
  count  = var.cloud_provider == "azure" ? 1 : 0
  source = "../azure"

  network_name   = var.network_name
  location       = try(var.azure_config.location, "")
  resource_group = try(var.azure_config.resource_group, "")
  address_space  = try(var.azure_config.address_space, [])
  subnets        = try(var.azure_config.subnets, {})
}
