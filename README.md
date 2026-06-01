# terraform-cloud-modules

A library of reusable Terraform modules for provisioning cloud infrastructure on **OVHcloud** and **Azure**. Every module comes in three flavours: an OVH implementation, an Azure implementation, and a **wrapper** that lets you switch between clouds with a single variable.

---

## What this repo provides

### Modules

| Module | OVH | Azure | Wrapper |
|--------|-----|-------|---------|
| **network** | vRack private network + subnets per region | Virtual Network + subnets | `cloud_provider = "ovh" \| "azure"` |
| **vm** | OpenStack compute instance (Linux/Windows) | Azure VM (Linux/Windows) | `cloud_provider = "ovh" \| "azure"` |
| **storage** | S3-compatible object storage or block volume | Storage Account + Blob / Managed Disk | `cloud_provider = "ovh" \| "azure"` |
| **container_registry** | OVH Managed Container Registry | Azure Container Registry (ACR) | `cloud_provider = "ovh" \| "azure"` |
| **kubernetes** | OVH Managed Kubernetes (MKS) | Azure Kubernetes Service (AKS) | `cloud_provider = "ovh" \| "azure"` |

### Common features across all modules

- **Auto SSH key generation** — VM modules generate a 4096-bit RSA key pair when no key is provided and expose the private key as a sensitive output.
- **Autoscaling** — Kubernetes node pools and (where applicable) compute resources are configured with min/max bounds out of the box.
- **IP restrictions** — Kubernetes API and container registry access can be locked down to specific CIDR ranges.
- **Consistent outputs** — wrapper modules expose identical output names regardless of the active cloud, making it easy to wire modules together.
- **deploy flag** — the container registry module supports `deploy = false` to skip resource creation entirely, useful in multi-environment setups.

---

## Repository structure

```
modules/
  network/
    ovh/          OVH vRack + subnets
    azure/        Azure VNet + subnets
    wrapper/      cloud-agnostic entry point
  vm/
    ovh/          OVH OpenStack VM
    azure/        Azure Linux / Windows VM
    wrapper/      cloud-agnostic entry point
  storage/
    ovh/          OVH object or block storage
    azure/        Azure Blob or Managed Disk
    wrapper/      cloud-agnostic entry point
  container_registry/
    ovh/          OVH Managed Registry + users + IP rules
    azure/        Azure ACR + tokens + IP rules
    wrapper/      cloud-agnostic entry point
  kubernetes/
    ovh/          OVH Managed Kubernetes + node pools
    azure/        AKS + node pools + VNet integration
    wrapper/      cloud-agnostic entry point

Test/             Example: network + registry + AKS on Azure
```

---

## Quick start — deploy to OVHcloud

```hcl
module "network" {
  source         = "./modules/network/wrapper"
  cloud_provider = "ovh"
  network_name   = "prod-network"

  ovh_config = {
    project_id = var.ovh_project_id
    vlan_id    = 100
    regions    = [{ region = "GRA11", subnet = "10.0.0.0/24" }]
  }
}

module "kubernetes" {
  source         = "./modules/kubernetes/wrapper"
  cloud_provider = "ovh"

  kube_cluster = { name = "prod-cluster", version = "1.30" }

  ovh_config = { project_id = var.ovh_project_id, region = "GRA11" }

  kube_node_pools = {
    default = { size = "b3-8", nodes_count = 2, nodes_min = 1, nodes_max = 5 }
  }
}
```

## Quick start — deploy to Azure

```hcl
module "network" {
  source         = "./modules/network/wrapper"
  cloud_provider = "azure"
  network_name   = "prod-vnet"

  azure_config = {
    location       = "westeurope"
    resource_group = "prod-rg"
    address_space  = ["10.0.0.0/16"]
    subnets        = { aks = { cidr = "10.0.0.0/22" } }
  }
}

module "kubernetes" {
  source         = "./modules/kubernetes/wrapper"
  cloud_provider = "azure"

  kube_cluster = { name = "prod-cluster", version = "1.30" }

  azure_config = {
    location               = "westeurope"
    resource_group         = "prod-rg"
    default_node_pool_name = "system"
    vnet_subnet_id         = module.network.subnet_ids["aks"]
  }

  kube_node_pools = {
    system = { size = "Standard_D2s_v3", nodes_count = 2, nodes_min = 1, nodes_max = 5 }
  }
}
```

---

## Switching clouds

The only change required to move a workload between clouds is updating `cloud_provider` and providing the matching `ovh_config` / `azure_config` block. All other configuration (cluster name, version, node pool sizes and counts, IP restrictions) stays the same.

```hcl
# Change this one line (and swap the config block) to switch providers:
cloud_provider = "ovh"   # or "azure"
```

---

## Example deployment

The [`Test/`](Test/) directory contains a complete working example that provisions a **VNet**, an **ACR container registry**, and an **AKS cluster** on Azure using the wrapper modules. It can be used as a starting point for a real environment.

```bash
cd Test
terraform init
terraform apply \
  -var="subscription_id=<your-subscription-id>" \
  -var="registry_name=<globally-unique-name>"
```

---

## Module documentation

Each module has its own README with a full input/output reference and usage examples.

| Module | README |
|--------|--------|
| network/ovh | [modules/network/ovh/README.md](modules/network/ovh/README.md) |
| network/azure | [modules/network/azure/README.md](modules/network/azure/README.md) |
| network/wrapper | [modules/network/wrapper/README.md](modules/network/wrapper/README.md) |
| vm/ovh | [modules/vm/ovh/README.md](modules/vm/ovh/README.md) |
| vm/azure | [modules/vm/azure/README.md](modules/vm/azure/README.md) |
| vm/wrapper | [modules/vm/wrapper/README.md](modules/vm/wrapper/README.md) |
| storage/ovh | [modules/storage/ovh/README.md](modules/storage/ovh/README.md) |
| storage/azure | [modules/storage/azure/README.md](modules/storage/azure/README.md) |
| storage/wrapper | [modules/storage/wrapper/README.md](modules/storage/wrapper/README.md) |
| container_registry/ovh | [modules/container_registry/ovh/README.md](modules/container_registry/ovh/README.md) |
| container_registry/azure | [modules/container_registry/azure/README.md](modules/container_registry/azure/README.md) |
| container_registry/wrapper | [modules/container_registry/wrapper/README.md](modules/container_registry/wrapper/README.md) |
| kubernetes/ovh | [modules/kubernetes/ovh/README.md](modules/kubernetes/ovh/README.md) |
| kubernetes/azure | [modules/kubernetes/azure/README.md](modules/kubernetes/azure/README.md) |
| kubernetes/wrapper | [modules/kubernetes/wrapper/README.md](modules/kubernetes/wrapper/README.md) |

---

## Provider requirements

| Provider | Used by |
|----------|---------|
| `ovh/ovh >= 1.0.0` | All OVH modules |
| `terraform-provider-openstack/openstack >= 3.0.0` | OVH VM, storage |
| `hashicorp/azurerm >= 4.0.0` | All Azure modules |
| `hashicorp/tls >= 4.0.0` | VM modules (SSH key generation) |
