output "storage_id" {
  value = var.deployment_type == "object" ? ovh_cloud_project_storage.storage[0].id : openstack_blockstorage_volume_v3.data[0].id
}
