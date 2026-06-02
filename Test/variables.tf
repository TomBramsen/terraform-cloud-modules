# =============================================================================
# GitOps / Flux credentials (sættes via TF_VAR_* miljøvariabler — aldrig hardkodet)
# =============================================================================
variable "netic_git_username" {
  type        = string
  sensitive   = true
  description = "Brugernavn til git.netic.dk (gotk-bootstrap-k8s repo)"
}

variable "netic_git_token" {
  type        = string
  sensitive   = true
  description = "Password / token til git.netic.dk"
}

variable "gitops_ssh_key" {
  type        = string
  sensitive   = true
  description = "Privat SSH-nøgle til kubernetes-config repo (GitHub). Sæt via TF_VAR_gitops_ssh_key=\"$(cat ~/.ssh/id_ed25519_gitops)\""
  default     = ""
}

variable "ovh_api_region" {
  type        = string
  description = "OVH API endpoint region (e.g., 'ovh-eu', 'ovh-ca')"
  default     = "ovh-ca"
}

variable "prefix" {
  type        = string
  description = "Prefix used for resource naming"
  default     = "test"
}

variable "registry_config" {
  type = object({
    deploy = bool
    name   = string
    azure = optional(object({
      sku = optional(string, "Standard")
    }), null)
    ovh = optional(object({
      region = string # e.g., "de" for Germany
    }), null)
  })
  description = "Container registry configuration — provider-specific settings"
  default = {
    deploy = true
    name   = "registry67241ca1d8b349ce9f6fefb72348bad2"
    azure = {
      sku = "Standard"
    }
    ovh = {
      region = "DE"
    }
  }
}

variable "registry_user_email" {
  type        = string
  description = "Email for the CI registry user"
  default     = "ci@example.com"
}

variable "kubernetes_version" {
  type        = string
  description = "Fallback Kubernetes version for AKS"
  default     = "1.34"
}

variable "tags" {
  type        = map(string)
  description = "Global tags applied to all resources"
  default = {
    "owner"       = "team-tbr"
    "environment" = "testing"
  }
}

variable "location" {
  type        = string
  description = "Azure region for resource deployment"
  default     = "denmarkeast"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group"
  default     = "rg-tbr-test"
}
# =============================================================================
# New Structured Object Variables (Matching your .tfvars)
# =============================================================================
variable "cluster_config" {
  type = object({
    cluster_name = string
    environment  = string
    tags         = optional(map(string), {})
  })
  description = "General cluster metadata and tagging"
  default = {
    cluster_name = "tbr-test-cluster"
    environment  = "testing"
    tags = {
      "owner"       = "team-tbr"
      "cost_center" = "test-ops"
    }
  }
}

variable "node_config" {
  type = object({
    node_size          = string # T-shirt size ("small", "medium", "large") or direct VM SKU
    node_count         = number # Desired base/initial node count
    autoscale_enabled  = bool   # Shared autoscale switch
    min_count          = optional(number, null)
    max_count          = optional(number, null)
    availability_zones = optional(list(string), []) # Shared availability zones list
    # Azure format:    ["1", "2", "3"]
    # OVHcloud format: ["eu-west-par-a", "eu-west-par-b", "eu-west-par-c"] / ["eu-south-mil-a", "eu-south-mil-b", "eu-south-mil-c"]
    image_id = optional(string, "1.34") # Optional custom image ID for node pool

    labels = optional(map(string), {}) # Kubernetes node labels
    taints = optional(list(object({    # Kubernetes node taints
      key    = string
      value  = string
      effect = string
    })), [])
  })
  description = "Sizing, scaling, and labeling for the default node pool"
  default = {
    node_size          = "small"
    node_count         = 1
    nodes_min          = 1
    nodes_max          = 2
    autoscale_enabled  = false
    # availability_zones = ["1", "2", "3"]

    labels = {
      "role" = "stateless-apps"
    }
  }
}

variable "network_config" {
  type = object({
    azure = optional(object({
      address_space = list(string)
      subnets       = map(object({ cidr = string }))
    }), null)
    ovh = optional(object({
      vlan_id    = number
      no_gateway = optional(bool, false)
      regions = list(object({
        region              = string
        subnet              = string
        dhcp                = optional(bool, true)
        ip_allocation_start = optional(number, null)
        ip_allocation_stop  = optional(number, null)
      }))
    }), null)
  })
  description = "Netværkskonfiguration — udfyld azure eller ovh blok afhængigt af cloud_settings.cloud_provider"
  default = {
    
    azure = {
      address_space = ["10.0.12.0/22"]
      subnets = {
        aks     = { cidr = "10.0.12.0/24" }
        default = { cidr = "10.0.13.0/24" }
      }
    }
    ovh = {
      vlan_id    = 100
      regions = [
       {
          region = "GRA9"
          subnet = "10.0.0.0/24"
          dhcp   = true
        }
        /*,
    
        {
          region              = "SBG5"
          subnet              = "10.0.1.0/24"
          dhcp                = false
          ip_allocation_start = 50
          ip_allocation_stop  = 150
        }
        */
      ]
      no_gateway = false
    }
  }
}

variable "cloud_settings" {
  type = object({
    cloud_provider     = string # "azure" or "ovh"
    region             = string # Maps to location / ovh_region
    azure = optional(object({
      subscription_id = string
      resource_group  = string
      dns_prefix      = optional(string, null)
    }), null)
    ovh = optional(object({
      project_id = string
    }), null)
    network_id         = optional(string, null) # Eksisterende netværks-ID (VNet subnet for Azure, privat netværk for OVH) — bruges kun hvis netværk er pre-eksisterende
    ip_restrictions    = optional(list(string), [])
  })
  description = "Cloud-specific environment landing zone configurations"

  default = {
  
    cloud_provider = "ovh"
    region         = "GRA9"
    ovh = {
      project_id = "67241ca1d8b349ce9f6fefb72348bad2"
    }
    network_id       = null
    ip_restrictions = [
      "77.243.59.220/32",
      "185.29.76.1/32",
      "185.29.76.2/32",
      "20.126.188.216/32",
      "20.23.62.36/32",
      "185.181.22.4/32",
      "4.205.250.156/32",
      "212.169.216.3/32",
      "185.181.22.18/32",
      "46.27.142.96/32"
    ]
  }
  /*
  default = {
    cloud_provider = "azure"
    region         = "denmarkeast"
    azure = {
      subscription_id = "9cbb71c9-7f62-4277-a708-f89d1f020134"
      resource_group  = "rg-tbr-test"
      dns_prefix      = "tbrtestdns"
    }
    network_id       = null
    ip_restrictions = [
      "77.243.59.220/32",
      "185.29.76.1/32",
      "185.29.76.2/32",
      "20.126.188.216/32",
      "20.23.62.36/32",
      "185.181.22.4/32",
      "4.205.250.156/32",
      "212.169.216.3/32",
      "185.181.22.18/32",
      "46.27.142.96/32"
    ]
  }
  */

  ## Kommenter den version ind der skal bruges : Azure eller OVH
  
}
