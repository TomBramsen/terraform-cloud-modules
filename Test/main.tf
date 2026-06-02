
# =============================================================================
# Network — cloud-agnostisk, styret af cloud_settings.cloud_provider
# =============================================================================
module "network" {
  source         = "../modules/network/wrapper"
  cloud_provider = var.cloud_settings.cloud_provider
  network_name   = "${var.prefix}-network"
  project_id     = var.cloud_settings.cloud_provider == "ovh" ? var.cloud_settings.ovh.project_id : ""

  azure_config = var.cloud_settings.cloud_provider == "azure" ? {
    location       = var.cloud_settings.region
    resource_group = var.cloud_settings.azure.resource_group
    address_space  = try(var.network_config.azure.address_space, [])
    subnets        = try(var.network_config.azure.subnets, {})
  } : null

  ovh_config = var.cloud_settings.cloud_provider == "ovh" ? var.network_config.ovh : null
}


# =============================================================================
# Container Registry
# =============================================================================
module "registry" {
  source         = "../modules/container_registry/wrapper"
  cloud_provider = var.cloud_settings.cloud_provider

  container_registry = {
    deploy = var.registry_config.deploy
    name   = var.registry_config.name
  }

  azure_config = var.cloud_settings.cloud_provider == "azure" ? {
    location       = var.cloud_settings.region
    resource_group = var.cloud_settings.azure.resource_group
    sku            = try(var.registry_config.azure.sku, "Standard")
  } : null

  ovh_config = var.cloud_settings.cloud_provider == "ovh" ? {
    project_id = var.cloud_settings.ovh.project_id
    region     = var.registry_config.ovh.region
  } : null

  registry_users  = [
    { login = "ci-user", email = var.registry_user_email }
  ]
  ip_restrictions = [
    for ip in var.cloud_settings.ip_restrictions : {
      ip_block    = ip
      description = "Allowed IP"
    }
  ]
}




# =============================================================================
# Kubernetes Cluster
# =============================================================================
module "kubernetes" {
  source = "../modules/kubernetes/wrapper"

  cluster_config = {
    cluster_name = var.cluster_config.cluster_name
    environment  = var.cluster_config.environment
    version      = var.kubernetes_version
    tags         = merge(var.tags, var.cluster_config.tags)
  }

  node_config = {
    node_size          = local.resolved_node_sku
    node_count         = var.node_config.node_count
    autoscale_enabled  = var.node_config.autoscale_enabled
    min_count          = var.node_config.min_count
    max_count          = var.node_config.max_count
    availability_zones = var.node_config.availability_zones
    labels             = var.node_config.labels
    taints             = var.node_config.taints
  }

  cloud_settings = {
    cloud_provider     = var.cloud_settings.cloud_provider
    region             = var.cloud_settings.region
    project_identifier = var.cloud_settings.cloud_provider == "azure" ? var.cloud_settings.azure.resource_group : var.cloud_settings.ovh.project_id
    network_id         = var.cloud_settings.cloud_provider == "azure" ? module.network.subnet_ids["aks"] : var.cloud_settings.network_id
    dns_prefix         = coalesce(try(var.cloud_settings.azure.dns_prefix, null), var.cluster_config.cluster_name)
    ip_restrictions    = var.cloud_settings.ip_restrictions
  }
}

# =============================================================================
# GitOps / Flux Bootstrap
# =============================================================================
module "flux_bootstrap" {
  source = "../modules/kubernetes/bootstrap/gitops"

  kubeconfig     = module.kubernetes.kubeconfig

  cluster_repo   = "git.netic.dk/scm/pd/gotk-bootstrap-k8s.git"
  bootstrap_path = "gotk"

  git_auth = {
    netic = {
      username = var.netic_git_username
      password = var.netic_git_token
    }
    "kubernetes-config" = {
      identity = var.gitops_ssh_key
    }
  }
}

# =============================================================================
# Role Assignments (kun Azure)
# =============================================================================
resource "azurerm_role_assignment" "aks_network" {
  count                = var.cloud_settings.cloud_provider == "azure" ? 1 : 0
  scope                = module.network.subnet_ids["aks"]
  role_definition_name = "Network Contributor"
  principal_id         = module.kubernetes.cluster_identity_id
}

