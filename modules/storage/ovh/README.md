# Storage — OVHcloud

Provisions either an S3-compatible **object storage** bucket or a block storage **volume** on OVHcloud. The type is selected via `deployment_type`.

## Resources created

| `deployment_type` | Resource | Description |
|-------------------|----------|-------------|
| `object` | `ovh_cloud_project_storage` | S3-compatible bucket with versioning and optional object lock |
| `block` | `openstack_blockstorage_volume_v3` | Persistent block volume (suitable as a Kubernetes PV) |

## Usage

### Object storage

```hcl
module "storage" {
  source = "./modules/storage/ovh"

  ovh_project_id  = var.ovh_project_id
  deployment_type = "object"

  object_storage = {
    name             = "my-bucket"
    region           = "GRA"
    versioning       = "enabled"
    encryption_sse   = "AES256"
    object_lock_days = 30   # set to 0 to disable object lock
  }
}
```

### Block storage

```hcl
module "storage" {
  source = "./modules/storage/ovh"

  ovh_project_id  = var.ovh_project_id
  deployment_type = "block"

  block_storage = {
    name        = "my-volume"
    region      = "GRA"
    size        = 50
    volume_type = "high-speed"
    description = "Application data volume"
  }
}
```

## Inputs

| Name | Type | Description |
|------|------|-------------|
| `ovh_project_id` | `string` | OVH Public Cloud project ID |
| `deployment_type` | `string` | `"object"` or `"block"` |
| `object_storage` | `object` | Object storage config — used when `deployment_type = "object"` |
| `block_storage` | `object` | Block storage config — used when `deployment_type = "block"` |

### `object_storage`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | — | Bucket name |
| `region` | `string` | — | OVH region (e.g. `"GRA"`) |
| `versioning` | `string` | `"enabled"` | `"enabled"` or `"disabled"` |
| `encryption_sse` | `string` | `"AES256"` | Server-side encryption algorithm |
| `object_lock_days` | `number` | `0` | Governance-mode retention in days — `0` disables object lock |

### `block_storage`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | — | Volume name |
| `region` | `string` | — | OVH region (e.g. `"GRA"`) |
| `size` | `number` | `10` | Size in GB |
| `volume_type` | `string` | `"classic"` | OVH volume type (e.g. `"high-speed"`, `"classic"`) |
| `description` | `string` | `"Storage"` | Volume description |

## Outputs

| Name | Description |
|------|-------------|
| `storage_id` | ID of the created resource |
| `storage_name` | Name of the created resource |
| `storage_region` | Region of the created resource |

## Provider

```hcl
provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}

provider "openstack" {
  auth_url  = "https://auth.cloud.ovh.net/v3"
  tenant_id = var.ovh_project_id
  user_name = var.openstack_user
  password  = var.openstack_password
  region    = "GRA"
}
```
