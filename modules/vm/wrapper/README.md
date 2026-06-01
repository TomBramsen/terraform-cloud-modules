# VM — Wrapper

Provisions a virtual machine on either **OVHcloud** or **Azure** using a shared interface. Common config (name, size, password, user-data) is passed at the top level; cloud-specific config is passed in `ovh_config` or `azure_config`.

## Usage

### OVHcloud

```hcl
module "vm" {
  source         = "./modules/vm/wrapper"
  cloud_provider = "ovh"

  vm = {
    name = "my-server"
    size = "b2-7"
  }

  ovh_config = {
    project_id    = var.ovh_project_id
    image_name    = "Ubuntu 24.04"
    network_names = ["my-private-network", "Ext-Net"]
  }
}
```

### Azure

```hcl
module "vm" {
  source         = "./modules/vm/wrapper"
  cloud_provider = "azure"

  vm = {
    name = "my-server"
    size = "Standard_D2s_v3"
  }

  azure_config = {
    location         = "westeurope"
    resource_group   = "my-rg"
    subnet_id        = module.network.subnet_ids["default"]
    create_public_ip = true
    image = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
    }
  }
}

output "ssh_key" { value = module.vm.ssh_private_key; sensitive = true }
output "ip"      { value = module.vm.public_ip }
```

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `cloud_provider` | `string` | yes | `"ovh"` or `"azure"` |
| `vm` | `object` | yes | Common config: `name`, `size`, `admin_pass?`, `user_data?` |
| `ovh_config` | `object` | if OVH | `{ project_id, image_name, network_names?, sshkey?, power_state? }` |
| `azure_config` | `object` | if Azure | `{ location, resource_group, subnet_id, image, os_type?, admin_username?, ssh_public_key?, create_public_ip? }` |

## Outputs

| Name | Description |
|------|-------------|
| `vm_name` | Name of the VM |
| `vm_ip` | Primary private IPv4 address |
| `public_ip` | Public IP (null if not configured) |
| `ssh_private_key` | Generated SSH private key *(sensitive)* — null if a key was provided |
