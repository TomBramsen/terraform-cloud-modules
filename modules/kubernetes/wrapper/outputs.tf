output "cluster_id" {
  value       = var.cloud_provider == "ovh" ? one(module.ovh[*].cluster_id) : one(module.azure[*].cluster_id)
  description = "ID of the created Kubernetes cluster"
}

output "cluster_name" {
  value       = var.cloud_provider == "ovh" ? one(module.ovh[*].cluster_name) : one(module.azure[*].cluster_name)
  description = "Name of the Kubernetes cluster"
}

output "node_pool_ids" {
  value       = var.cloud_provider == "ovh" ? one(module.ovh[*].node_pool_ids) : one(module.azure[*].node_pool_ids)
  description = "Map of node pool names to their respective IDs"
}

output "kubeconfig" {
  value       = var.cloud_provider == "ovh" ? one(module.ovh[*].kubeconfig) : one(module.azure[*].kubeconfig)
  sensitive   = true
  description = "Raw kubeconfig string to authenticate against the cluster"
}

output "cluster_identity_id" {
  value       = var.cloud_provider == "azure" ? one(module.azure[*].cluster_identity_id) : null
  description = "Principal ID of the cluster's managed identity (Azure only, null for OVH)"
}
