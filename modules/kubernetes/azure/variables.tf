variable "cluster_config" {
  type = object({
    name        = string
    environment = string
    version     = string
  })
  description = "Core Kubernetes cluster settings"
}

variable "node_config" {
type = object({
    sku                = string
    node_count         = number
    autoscale_enabled  = bool
    min_count          = number
    max_count          = number
   availability_zones = optional(list(string), []) # Shared availability zones list
     labels             = map(string)
    taints             = list(any)
  })
  description = "Default node pool sizing and scaling settings"
}

variable "cloud_settings" {
  type = object({
    resource_group  = string
    location        = string
    dns_prefix      = string
    vnet_subnet_id  = optional(string)
    ip_restrictions = optional(list(string), [])
  })
  description = "Azure infrastructure and network specific settings"
}
