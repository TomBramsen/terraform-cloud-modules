variable "ovh_project_id" {
  type        = string
  description = "OVH Public Cloud Project ID"
}

variable "ovh_region" {
  type        = string
  description = "OVH Region (fx GRA11)"
}

## Kubernetes Managed Cluster instance
variable "kube_cluster" {
  type = object({
    name            = string
    version         = string
    ip_restrictions = optional(list(string), [])
  })
}

# All the nodepools for the above Cluster
variable "kube_node_pools" {
  type = map(object({
    size        = string
    nodes_count = number
    nodes_min   = number
    nodes_max   = number
    labels      = optional(map(string), {})
    taints      = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  default = {}
}