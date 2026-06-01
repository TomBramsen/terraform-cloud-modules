output "registry_url" {
  value       = var.container_registry.deploy ? azurerm_container_registry.registry[0].login_server : null
  description = "Login server URL of the ACR (e.g. myregistry.azurecr.io)"
}

output "admin_username" {
  value       = var.container_registry.deploy ? azurerm_container_registry.registry[0].admin_username : null
  description = "Admin username for the registry"
}

output "admin_password" {
  value       = var.container_registry.deploy ? azurerm_container_registry.registry[0].admin_password : null
  sensitive   = true
  description = "Admin password for the registry"
}

output "user_passwords" {
  value       = { for k, v in azurerm_container_registry_token_password.user_password : k => v.password1[0].value }
  sensitive   = true
  description = "Map of token usernames and their generated passwords"
}
