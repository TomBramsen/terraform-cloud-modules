terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = ">= 1.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}
