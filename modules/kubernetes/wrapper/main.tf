# --- CALL YOUR AZURE MODULE ---
module "azure_k8s_cluster" {
  source = "../azure"
  count  = var.cloud_settings.cloud_provider == "azure" ? 1 : 0

  cluster_config = {
    name        = var.cluster_config.cluster_name
    environment = var.cluster_config.environment
    version     = var.cluster_config.k8s_version
    tags        = var.cluster_config.tags
  }

  node_config = {
    sku                = local.resolved_node_sku # BEHOLD DENNE! Azure SKAL have hardware-størrelsen her
    node_count         = var.node_config.node_count
    autoscale_enabled  = var.node_config.autoscale_enabled
    min_count          = var.node_config.min_count
    max_count          = var.node_config.max_count
    availability_zones = var.node_config.availability_zones
    labels             = var.node_config.labels
    taints             = var.node_config.taints
  }

  cloud_settings = {
    resource_group  = var.cloud_settings.project_identifier
    location        = var.cloud_settings.region
    dns_prefix      = coalesce(var.cloud_settings.azure_dns_prefix, var.cluster_config.cluster_name)
    vnet_subnet_id  = var.cloud_settings.network_id
    ip_restrictions = var.cloud_settings.ip_restrictions
  }
}

# --- CALL YOUR OVH MODULE ---
module "ovh_k8s_cluster" {
  source = "../ovh"
  count  = var.cloud_settings.cloud_provider == "ovh" ? 1 : 0

  cluster_config = {
    name        = var.cluster_config.cluster_name
    environment = var.cluster_config.environment
    version     = var.cluster_config.k8s_version
    tags        = var.cluster_config.tags
  }

  node_config = {
    sku               = local.resolved_node_sku # OVH skal også bruge sin hardware flavor
    node_count        = var.node_config.node_count
    autoscale_enabled = var.node_config.autoscale_enabled
    min_count         = var.node_config.min_count
    max_count         = var.node_config.max_count
    availability_zones = var.node_config.availability_zones
    labels            = var.node_config.labels
    taints            = var.node_config.taints
    # NOTE: Ingen 'os_sku' eller 'node_image' her, da OVH ikke understøtter det.
  }

  cloud_settings = {
    ovh_project_id     = var.cloud_settings.project_identifier
    ovh_region         = var.cloud_settings.region
    private_network_id = var.cloud_settings.network_id
    ip_restrictions    = var.cloud_settings.ip_restrictions
  }
}
