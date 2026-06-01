terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
    }

    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 3.0.0"
    }
  }
}