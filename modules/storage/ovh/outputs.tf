output "storage_id" {
  description = "ID of the created storage resource"
  value       = var.deployment_type == "object" ? ovh_cloud_project_storage.storage[0].id : openstack_blockstorage_volume_v3.data[0].id
}

output "storage_name" {
  description = "Name of the created storage resource"
  value       = var.deployment_type == "object" ? var.object_storage.name : var.block_storage.name
}

output "storage_region" {
  description = "Region of the created storage resource"
  value       = var.deployment_type == "object" ? var.object_storage.region : var.block_storage.region
}

output "connection_string" {
  description = "Connection string for the storage (null for OVH - use S3 endpoint instead)"
  value       = null
  sensitive   = true
}


