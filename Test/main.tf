# =============================================================================
# Resource Group
# =============================================================================

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location

  tags = {
    managed-by  = "terraform"
    environment = var.prefix
  }
}

# =============================================================================
# Network — VNet with two subnets:
#   aks     10.0.0.0/22  (1024 IPs for AKS nodes + pods)
#   default 10.0.8.0/24  (for other resources)
# =============================================================================

module "network" {
  source         = "../modules/network/wrapper"
  cloud_provider = "azure"
  network_name   = "${var.prefix}-vnet"

  azure_config = {
    location       = azurerm_resource_group.rg.location
    resource_group = azurerm_resource_group.rg.name
    address_space  = ["10.0.0.0/16"]
    subnets = {
      aks     = { cidr = "10.0.0.0/22" }
      default = { cidr = "10.0.8.0/24" }
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
    location       = azurerm_resource_group.rg.location
    resource_group = azurerm_resource_group.rg.name
    sku            = "Standard"
  }

  registry_users = [
    { login = "ci-user", email = var.registry_user_email }
  ]
}

# =============================================================================
# Kubernetes — AKS with two node pools in the aks subnet:
#   system   Standard_D2s_v3  (1–5 nodes)   system workloads
#   workers  Standard_D4s_v3  (0–10 nodes)  application workloads
# =============================================================================

module "kubernetes" {
  source         = "../modules/kubernetes/wrapper"
  cloud_provider = "azure"

  kube_cluster = {
    name    = "${var.prefix}-aks"
    version = var.kubernetes_version
  }

  azure_config = {
    location               = azurerm_resource_group.rg.location
    resource_group         = azurerm_resource_group.rg.name
    default_node_pool_name = "system"
    vnet_subnet_id         = module.network.subnet_ids["aks"]
  }

  kube_node_pools = {
    system = {
      size        = "Standard_D2s_v3"
      nodes_count = 2
      nodes_min   = 1
      nodes_max   = 5
    }
    workers = {
      size        = "Standard_D4s_v3"
      nodes_count = 1
      nodes_min   = 0
      nodes_max   = 10
      labels      = { role = "workers" }
    }
  }
}

# Grant AKS's managed identity Network Contributor on the AKS subnet
# so it can manage load balancers and route tables.
resource "azurerm_role_assignment" "aks_network" {
  scope                = module.network.subnet_ids["aks"]
  role_definition_name = "Network Contributor"
  principal_id         = module.kubernetes.cluster_identity_id
}
