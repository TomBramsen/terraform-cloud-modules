# Create an OVHcloud Managed Kubernetes cluster
resource "ovh_cloud_project_kube" "kube_cluster" {
  service_name       = var.cloud_settings.ovh_project_id
  name               = var.cluster_config.name
  region             = var.cloud_settings.ovh_region
  version            = var.cluster_config.version
  private_network_id = var.cloud_settings.private_network_id
}

# Create Managed Node Pool
resource "ovh_cloud_project_kube_nodepool" "node_pool" {
  service_name  = var.cloud_settings.ovh_project_id
  kube_id       = ovh_cloud_project_kube.kube_cluster.id
  
  name          = "defaultpool"
  flavor_name   = var.node_config.sku
  desired_nodes = var.node_config.node_count
  
  # Autoscale configuration mapping
  autoscale     = var.node_config.autoscale_enabled
  min_nodes     = var.node_config.autoscale_enabled ? var.node_config.min_count : var.node_config.node_count
  max_nodes     = var.node_config.autoscale_enabled ? var.node_config.max_count : var.node_config.node_count
  
  # Availability zones mapping
  availability_zones = length(var.node_config.availability_zones) > 0 ? var.node_config.availability_zones : null

  template {
    metadata {
      # Restored metadata tracking and deletion handling blocks
      annotations = {
        "managed-by" = "terraform"
      }
      finalizers = []
      
      labels = merge({ "environment" = var.cluster_config.environment }, var.node_config.labels)
    }
    
    spec {
      unschedulable = false
      taints        = var.node_config.taints
    }
  }
}

# Kube-API IP Access restrictions
resource "ovh_cloud_project_kube_iprestrictions" "restrictions" {
  count        = length(var.cloud_settings.ip_restrictions) > 0 ? 1 : 0
  service_name = var.cloud_settings.ovh_project_id
  kube_id      = ovh_cloud_project_kube.kube_cluster.id
  ips          = var.cloud_settings.ip_restrictions
}