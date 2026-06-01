# Create an OVHcloud Managed Kubernetes cluster
resource "ovh_cloud_project_kube" "kube_cluster" {
  service_name = var.ovh_project_id
  name         = var.kube_cluster.name
  region       = var.ovh_region
  version      = var.kube_cluster.version
}

# Create Node Pools 
resource "ovh_cloud_project_kube_nodepool" "node_pool" {
  for_each     = var.kube_node_pools

  service_name  = var.ovh_project_id
  kube_id       = ovh_cloud_project_kube.kube_cluster.id
  
  # each.key is the name of the pool (fx "frontend" eller "backend")
  name          = each.key
  flavor_name   = each.value.size
  desired_nodes = each.value.nodes_count
  min_nodes     = each.value.nodes_min
  max_nodes     = each.value.nodes_max

  template {
    metadata {
      annotations = {
        managed-by = "terraform"
      }
      finalizers = []
      labels     = each.value.labels
    }
    spec {
      unschedulable = false
      taints        = each.value.taints
    }
  }
}

# Kube-API IP Access restrictions
resource "ovh_cloud_project_kube_iprestrictions" "restrictions" {
  count        = length(var.kube_cluster.ip_restrictions) > 0 ? 1 : 0
  service_name = var.ovh_project_id
  kube_id      = ovh_cloud_project_kube.kube_cluster.id
  ips          = var.kube_cluster.ip_restrictions
}