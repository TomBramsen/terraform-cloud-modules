# -----------------------------------------------------------------------------
# Object Storage (Azure Storage Account + Blob Container)
# Storage account names must be globally unique, 3-24 chars, lowercase alphanumeric only.
# -----------------------------------------------------------------------------

resource "azurerm_storage_account" "storage" {
  count = var.deployment_type == "object" ? 1 : 0

  name                     = var.object_storage.name
  resource_group_name      = var.object_storage.resource_group
  location                 = var.object_storage.location
  account_tier             = "Standard"
  account_replication_type = var.object_storage.replication_type
  account_kind             = "StorageV2"

  blob_properties {
    versioning_enabled = var.object_storage.versioning

    dynamic "delete_retention_policy" {
      for_each = var.object_storage.retention_days > 0 ? [1] : []
      content {
        days = var.object_storage.retention_days
      }
    }
  }

  tags = {
    managed-by = "terraform"
  }
}

resource "azurerm_storage_container" "container" {
  count                 = var.deployment_type == "object" ? 1 : 0
  name                  = var.object_storage.container_name
  storage_account_id    = azurerm_storage_account.storage[0].id
  container_access_type = "private"
}

# -----------------------------------------------------------------------------
# Block Storage (Azure Managed Disk)
# -----------------------------------------------------------------------------

resource "azurerm_managed_disk" "disk" {
  count = var.deployment_type == "block" ? 1 : 0

  name                 = var.block_storage.name
  location             = var.block_storage.location
  resource_group_name  = var.block_storage.resource_group
  storage_account_type = var.block_storage.storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.block_storage.size

  tags = {
    managed-by  = "terraform"
    description = var.block_storage.description
  }
}
