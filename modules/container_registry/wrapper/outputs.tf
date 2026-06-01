output "registry_url" {
  value       = var.cloud_provider == "ovh" ? one(module.ovh[*].registry_url) : one(module.azure[*].registry_url)
  description = "URL/login server of the container registry"
}

output "user_passwords" {
  value       = var.cloud_provider == "ovh" ? one(module.ovh[*].user_passwords) : one(module.azure[*].user_passwords)
  sensitive   = true
  description = "Map of usernames and their generated passwords"
}
