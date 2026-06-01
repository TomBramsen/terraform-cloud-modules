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
# =============================================================================

module "network" {
  source         = "../modules/network/wrapper"
  cloud_provider = "azure"
  network_name   = "${var.prefix}-vnet"

  azure_config = {
    location       = azurerm_resource_group.rg.location
    resource_group = azurerm_resource_group.rg.name
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
    location       = azurerm_resource_group.rg.location
    resource_group = azurerm_resource_group.rg.name
    sku            = "Standard"
  }

  registry_users = [
    { login = "ci-user", email = var.registry_user_email }
  ]
}

# =============================================================================
# Kubernetes 
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
      size        = "Standard_B2ms"
      nodes_count = 1
      nodes_min   = 1
      nodes_max   = 3
    }
    workers = {
      size        = "Standard_B2ms"
      nodes_count = 1
      nodes_min   = 0
      nodes_max   = 3
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