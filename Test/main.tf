
# =============================================================================
# Network — VNet with two subnets:
# =============================================================================

module "network" {
  source         = "../modules/network/wrapper"
  cloud_provider = "azure"
  network_name   = "${var.prefix}-vnet"

  azure_config = {
    location       = var.location
    resource_group = var.resource_group_name
    address_space  = ["10.0.12.0/22"]
    subnets = {
      aks     = { cidr = "10.0.12.0/24" }
      default = { cidr = "10.0.13.0/24" }
    }
  }
}

# =============================================================================
# Container Registry — Azure ACR (Standard)
# =============================================================================

module "registry" {
  source         = "../modules/container_registry/wrapper"
  cloud_provider = "azure"

  container_registry = {
    deploy = true
    name   = var.registry_name
  }

  azure_config = {
    location       = var.location
    resource_group = var.resource_group_name
    sku            = "Standard"
  }

  registry_users = [
    { login = "ci-user", email = var.registry_user_email }
  ]
}

# =============================================================================
# Kubernetes 
# =============================================================================
# =============================================================================
# Kubernetes Cluster Integration Layer
# =============================================================================
module "kubernetes" {
  source = "../modules/kubernetes/wrapper"

  cluster_config = {
    cluster_name = var.cluster_config.cluster_name
    environment  = var.cluster_config.environment
    version      = var.kubernetes_version
    tags         = var.cluster_config.tags
  }

  node_config = {
    node_size         = local.resolved_node_sku
    node_count        = var.node_config.node_count
    autoscale_enabled = var.node_config.autoscale_enabled

    min_count = var.node_config.min_count
    max_count = var.node_config.max_count

    availability_zones = var.node_config.availability_zones
    labels             = var.node_config.labels
    taints             = var.node_config.taints
  }

  cloud_settings = {
    cloud_provider     = var.cloud_settings.cloud_provider
    region             = var.cloud_settings.region
    project_identifier = var.cloud_settings.project_identifier
    # Dynamically provide the subnet ID if Azure is running
    network_id      = var.cloud_settings.cloud_provider == "azure" ? module.network.subnet_ids["aks"] : var.cloud_settings.network_id
    dns_prefix      = coalesce(var.cloud_settings.azure_dns_prefix, var.cluster_config.cluster_name)
    ip_restrictions = var.cloud_settings.ip_restrictions
  }

  flux_config = local.flux_config
}

# =============================================================================
# GitOps / Flux Bootstrap
# =============================================================================
# flux_config er optional i wrapperen — fjern hele blokken hvis du ikke vil bootstrappe.
# Credentials trækkes fra miljøvariabler:
#   export TF_VAR_netic_git_username="..."
#   export TF_VAR_netic_git_token="..."
#   export TF_VAR_gitops_ssh_key="$(cat ~/.ssh/id_ed25519_gitops)"
# =============================================================================

locals {
  flux_config = {
    cluster_repo   = "git@github.com:your-org/kubernetes-config.git" # <-- din cluster config repo (ikke gotk-repoet)
    bootstrap_path = "clusters/${var.cluster_config.environment}"

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
}

# =============================================================================
# Role Assignments (Executed ONLY if provider is Azure)
# =============================================================================
# Grant AKS's managed identity Network Contributor on the AKS subnet
# so it can manage load balancers and route tables safely.
resource "azurerm_role_assignment" "aks_network" {
  count                = var.cloud_settings.cloud_provider == "azure" ? 1 : 0
  scope                = module.network.subnet_ids["aks"]
  role_definition_name = "Network Contributor"
  principal_id         = module.kubernetes.cluster_identity_id
}
