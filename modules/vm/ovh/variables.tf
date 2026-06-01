variable "ovh_project_id" {
  description = "OVH Cloud project ID / service name"
  type        = string
}

variable "vm" {
  type = object({
    name          = string
    size          = string
    image_name    = string
    sshkey        = optional(string, null)
    admin_pass    = optional(string, "Password123!")
    network_names = optional(list(string), [])
    power_state   = optional(string, "active")
    user_data     = optional(string, null)
  })
  default = {
    name          = "netic-vpn"
    size          = "b2-7"
    image_name    = "Ubuntu 24.04"
    network_names = ["netic-vpn-net"] // ["netic-vpn-net", "Ext-Net"] 
  }
}
