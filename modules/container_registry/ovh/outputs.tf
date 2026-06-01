output "registry_url" {
  value       = ovh_cloud_project_containerregistry.registry.url
  description = "The public URL endpoint of the provisioned Container Registry"
}


# Returnerer et map: { "bruger1" = "password123", "bruger2" = "password456" }
output "user_passwords" {
  value       = { for k, v in ovh_cloud_project_containerregistry_user.user : k => v.password }
  sensitive   = true
  description = "Map of registry usernames and their generated passwords"
}
