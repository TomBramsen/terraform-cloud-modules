terraform {
  required_version = ">= 1.5"

  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = ">= 2.1.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 3.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}

provider "ovh" {
  endpoint = var.ovh_api_region
}

provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3"
  domain_name = "Default"
  tenant_id   = var.cloud_settings.ovh_project_id
  region      = var.cloud_settings.region
}

# Required because network/wrapper and vm/wrapper both declare azurerm in their
# required_providers (to support the Azure path). No resources use it here.
provider "azurerm" {
  features {}
  subscription_id                 = ""
  resource_provider_registrations = "none"
}
