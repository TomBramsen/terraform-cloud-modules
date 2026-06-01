output "cluster_id" {
  value       = azurerm_kubernetes_cluster.aks.id
  description = "ID of the created AKS cluster"
}

output "cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "The name of the AKS cluster"
}

output "node_pool_ids" {
  value = merge(
    { (local.default_pool_key) = azurerm_kubernetes_cluster.aks.id },
    { for k, v in azurerm_kubernetes_cluster_node_pool.node_pool : k => v.id }
  )
  description = "A map of node pool names to their respective IDs"
}

output "kubeconfig" {
  description = "Raw kubeconfig string, used to authenticate against the cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "cluster_identity_id" {
  description = "Principal ID of the cluster's SystemAssigned managed identity — use for role assignments"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
