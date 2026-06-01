locals {
  default_pool_key = var.kube_cluster.default_node_pool_name
  default_pool     = var.kube_node_pools[local.default_pool_key]
  extra_pools      = { for k, v in var.kube_node_pools : k => v if k != local.default_pool_key }
  dns_prefix       = coalesce(var.kube_cluster.dns_prefix, var.kube_cluster.name)
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.kube_cluster.name
  location            = var.kube_cluster.location
  resource_group_name = var.kube_cluster.resource_group
  dns_prefix          = local.dns_prefix
  kubernetes_version  = var.kube_cluster.version

  default_node_pool {
    name                 = local.default_pool_key
    vm_size              = local.default_pool.size
    node_count           = local.default_pool.nodes_count
    min_count            = local.default_pool.nodes_min
    max_count            = local.default_pool.nodes_max
    auto_scaling_enabled = true
    node_labels          = local.default_pool.labels
    vnet_subnet_id       = var.kube_cluster.vnet_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "api_server_access_profile" {
    for_each = length(var.kube_cluster.ip_restrictions) > 0 ? [1] : []
    content {
      authorized_ip_ranges = var.kube_cluster.ip_restrictions
    }
  }

  tags = {
    managed-by = "terraform"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  for_each = local.extra_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.size
  node_count            = each.value.nodes_count
  min_count             = each.value.nodes_min
  max_count             = each.value.nodes_max
  auto_scaling_enabled  = true
  node_labels           = each.value.labels
  vnet_subnet_id        = var.kube_cluster.vnet_subnet_id
  # AKS taints format: "key=value:Effect"
  node_taints = [for t in each.value.taints : "${t.key}=${t.value}:${t.effect}"]

  tags = {
    managed-by = "terraform"
  }
}