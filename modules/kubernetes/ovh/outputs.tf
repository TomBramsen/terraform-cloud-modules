output "cluster_id" {
  value       = ovh_cloud_project_kube.kube_cluster.id
  description = "ID of the created OVHcloud Kubernetes cluster"
}

output "cluster_name" {
  value       = ovh_cloud_project_kube.kube_cluster.name
  description = "The name of the Kubernetes cluster"
}

output "node_pool_ids" {
  # This creates a clean map: { "default-pool" = "id-123", "storage-pool" = "id-456" }
  value       = { for k, v in ovh_cloud_project_kube_nodepool.node_pool : k => v.id }
  description = "A map of the created node pools and their respective IDs"
}

output "kubeconfig" {
  description = "Den rå kubeconfig streng fra OVH, brugt til at logge på clusteret"
  value       = ovh_cloud_project_kube.kube_cluster.kubeconfig
  sensitive   = true # Skjuler koden i dine GitHub logfiler
}