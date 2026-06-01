
# -----------------------------------------------------------------------------
# Object Storage (S3 compatible)
# -----------------------------------------------------------------------------
# https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_storage#sse_algorithm-1

resource "ovh_cloud_project_storage" "storage" {
  count = var.deployment_type == "object" ? 1 : 0

  service_name = var.ovh_project_id
  region_name  = var.object_storage.region
  name         = var.object_storage.name

  encryption = {
    sse_algorithm = var.object_storage.encryption_sse
  }

  versioning = {
    status = var.object_storage.versioning
  }

  object_lock = {
    status = var.object_storage.object_lock_days > 0 ? "enabled" : "disabled"
    rule = {
      mode   = "governance"
      period = "P${var.object_storage.object_lock_days}D"
    }
  }
}

# -----------------------------------------------------------------------------
# Block Storage (Persistent Volumes)
# -----------------------------------------------------------------------------
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/blockstorage_volume_v3

resource "openstack_blockstorage_volume_v3" "data" {
  count = var.deployment_type == "block" ? 1 : 0

  region      = var.block_storage.region
  name        = var.block_storage.name
  description = var.block_storage.description
  size        = var.block_storage.size
  volume_type = var.block_storage.volume_type
}