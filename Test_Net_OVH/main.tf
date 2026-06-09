/*
Apply and force scripts to be re-run:

terraform apply \
  -replace="module.vm.module.ovh[0].openstack_compute_instance_v2.VMLinux[0]" \
  -replace="module.clientvm.module.ovh[0].openstack_compute_instance_v2.VMLinux[0]" \
  -auto-approve

*/


locals {
  # user_data is computed here — templatefile() and variable references are not
  # allowed in variable defaults, so we do it in locals instead
  vm_userdata = templatefile("${path.module}/userdata_testvm.sh.tpl", {
    ovh_subnet   = var.network_config.regions[0].subnet
    azure_subnet = var.azure_subnet
    azure_ip     = var.azure_ip
    azure_psk    = var.azure_psk
    dns_servers  = join(" ", var.dns_servers)
  })

  # ip_address is null during plan (DHCP-assigned, only known after port creation).
  # The for-expression filters out nulls — try() catches the empty-list error and returns "".
  client_userdata = templatefile("${path.module}/userdata_client.sh.tpl", {
    azure_subnet   = var.azure_subnet
    vpn_private_ip = var.vm_config.private_ip
    dns_servers    = join(" ", var.dns_servers)
  })
}

# =============================================================================
# Network — OVH private vRack network
# =============================================================================
module "network" {
  source = "../modules/network/network/wrapper"

  network = {
    name = var.network_config.name

    ovh = {
      project_id = var.cloud_settings.ovh_project_id
      vlan_id    = var.network_config.vlan_id
      regions    = var.network_config.regions
    }
  }
}

# =============================================================================
# Port — create private port explicitly with port_security_enabled = false
# Avoids the need for security group rules (quota issue) and allows
# IPsec ESP packets through without OVH port security dropping them
# =============================================================================
resource "openstack_networking_port_v2" "vpn_private" {
  name                  = "${var.vm_config.name}-private-port"
  network_id            = module.network.network_id
  port_security_enabled = false

  fixed_ip {
    subnet_id  = module.network.subnet_ids[var.network_config.regions[0].region]
    ip_address = var.vm_config.private_ip
  }

  depends_on = [module.network]
}

# =============================================================================
# Router — connects the private subnet to Ext-Net so floating IPs work
# =============================================================================
data "openstack_networking_network_v2" "ext_net" {
  name = "Ext-Net"
}

resource "openstack_networking_router_v2" "router" {
  count               = var.vm_config.public_net ? 1 : 0
  name                = "${var.network_config.name}-router"
  external_network_id = data.openstack_networking_network_v2.ext_net.id
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  count      = var.vm_config.public_net ? 1 : 0
  router_id  = openstack_networking_router_v2.router[0].id
  subnet_id  = module.network.subnet_ids[var.network_config.regions[0].region]
  depends_on = [module.network]
}

# =============================================================================
# Public IP — either look up an existing reserved floating IP or allocate a new one.
# Set vm_config.existing_fip_address to reuse a previously reserved IP.
# =============================================================================
data "openstack_networking_floatingip_v2" "vpn_fip" {
  count   = var.vm_config.public_net && var.vm_config.existing_fip_address != null ? 1 : 0
  address = var.vm_config.existing_fip_address
}

module "public_ip" {
  count  = var.vm_config.public_net && var.vm_config.existing_fip_address == null ? 1 : 0
  source = "../modules/network/public-ip/wrapper"

  public_ip = {
    name            = "${var.vm_config.name}-fip"
    location        = var.cloud_settings.region
    resource_group  = "vpn"
    tags            = var.tags
    ovh             = {}
    prevent_destroy = true
  }
}

locals {
  fip_address = var.vm_config.existing_fip_address != null ? data.openstack_networking_floatingip_v2.vpn_fip[0].address : module.public_ip[0].ip_address
}

# Associate floating IP with the VPN VM's private port
resource "openstack_networking_floatingip_associate_v2" "vpn_fip" {
  count       = var.vm_config.public_net ? 1 : 0
  floating_ip = local.fip_address
  port_id     = openstack_networking_port_v2.vpn_private.id
  depends_on  = [openstack_networking_router_interface_v2.router_interface]
}

# =============================================================================
# Virtual Machine — OVH OpenStack instance - For VPN Connection
# =============================================================================
module "vm" {
  source = "../modules/vm/wrapper"

  vm = {
    name           = var.vm_config.name
    size           = var.vm_config.size
    location       = var.cloud_settings.region
    resource_group = "vpn"
    user_data      = local.vm_userdata
    ssh_public_key = var.vm_config.ssh_public_key
    tags           = var.tags

    ovh = {
      project_id      = var.cloud_settings.ovh_project_id
      image_name      = var.vm_config.image_name
      port_ids        = [openstack_networking_port_v2.vpn_private.id]
      power_state     = var.vm_config.power_state
      security_groups = []
    }
  }

  depends_on = [
    module.network,
    openstack_networking_port_v2.vpn_private,
    openstack_networking_router_interface_v2.router_interface,
    openstack_networking_floatingip_associate_v2.vpn_fip,
  ]
}

# =============================================================================
# Port — client VM, private network only
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
# Client VM — no public IP, routes Azure traffic via VPN VM
# =============================================================================
module "clientvm" {
  source = "../modules/vm/wrapper"

  vm = {
    name           = "client-vm"
    size           = var.vm_config.size
    location       = var.cloud_settings.region
    resource_group = "client"
    user_data      = local.client_userdata
    tags           = var.tags

    ovh = {
      project_id      = var.cloud_settings.ovh_project_id
      image_name      = var.vm_config.image_name
      port_ids        = [openstack_networking_port_v2.client_private.id]
      power_state     = var.vm_config.power_state
      security_groups = []
    }
  }

  depends_on = [module.network, openstack_networking_port_v2.client_private]
}
