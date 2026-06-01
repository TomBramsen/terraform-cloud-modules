variable "kube_cluster" {
  type = object({
    name                   = string
    version                = string
    location               = string
    resource_group         = string
    dns_prefix             = optional(string, null)
    default_node_pool_name = optional(string, "system")
    ip_restrictions        = optional(list(string), [])
    vnet_subnet_id         = optional(string, null)
  })
  description = "AKS cluster configuration. Node pool names must be <= 12 lowercase alphanumeric characters."
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
  description = "Map of node pools. One entry must match kube_cluster.default_node_pool_name — it becomes the AKS system pool."
}
