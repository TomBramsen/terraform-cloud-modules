variable "cloud_provider" {
  type        = string
  description = "Cloud provider to deploy Kubernetes to: 'ovh' or 'azure'"
  validation {
    condition     = contains(["ovh", "azure"], var.cloud_provider)
    error_message = "cloud_provider must be 'ovh' or 'azure'."
  }
}

variable "kube_cluster" {
  type = object({
    name            = string
    version         = string
    ip_restrictions = optional(list(string), [])
  })
  description = "Common Kubernetes cluster configuration shared across all cloud providers"
}

variable "kube_node_pools" {
  type = map(object({
    size        = string
    nodes_count = number
    nodes_min   = number
    nodes_max   = number
    labels      = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  default     = {}
  description = "Node pools to create. For Azure, one entry must match azure_config.default_node_pool_name."
}

# OVH-specific configuration
variable "ovh_config" {
  type = object({
    project_id = string
    region     = string
  })
  default     = null
  description = "OVH-specific configuration. Required when cloud_provider = 'ovh'."
}

# Azure-specific configuration
variable "azure_config" {
  type = object({
    location               = string
    resource_group         = string
    dns_prefix             = optional(string, null)
    default_node_pool_name = optional(string, "system")
    vnet_subnet_id         = optional(string, null)
  })
  default     = null
  description = "Azure-specific configuration. Required when cloud_provider = 'azure'."
}
