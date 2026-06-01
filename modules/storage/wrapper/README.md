# Storage — Wrapper

Provisions object or block storage on either **OVHcloud** or **Azure** using a shared entry point.

Because storage APIs differ between clouds, the cloud-specific configs are in separate variables rather than a single shared config block.

## Usage

### OVHcloud — object storage

```hcl
module "storage" {
  source         = "./modules/storage/wrapper"
  cloud_provider = "ovh"
  deployment_type = "object"

  ovh_config = { project_id = var.ovh_project_id }

  ovh_object_storage = {
    name   = "my-bucket"
    region = "GRA"
  }
}
```

### OVHcloud — block storage

```hcl
module "storage" {
  source          = "./modules/storage/wrapper"
  cloud_provider  = "ovh"
  deployment_type = "block"

  ovh_config = { project_id = var.ovh_project_id }

  ovh_block_storage = {
    name        = "my-volume"
    region      = "GRA"
    size        = 50
    volume_type = "high-speed"
  }
}
```

### Azure — object storage

```hcl
module "storage" {
  source          = "./modules/storage/wrapper"
  cloud_provider  = "azure"
  deployment_type = "object"

  azure_object_storage = {
    name           = "mycompanydatastore"   # globally unique
    resource_group = "my-rg"
    location       = "westeurope"
  }
}

output "connection_string" { value = module.storage.connection_string; sensitive = true }
```

### Azure — block storage

```hcl
module "storage" {
  source          = "./modules/storage/wrapper"
  cloud_provider  = "azure"
  deployment_type = "block"

  azure_block_storage = {
    name                 = "my-data-disk"
    resource_group       = "my-rg"
    location             = "westeurope"
    size                 = 128
    storage_account_type = "Premium_LRS"
  }
}
```

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `cloud_provider` | `string` | yes | `"ovh"` or `"azure"` |
| `deployment_type` | `string` | yes | `"object"` or `"block"` |
| `ovh_config` | `object` | if OVH | `{ project_id }` |
| `ovh_object_storage` | `object` | if OVH + object | OVH bucket config |
| `ovh_block_storage` | `object` | if OVH + block | OVH volume config |
| `azure_object_storage` | `object` | if Azure + object | Azure storage account config |
| `azure_block_storage` | `object` | if Azure + block | Azure managed disk config |

## Outputs

| Name | Description |
|------|-------------|
| `storage_id` | ID of the created storage resource |
| `storage_name` | Name of the storage resource |
| `storage_region` | Region of the storage resource |
| `connection_string` | Azure primary connection string *(sensitive)* — `null` for OVH |
