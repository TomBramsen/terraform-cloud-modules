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

variable "dns_servers" {
  type        = list(string)
  description = "DNS servers injected into VMs via userdata (set before apt-get to avoid DNS failures on private subnets)"
  default     = ["1.1.1.2", "1.0.0.2"]
}

variable "azure_ip" {
  type        = string
  description = "Public IP of the Azure VPN gateway (for security group rules + IPsec)"
  default     = "9.205.145.190"
}

variable "azure_psk" {
  type        = string
  description = "Pre-shared key for the IPsec tunnel"
  sensitive   = true
  default     = "123456"
}

variable "azure_subnet" {
  type        = string
  description = "Azure VNet subnet CIDR reachable via the IPsec tunnel"
  default     = "192.168.24.0/22"
}

variable "network_config" {
  type = object({
    name    = optional(string, "test-private-net")
    vlan_id = number
    regions = list(object({
      region              = string
      subnet              = string
      dhcp                = optional(bool, true)
      no_gateway          = optional(bool, false)
      ip_allocation_start = optional(number, 10)
      ip_allocation_stop  = optional(number, 200)
    }))
  })
  description = "OVH private network (vRack) configuration"
  default = {
    name    = "test-private-net"
    vlan_id = 200

    regions = [
      {
        region              = "GRA9"
        subnet              = "10.0.10.0/24"
        dhcp                = true
        no_gateway          = false
        ip_allocation_start = 10
        ip_allocation_stop  = 200
      }
    ]
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources"
  default = {
    managed-by = "terraform"
    module     = "Test_Net_OVH"
  }
}

variable "vm_config" {
  type = object({
    name                 = optional(string, "vpn-vm")
    size                 = optional(string, "d2-4")
    image_name           = optional(string, "Ubuntu 24.04")
    public_net           = optional(bool, true)
    power_state          = optional(string, "active")
    ssh_public_key       = optional(string, null)
    // existing_fip_address = optional(string, null)
     existing_fip_address = optional(string, "145.239.127.208")
    private_ip           = optional(string, "10.0.10.20")  // Must be free.  openstack port list will show used IPs in the subnet.
     user_data            = optional(string, null) 
  })
  
  description = "Virtual machine configuration. user_data is computed in main.tf via templatefile — cannot be set in variable defaults."
  default     = {}
}
