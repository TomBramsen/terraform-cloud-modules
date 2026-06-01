locals {
  is_windows     = can(regex("(?i)windows", var.vm.image_name))
  create_ssh_key = var.vm.sshkey == null && !local.is_windows
}

######################################
###          SSH Key Section       ###
######################################

resource "tls_private_key" "ssh_key" {
  count     = local.create_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "openstack_compute_keypair_v2" "default" {
  count      = local.create_ssh_key ? 1 : 0
  name       = "${var.vm.name}-generated-key"
  public_key = trimspace(tls_private_key.ssh_key[0].public_key_openssh)
}

resource "ovh_cloud_project_ssh_key" "default" {
  count        = local.create_ssh_key ? 1 : 0
  service_name = var.ovh_project_id
  name         = "${var.vm.name}-generated-key"
  public_key   = trimspace(tls_private_key.ssh_key[0].public_key_openssh)
}


######################################
###          Generate VMs          ###
######################################

# Linux VM
resource "openstack_compute_instance_v2" "VMLinux" {
  count           = local.is_windows ? 0 : 1
  name            = var.vm.name
  flavor_name     = var.vm.size
  image_name      = var.vm.image_name
  key_pair        = local.create_ssh_key ? ovh_cloud_project_ssh_key.default[0].name : var.vm.sshkey
  security_groups = ["default"]
  power_state     = var.vm.power_state
  user_data       = var.vm.user_data

  dynamic "network" {
    for_each = var.vm.network_names
    content {
      name = network.value
    }
  }

  lifecycle {
    ignore_changes = [image_name]
    precondition {
      condition     = !local.is_windows || var.vm.admin_pass != null
      error_message = "admin_pass must be set for Windows VMs."
    }
  }

  depends_on = [ovh_cloud_project_ssh_key.default]
}

# Windows VM
resource "openstack_compute_instance_v2" "VMWindows" {
  count           = local.is_windows ? 1 : 0
  name            = var.vm.name
  flavor_name     = var.vm.size
  image_name      = var.vm.image_name
  admin_pass      = var.vm.admin_pass
  security_groups = ["default"]
  power_state     = var.vm.power_state

  dynamic "network" {
    for_each = var.vm.network_names
    content {
      name = network.value
    }
  }

  lifecycle {
    ignore_changes = [image_name]
    precondition {
      condition     = var.vm.admin_pass != null
      error_message = "admin_pass must be set for Windows VMs."
    }
  }
}
