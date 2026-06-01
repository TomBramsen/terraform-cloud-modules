variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "location" {
  type        = string
  description = "Azure region to deploy all resources"
  default     = "westeurope"
}

variable "resource_group" {
  type        = string
  description = "Name of the resource group to create"
  default     = "test-infra-rg"
}

variable "prefix" {
  type        = string
  description = "Prefix used for resource naming"
  default     = "test"
}

variable "registry_name" {
  type        = string
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
  default     = "1.30"
}
