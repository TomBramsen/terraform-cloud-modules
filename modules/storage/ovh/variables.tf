variable "ovh_project_id" {
  description = "OVH Cloud project ID / service name"
  type        = string
}

variable "deployment_type" {
  description = "Which storage to deploy: object or block"
  type        = string

  validation {
    condition     = contains(["object", "block"], var.deployment_type)
    error_message = "deployment_type must be 'object' or 'block'."
  }
}

variable "object_storage" {
  description = "Object storage config (used when deployment_type = object)"
  type = object({
    name             = string
    region           = string
    versioning       = optional(string, "enabled")
    encryption_sse   = optional(string, "AES256")
    object_lock_days = optional(number, 0)
  })

  default = {
    name   = "object-storage"
    region = "GRA"
  }
}

variable "block_storage" {
  description = "Block storage config (used when deployment_type = block)"
  type = object({
    name        = string
    region      = string
    size        = optional(number, 10)
    volume_type = optional(string, "classic")
    description = optional(string, "Storage")
  })

  default = {
    name   = "block-storage"
    region = "GRA"
  }
}
