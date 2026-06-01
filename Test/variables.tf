variable "subscription_id" {
  type        = string
  default = "9cbb71c9-7f62-4277-a708-f89d1f020134"
}

variable "location" {
  type        = string
  description = "Azure region to deploy all resources"
  default     = "denmarkeast"
}

variable "resource_group" {
  type        = string
  description = "Name of the resource group to create"
  default     = "rg-tbr-test2"
}

variable "prefix" {
  type        = string
  description = "Prefix used for resource naming"
  default     = "test"
}

variable "registry_name" {
  type        = string
  default = "registry67241ca1d8b349ce9f6fefb72348bad2"
  description = "Container registry name — must be globally unique, 5-50 alphanumeric chars"
}

variable "registry_user_email" {
  type        = string
  description = "Email for the CI registry user"
  default     = "ci@example.com"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for AKS"
  default     = "1.34"
}

variable "ovh_project_id" {
  type        = string
  description = "OVH Cloud project ID for OpenStack resources"
  default     = "67241ca1d8b349ce9f6fefb72348bad2"
}

variable "ovh_region" {
  type        = string
  description = "OVH Cloud region for OpenStack resources"
  default     = "GRA9"
}

variable "OS_username" {
  type        = string
  description = "OpenStack username for OVH authentication"
  default     = "your-ovh-username"
}

variable "OS_password" {
  type        = string
  description = "OpenStack password for OVH authentication"
  default     = "your-ovh-password"
  sensitive   = true
}

variable "ovh_api_region" {
  type        = string
  description = "OVH API region endpoint identifier"
  default     = "ovh-ca"
}
