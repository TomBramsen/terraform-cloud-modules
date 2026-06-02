variable "netic_username" {
  type      = string
  sensitive = true
}

variable "netic_password" {
  type      = string
  sensitive = true
}

variable "cluster_simple_name" {
  type = string
}

variable "cluster_repo" {
  type        = string
  description = "The Git URL for the cluster repository"
}

variable "region" {
  type = string
}

variable "environment" {
  type        = string
  description = "The stage of the development lifecycle for the workload that the resource supports."
}

variable "cluster_dns" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "dns_client_id" {
  type = string
}

variable "vault_server" {
  type = string
  description = "URL of Vaultserver"
}

variable "otel_server" {
  type = string
  description = "URL of Otelserver"
}

variable "cluster_operator" {
  type = string
  description = "Cluster operator"
}

variable "cluster_provider" {
  type = string
  description = "Cluster Provider"
}

variable "cluster_type" {
  type = string
  description = "Cluster type"
}

variable "cluster_env" {
  type = string
  description = "Cluster environment"
}

variable "infra_bootstrap_resilience_zone" {
  type = string
  description = "kubernetes infrastructure config resilience zone / branch"
}

variable "ingress_type" {
  type = string
  description = "List of supported ingress controllers"
  
  validation {
    condition = contains(["contour", "istio"], var.ingress_type)
    error_message = "Unsupported ingress type. Choose contour or istio"
  }
  
}

variable "ingress_source" {
  type = string
  description = "Defines external-dns source. istio vs contour"

  validation {
    condition = contains(["contour-httpproxy", "istio-virtualservice"], var.ingress_source)
    error_message = "Unsupported ingress source. Choose contour-httpproxy or istio-virtualservice"
  }

}