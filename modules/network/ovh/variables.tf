variable "ovh_project_id" {
  description = "OVH Cloud project ID / service name"
  type        = string
}

variable "network_name" {
  description = "Name of the private network"
  type        = string
}

variable "vlan_id" {
  description = "VLAN ID for the private network"
  type        = number
}

variable "regions" {
  type = list(object({
    region              = string
    subnet              = string
    dhcp                = optional(bool, true)   # Defaults to true if omitted by the user
    ip_allocation_start = optional(number, 10)   # Defaults to 10 if omitted by the user
    ip_allocation_stop  = optional(number, 200)  # Defaults to 200 if omitted by the user
  }))
  description = "List of regions and their associated subnet configurations"
}

variable "no_gateway" {
  description = "Disable gateway on subnets"
  type        = bool
  default     = false
}