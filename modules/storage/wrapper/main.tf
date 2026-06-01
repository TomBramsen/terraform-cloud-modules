module "ovh" {
  count  = var.cloud_provider == "ovh" ? 1 : 0
  source = "../ovh"

  ovh_project_id  = try(var.ovh_config.project_id, "")
  deployment_type = var.deployment_type

  object_storage = try(var.ovh_object_storage, { name = "", region = "" })
  block_storage  = try(var.ovh_block_storage, { name = "", region = "" })
}

module "azure" {
  count  = var.cloud_provider == "azure" ? 1 : 0
  source = "../azure"

  deployment_type = var.deployment_type

  object_storage = try(var.azure_object_storage, { name = "", resource_group = "", location = "" })
  block_storage  = try(var.azure_block_storage, { name = "", resource_group = "", location = "" })
}
