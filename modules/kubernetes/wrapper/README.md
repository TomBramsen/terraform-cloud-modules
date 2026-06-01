# Kubernetes — Wrapper

A unified entry point that deploys a managed Kubernetes cluster to either **OVHcloud** or **Azure** using a shared variable interface. The cloud-specific implementation is selected at runtime via `cloud_provider`.

> For full usage examples and provider configuration, see the [module root README](../README.md).

## How it works

The wrapper contains two conditional module calls — one for OVH, one for Azure — each guarded by `count`. Only the selected provider's resources are created. Outputs are identical regardless of which cloud is active.

```
cloud_provider = "ovh"   →  module.ovh[0]   (module.azure is count = 0)
cloud_provider = "azure" →  module.azure[0] (module.ovh  is count = 0)
```

## Usage

```hcl
module "kubernetes" {
  source         = "./modules/kubernetes/wrapper"
  cloud_provider = "ovh"   # or "azure"

  kube_cluster = {
    name    = "my-cluster"
    version = "1.30"
  }

  # Provide only the block that matches cloud_provider:
  ovh_config = {
    project_id = var.ovh_project_id
    region     = "GRA11"
  }

  kube_node_pools = {
    default = {
      size        = "b3-8"
      nodes_count = 2
      nodes_min   = 1
      nodes_max   = 5
    }
  }
}

output "kubeconfig" {
  value     = module.kubernetes.kubeconfig
  sensitive = true
}
```

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `cloud_provider` | `string` | yes | `"ovh"` or `"azure"` |
| `kube_cluster` | `object` | yes | Common cluster config: `name`, `version`, `ip_restrictions` |
| `kube_node_pools` | `map(object)` | no | Node pools (see child module READMEs for size formats) |
| `ovh_config` | `object` | if OVH | `{ project_id, region }` |
| `azure_config` | `object` | if Azure | `{ location, resource_group, default_node_pool_name?, dns_prefix? }` |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | ID of the created cluster |
| `cluster_name` | Name of the cluster |
| `node_pool_ids` | Map of pool names → IDs |
| `kubeconfig` | Raw kubeconfig string *(sensitive)* |

## Provider configuration

Both providers are declared in `provider.tf` so Terraform can load their schemas. Only the active provider needs to be authenticated — the inactive one is initialized but makes no API calls.

Declare providers in your root module:

```hcl
# OVH
provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}

# Azure
provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}
```
