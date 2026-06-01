output "network_id" {
  value       = var.cloud_provider == "ovh" ? one(module.ovh[*].network_id) : one(module.azure[*].network_id)
  description = "ID of the created network"
}

output "network_name" {
  value       = var.cloud_provider == "ovh" ? one(module.ovh[*].network_name) : one(module.azure[*].network_name)
  description = "Name of the network"
}

output "subnet_ids" {
  value       = var.cloud_provider == "ovh" ? one(module.ovh[*].subnet_ids) : one(module.azure[*].subnet_ids)
  description = "Map of subnet name/region to subnet ID"
}
