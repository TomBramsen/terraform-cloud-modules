# Network — Wrapper

Provisions a private network on either **OVHcloud** (vRack) or **Azure** (VNet) using a shared entry point.

The network architectures differ between clouds — OVH uses VLAN-based private networking across regions, Azure uses address-space-based VNets with named subnets — so each cloud has its own config block.

## Usage

### OVHcloud

```hcl
module "network" {
  source         = "./modules/network/wrapper"
  cloud_provider = "ovh"
  network_name   = "my-private-network"

  ovh_config = {
    project_id = var.ovh_project_id
    vlan_id    = 100
    regions = [
      { region = "GRA11", subnet = "10.0.0.0/24" },
      { region = "SBG5",  subnet = "10.0.1.0/24", dhcp = false }
    ]
  }
}
```

### Azure

```hcl
module "network" {
  source         = "./modules/network/wrapper"
  cloud_provider = "azure"
  network_name   = "my-vnet"

  azure_config = {
    location       = "westeurope"
    resource_group = "my-rg"
    address_space  = ["10.0.0.0/16"]
    subnets = {
      default = { cidr = "10.0.1.0/24" }
      aks     = { cidr = "10.0.2.0/24" }
    }
  }
}
```

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `cloud_provider` | `string` | yes | `"ovh"` or `"azure"` |
| `network_name` | `string` | yes | Network name (used on both clouds) |
| `ovh_config` | `object` | if OVH | `{ project_id, vlan_id, regions, no_gateway? }` |
| `azure_config` | `object` | if Azure | `{ location, resource_group, address_space, subnets }` |

## Outputs

| Name | Description |
|------|-------------|
| `network_id` | ID of the created network |
| `network_name` | Name of the network |
| `subnet_ids` | Map of region/name → subnet ID — use with the VM wrapper's `ovh_config.network_names` or `azure_config.subnet_id` |
