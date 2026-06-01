variable "cloud_provider" {
  type        = string
  description = "Cloud provider: 'ovh' or 'azure'"
  validation {
    condition     = contains(["ovh", "azure"], var.cloud_provider)
    error_message = "cloud_provider must be 'ovh' or 'azure'."
  }
}

variable "network_name" {
  type        = string
  description = "Name of the network (used on both clouds)"
}

variable "ovh_config" {
  type = object({
    project_id = string
    vlan_id    = number
    no_gateway = optional(bool, false)
    regions = list(object({
      region              = string
      subnet              = string
      dhcp                = optional(bool, true)
      ip_allocation_start = optional(number, 10)
      ip_allocation_stop  = optional(number, 200)
    }))
  })
  default     = null
  description = "OVH-specific network config. Required when cloud_provider = 'ovh'."
}

variable "azure_config" {
  type = object({
    location       = string
    resource_group = string
    address_space  = list(string)
    subnets = map(object({
      cidr = string
    }))
  })
  default     = null
  description = "Azure-specific network config. Required when cloud_provider = 'azure'."
}
