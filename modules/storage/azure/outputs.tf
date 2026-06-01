output "storage_id" {
  description = "ID of the created storage resource"
  value       = var.deployment_type == "object" ? azurerm_storage_account.storage[0].id : azurerm_managed_disk.disk[0].id
}

output "storage_name" {
  description = "Name of the created storage resource"
  value       = var.deployment_type == "object" ? var.object_storage.name : var.block_storage.name
}

output "storage_region" {
  description = "Region of the created storage resource"
  value       = var.deployment_type == "object" ? var.object_storage.location : var.block_storage.location
}

output "connection_string" {
  description = "Primary connection string for the storage account (null for block storage)"
  value       = var.deployment_type == "object" ? azurerm_storage_account.storage[0].primary_connection_string : null
  sensitive   = true
}
