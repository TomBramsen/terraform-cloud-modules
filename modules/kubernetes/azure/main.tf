# Create Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_config.name
  location            = var.cloud_settings.location
  resource_group_name = var.cloud_settings.resource_group
  dns_prefix          = var.cloud_settings.dns_prefix
  kubernetes_version  = var.cluster_config.version

default_node_pool {
    name                 = "defaultpool"
    vm_size              = var.node_config.sku
    node_count           = var.node_config.node_count
    vnet_subnet_id       = var.cloud_settings.vnet_subnet_id
    node_labels          = merge(var.cluster_config.tags, var.node_config.labels)
    
    # Mapping the shared autoscale and zones properties to Azure parameters
    auto_scaling_enabled = var.node_config.autoscale_enabled
    min_count            = var.node_config.autoscale_enabled ? var.node_config.min_count : null
    max_count            = var.node_config.autoscale_enabled ? var.node_config.max_count : null
    zones                = length(var.node_config.availability_zones) > 0 ? var.node_config.availability_zones : null
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"             # Standard CNI for custom subnets
    service_cidr   = "172.16.0.0/16"     # Completely isolated range for internal ClusterIPs
    dns_service_ip = "172.16.0.10"       # Must be an IP inside the service_cidr range (.10 is standard)
  }
  
  # Kube-API IP Access restrictions
  dynamic "api_server_access_profile" {
    for_each = length(var.cloud_settings.ip_restrictions) > 0 ? [1] : []
    content {
      authorized_ip_ranges = var.cloud_settings.ip_restrictions
    }
  }

  tags = merge({ managed-by = "terraform" }, var.cluster_config.tags)
}
