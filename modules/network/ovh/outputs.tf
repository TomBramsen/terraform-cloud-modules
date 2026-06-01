output "network_id" {
  description = "ID of the private network"
  value       = ovh_cloud_project_network_private.net.id
}
output "network_name" {
  description = "Name of the private network"
  value       = ovh_cloud_project_network_private.net.name
}
output "subnet_ids" {
  description = "Map of region and their subnet IDs"
  value = {
    for k, v in ovh_cloud_project_network_private_subnet.subnet : k => v.id
  }
}
