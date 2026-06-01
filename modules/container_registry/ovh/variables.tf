# modules/ovh_container_registry/variables.tf

variable "ovh_project_id" {
  type        = string
  description = "OVH cloud projektets service ID"
}

variable "container_registry" {
  type = object({
    deploy = bool
    name   = string
    region = string
    plan   = optional(string, "S")
    size   = optional(number, 209715200 )     # 200 MB in Bytes (200*1024*1024) (209715200 Bytes)
  })
  description = "Configuration of OVH Container Registry"
}

variable "registry_users" {
  type = list(object({
    login = string
    email = string
  }))
  description = "List of user accounts to create in the container registry"
  
  default = [
    {
      login = "netic-registry-user"
      email = "infra-automation@netic.dk"
    }
  ]
}

variable "ip_restrictions" {
  type = list(object({
    ip_block    = string
    description = string
  }))
  default     = []
  description = "List of IP blocks allowed to access the container registry. Leave empty for no restrictions."
}