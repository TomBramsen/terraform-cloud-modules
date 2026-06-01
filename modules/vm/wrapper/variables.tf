variable "cloud_provider" {
  type        = string
  description = "Cloud provider: 'ovh' or 'azure'"
  validation {
    condition     = contains(["ovh", "azure"], var.cloud_provider)
    error_message = "cloud_provider must be 'ovh' or 'azure'."
  }
}

variable "vm" {
  type = object({
    name       = string
    size       = string
    admin_pass = optional(string, null)
    user_data  = optional(string, null)
  })
  description = "Common VM configuration shared across cloud providers"
}

variable "ovh_config" {
  type = object({
    project_id    = string
    image_name    = string
    network_names = optional(list(string), [])
    sshkey        = optional(string, null)
    power_state   = optional(string, "active")
  })
  default     = null
  description = "OVH-specific VM config. Required when cloud_provider = 'ovh'."
}

variable "azure_config" {
  type = object({
    location         = string
    resource_group   = string
    subnet_id        = string
    os_type          = optional(string, "Linux")
    admin_username   = optional(string, "azureuser")
    ssh_public_key   = optional(string, null)
    create_public_ip = optional(bool, false)
    image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = optional(string, "latest")
    })
  })
  default     = null
  description = "Azure-specific VM config. Required when cloud_provider = 'azure'."
}
