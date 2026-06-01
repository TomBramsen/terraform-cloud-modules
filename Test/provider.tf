terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 3.0.0"
    }

    ovh = {
      source  = "ovh/ovh"
      version = ">= 2.1.0"
    }

    tls = {
      source = "hashicorp/tls"
    }

    local = {
      source = "hashicorp/local"
    }
    
  }
 /* backend "azurerm" {
    resource_group_name  = "rg-tbr-test2"
    storage_account_name = "storagetbrnetictest10" 
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
  */
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
   resource_provider_registrations = "none"
}

provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3"
  domain_name = "Default"

  tenant_id = var.ovh_project_id
  region    = var.ovh_region
  user_name = var.OS_username
  password  = var.OS_password
}

provider "ovh" {
  endpoint = var.ovh_api_region
}