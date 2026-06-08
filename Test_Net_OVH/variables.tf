variable "ovh_api_region" {
  type        = string
  description = "OVH API endpoint region (e.g. 'ovh-eu', 'ovh-ca')"
  default     = "ovh-ca"
}

variable "cloud_settings" {
  type = object({
    ovh_project_id = string
    region         = string
  })
  description = "OVH landing zone settings"
  default = {
    ovh_project_id = "67241ca1d8b349ce9f6fefb72348bad2"
    region         = "GRA9"
  }
}

variable "azure_ip" {
  type        = string
  description = "Public IP of the Azure VPN gateway (for security group rules + IPsec)"
  default     = "9.205.168.26"
}

variable "azure_psk" {
  type        = string
  description = "Pre-shared key til IPsec tunnelen"
  sensitive   = true
  default     = "123456"
}

variable "azure_subnet" {
  type        = string
  description = "Azure VNet subnet CIDR der skal nås via tunnelen"
  default     = "192.168.24.0/24"
}

variable "network_config" {
  type = object({
    name       = optional(string, "test-private-net")
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
  description = "OVH private network (vRack) configuration"
  default = {
    name       = "test-private-net"
    vlan_id    = 200
    no_gateway = false

    regions = [
      {
        region              = "GRA9"
        subnet              = "10.0.10.0/24"
        dhcp                = true
        ip_allocation_start = 10
        ip_allocation_stop  = 200
      }
    ]
  }
}

variable "vm_config" {
  type = object({
    name        = optional(string, "vpn-vm")
    size        = optional(string, "d2-4")
    image_name  = optional(string, "Ubuntu 24.04")
    public_net  = optional(bool, true)
    power_state = optional(string, "active")
    sshkey      = optional(string, null)
  })
  description = "Virtual machine configuration. user_data genereres i main.tf via templatefile — kan ikke sættes i variable default."
  default     = {}
}
