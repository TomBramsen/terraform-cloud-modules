variable "network_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "location" {
  type        = string
  description = "Azure region (e.g. 'westeurope')"
}

variable "resource_group" {
  type        = string
  description = "Name of an existing resource group"
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the VNet (e.g. ['10.0.0.0/16'])"
}

variable "subnets" {
  type = map(object({
    cidr = string
  }))
  description = "Map of subnet name to CIDR (e.g. { default = { cidr = '10.0.1.0/24' } })"
}
