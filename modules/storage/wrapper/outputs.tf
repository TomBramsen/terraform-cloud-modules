output "storage_id" {
  description = "ID of the created storage resource"
  value       = var.cloud_provider == "ovh" ? one(module.ovh[*].storage_id) : one(module.azure[*].storage_id)
}

output "storage_name" {
  description = "Name of the storage resource"
  value       = var.cloud_provider == "ovh" ? one(module.ovh[*].storage_name) : one(module.azure[*].storage_name)
}

output "storage_region" {
  description = "Region of the storage resource"
  value       = var.cloud_provider == "ovh" ? one(module.ovh[*].storage_region) : one(module.azure[*].storage_region)
}

output "connection_string" {
  description = "Azure storage account connection string (null for OVH)"
  value       = var.cloud_provider == "azure" ? one(module.azure[*].connection_string) : null
  sensitive   = true
}
