# Terraform evaluates module arguments even when count = 0, so cloud-specific
# configs use try() to avoid null-access errors when that provider is not selected.

module "ovh" {
  count  = var.cloud_provider == "ovh" ? 1 : 0
  source = "../ovh"

  ovh_project_id  = try(var.ovh_config.project_id, "")
  ovh_region      = try(var.ovh_config.region, "")
  kube_cluster    = var.kube_cluster
  kube_node_pools = var.kube_node_pools
}

module "azure" {
  count  = var.cloud_provider == "azure" ? 1 : 0
  source = "../azure"

  kube_cluster = {
    name                   = var.kube_cluster.name
    version                = var.kube_cluster.version
    location               = try(var.azure_config.location, "")
    resource_group         = try(var.azure_config.resource_group, "")
    dns_prefix             = try(var.azure_config.dns_prefix, null)
    default_node_pool_name = try(var.azure_config.default_node_pool_name, "system")
    vnet_subnet_id         = try(var.azure_config.vnet_subnet_id, null)
    ip_restrictions        = var.kube_cluster.ip_restrictions
  }

  kube_node_pools = var.kube_node_pools
}
