output "registry_url" {
  value       = var.container_registry.deploy ? ovh_cloud_project_containerregistry.registry[0].url : null
  description = "The public URL endpoint of the provisioned Container Registry"
}

output "user_passwords" {
  value       = { for k, v in ovh_cloud_project_containerregistry_user.user : k => v.password }
  sensitive   = true
  description = "Map of registry usernames and their generated passwords"
}
