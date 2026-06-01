variable "cloud_provider" {
  type        = string
  description = "Cloud provider: 'ovh' or 'azure'"
  validation {
    condition     = contains(["ovh", "azure"], var.cloud_provider)
    error_message = "cloud_provider must be 'ovh' or 'azure'."
  }
}

variable "deployment_type" {
  type        = string
  description = "Which storage to deploy: 'object' or 'block'"
  validation {
    condition     = contains(["object", "block"], var.deployment_type)
    error_message = "deployment_type must be 'object' or 'block'."
  }
}

variable "ovh_config" {
  type = object({
    project_id = string
  })
  default     = null
  description = "OVH-specific config. Required when cloud_provider = 'ovh'."
}

variable "ovh_object_storage" {
  type = object({
    name             = string
    region           = string
    versioning       = optional(string, "enabled")
    encryption_sse   = optional(string, "AES256")
    object_lock_days = optional(number, 0)
  })
  default     = null
  description = "OVH object storage config. Required when cloud_provider = 'ovh' and deployment_type = 'object'."
}

variable "ovh_block_storage" {
  type = object({
    name        = string
    region      = string
    size        = optional(number, 10)
    volume_type = optional(string, "classic")
    description = optional(string, "Storage")
  })
  default     = null
  description = "OVH block storage config. Required when cloud_provider = 'ovh' and deployment_type = 'block'."
}

variable "azure_object_storage" {
  type = object({
    name             = string
    resource_group   = string
    location         = string
    replication_type = optional(string, "LRS")
    versioning       = optional(bool, true)
    retention_days   = optional(number, 0)
    container_name   = optional(string, "data")
  })
  default     = null
  description = "Azure object storage config. Required when cloud_provider = 'azure' and deployment_type = 'object'."
}

variable "azure_block_storage" {
  type = object({
    name                 = string
    resource_group       = string
    location             = string
    size                 = optional(number, 10)
    storage_account_type = optional(string, "Standard_LRS")
    description          = optional(string, "Storage")
  })
  default     = null
  description = "Azure block storage config. Required when cloud_provider = 'azure' and deployment_type = 'block'."
}
