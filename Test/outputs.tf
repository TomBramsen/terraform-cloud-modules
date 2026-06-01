
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.network.network_id
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.network.subnet_ids
}

output "registry_url" {
  description = "Login server URL for the container registry"
  value       = module.registry.registry_url
}

output "registry_user_passwords" {
  description = "Map of registry token usernames to generated passwords"
  value       = module.registry.user_passwords
  sensitive   = true
}

output "cluster_id" {
  description = "ID of the AKS cluster"
  value       = module.kubernetes.cluster_id
}


output "kubeconfig" {
  description = "Raw kubeconfig — pipe to a file or use with KUBECONFIG env var"
  value       = module.kubernetes.kubeconfig
  sensitive   = true
}
