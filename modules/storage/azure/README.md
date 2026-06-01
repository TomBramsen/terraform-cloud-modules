# Storage — Azure

Provisions either an Azure **Storage Account** (Blob/object storage) or an Azure **Managed Disk** (block storage).

## Resources created

| `deployment_type` | Resource | Description |
|-------------------|----------|-------------|
| `object` | `azurerm_storage_account` | General-purpose v2 storage account |
| `object` | `azurerm_storage_container` | Private blob container within the account |
| `block` | `azurerm_managed_disk` | Empty managed disk (ready to attach to a VM) |

## Usage

### Object storage

```hcl
module "storage" {
  source = "./modules/storage/azure"

  deployment_type = "object"

  object_storage = {
    name             = "mycompanydata"    # globally unique, 3-24 chars, lowercase alphanumeric
    resource_group   = "my-rg"
    location         = "westeurope"
    replication_type = "LRS"
    versioning       = true
    retention_days   = 30
    container_name   = "backups"
  }
}

output "connection_string" { value = module.storage.connection_string; sensitive = true }
```

### Block storage

```hcl
module "storage" {
  source = "./modules/storage/azure"

  deployment_type = "block"

  block_storage = {
    name                 = "my-data-disk"
    resource_group       = "my-rg"
    location             = "westeurope"
    size                 = 128
    storage_account_type = "Premium_LRS"
  }
}
```

## Inputs

### `object_storage`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | — | Storage account name — globally unique, 3-24 lowercase alphanumeric |
| `resource_group` | `string` | — | Existing resource group |
| `location` | `string` | — | Azure region |
| `replication_type` | `string` | `"LRS"` | `"LRS"`, `"GRS"`, `"ZRS"`, `"GZRS"` |
| `versioning` | `bool` | `true` | Enable blob versioning |
| `retention_days` | `number` | `0` | Soft-delete retention days — `0` disables |
| `container_name` | `string` | `"data"` | Name of the blob container to create |

### `block_storage`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | — | Managed disk name |
| `resource_group` | `string` | — | Existing resource group |
| `location` | `string` | — | Azure region |
| `size` | `number` | `10` | Disk size in GB |
| `storage_account_type` | `string` | `"Standard_LRS"` | `"Standard_LRS"`, `"Premium_LRS"`, `"UltraSSD_LRS"` |
| `description` | `string` | `"Storage"` | Added as a tag on the disk |

## Outputs

| Name | Description |
|------|-------------|
| `storage_id` | ID of the created resource |
| `storage_name` | Name of the storage resource |
| `storage_region` | Region of the storage resource |
| `connection_string` | Primary connection string *(sensitive)* — null for block storage |

## Notes

- **Storage account names** must be globally unique across all of Azure. Use a prefix that includes your organisation name.
- **Blob access is private** by default — use SAS tokens, account keys (via `connection_string`), or Azure AD for access.
- **Managed disks** are created empty. Attach to a VM via `azurerm_virtual_machine_data_disk_attachment` after creation.
