variable "deployment_type" {
  type        = string
  description = "Which storage to deploy: 'object' (Storage Account + Blob Container) or 'block' (Managed Disk)"
  validation {
    condition     = contains(["object", "block"], var.deployment_type)
    error_message = "deployment_type must be 'object' or 'block'."
  }
}

variable "object_storage" {
  description = "Object storage config (used when deployment_type = 'object')"
  type = object({
    name             = string
    resource_group   = string
    location         = string
    replication_type = optional(string, "LRS")
    versioning       = optional(bool, true)
    retention_days   = optional(number, 0)
    container_name   = optional(string, "data")
  })
  default = {
    name           = "mystorageaccount"
    resource_group = ""
    location       = ""
  }
}

variable "block_storage" {
  description = "Block storage config (used when deployment_type = 'block')"
  type = object({
    name                 = string
    resource_group       = string
    location             = string
    size                 = optional(number, 10)
    storage_account_type = optional(string, "Standard_LRS")
    description          = optional(string, "Storage")
  })
  default = {
    name           = "mymanageddisk"
    resource_group = ""
    location       = ""
  }
}
