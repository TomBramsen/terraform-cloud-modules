/*
Apply and force scripts to be re-run:

terraform apply \
  -replace="module.vm.module.ovh[0].openstack_compute_instance_v2.VMLinux[0]" \
  -replace="module.clientvm.module.ovh[0].openstack_compute_instance_v2.VMLinux[0]" \
  -auto-approve

*/


locals {
  # Ext-Net til public IP — port security styres af OVH selv på dette netværk
  public_network_names = var.vm_config.public_net ? ["Ext-Net"] : []

  # user_data beregnes her — templatefile() og variable-referencer er ikke
  # tilladte i variable defaults, så vi gør det i locals i stedet
  vm_userdata = templatefile("${path.module}/userdata_testvm.sh.tpl", {
    ovh_subnet   = var.network_config.regions[0].subnet
    azure_subnet = var.azure_subnet
    azure_ip     = var.azure_ip
    azure_psk    = var.azure_psk
  })
}

# =============================================================================
# Network — OVH private vRack network
# =============================================================================
module "network" {
  source         = "../modules/network/wrapper"
  cloud_provider = "ovh"
  network_name   = var.network_config.name
  project_id     = var.cloud_settings.ovh_project_id

  ovh_config = {
    vlan_id    = var.network_config.vlan_id
    no_gateway = var.network_config.no_gateway
    regions    = var.network_config.regions
  }
}

# =============================================================================
# Port — opret privat port eksplicit med port_security_enabled = false
# Undgår behov for security group rules (quota-problem) og tillader
# IPsec ESP-pakker igennem uden at OVH's port security dropper dem
# =============================================================================
resource "openstack_networking_port_v2" "vpn_private" {
  name                  = "${var.vm_config.name}-private-port"
  network_id            = module.network.network_id
  port_security_enabled = false

  fixed_ip {
    subnet_id = module.network.subnet_ids[var.network_config.regions[0].region]
  }

  depends_on = [module.network]
}

# =============================================================================
# Virtual Machine — OVH OpenStack instance
# =============================================================================
module "vm" {
  source         = "../modules/vm/wrapper"
  cloud_provider = "ovh"

  vm = {
    name      = var.vm_config.name
    size      = var.vm_config.size
    user_data = local.vm_userdata
  }

  ovh_config = {
    project_id    = var.cloud_settings.ovh_project_id
    image_name    = var.vm_config.image_name
    sshkey        = var.vm_config.sshkey
    network_names = local.public_network_names          # Kun Ext-Net via navn
    port_ids      = [openstack_networking_port_v2.vpn_private.id]  # Privat via port
    power_state   = var.vm_config.power_state
  }

  depends_on = [module.network, openstack_networking_port_v2.vpn_private]
}

# =============================================================================
# Port — client VM, kun privat netværk
# =============================================================================
resource "openstack_networking_port_v2" "client_private" {
  name                  = "client-vm-private-port"
  network_id            = module.network.network_id
  port_security_enabled = false

  fixed_ip {
    subnet_id = module.network.subnet_ids[var.network_config.regions[0].region]
  }

  depends_on = [module.network]
}

# =============================================================================
# Client VM — ingen public IP, router Azure-trafik via VPN VM
# =============================================================================
module "clientvm" {
  source         = "../modules/vm/wrapper"
  cloud_provider = "ovh"

  vm = {
    name = "client-vm"
    size = var.vm_config.size
    user_data = templatefile("${path.module}/userdata_client.sh.tpl", {
      azure_subnet   = var.azure_subnet
      vpn_private_ip = tolist(openstack_networking_port_v2.vpn_private.fixed_ip)[0].ip_address
    })
  }

  ovh_config = {
    project_id    = var.cloud_settings.ovh_project_id
    image_name    = var.vm_config.image_name
    port_ids      = [openstack_networking_port_v2.client_private.id]
    power_state   = var.vm_config.power_state
  }

  depends_on = [module.network, openstack_networking_port_v2.client_private]
}
