module "ovh" {
  count  = var.cloud_provider == "ovh" ? 1 : 0
  source = "../ovh"

  ovh_project_id = try(var.ovh_config.project_id, "")

  vm = {
    name          = var.vm.name
    size          = var.vm.size
    image_name    = try(var.ovh_config.image_name, "")
    sshkey        = try(var.ovh_config.sshkey, null)
    admin_pass    = var.vm.admin_pass
    network_names = try(var.ovh_config.network_names, [])
    power_state   = try(var.ovh_config.power_state, "active")
    user_data     = var.vm.user_data
  }
}

module "azure" {
  count  = var.cloud_provider == "azure" ? 1 : 0
  source = "../azure"

  vm = {
    name             = var.vm.name
    size             = var.vm.size
    location         = try(var.azure_config.location, "")
    resource_group   = try(var.azure_config.resource_group, "")
    os_type          = try(var.azure_config.os_type, "Linux")
    admin_username   = try(var.azure_config.admin_username, "azureuser")
    admin_pass       = var.vm.admin_pass
    ssh_public_key   = try(var.azure_config.ssh_public_key, null)
    subnet_id        = try(var.azure_config.subnet_id, "")
    create_public_ip = try(var.azure_config.create_public_ip, false)
    user_data        = var.vm.user_data
    image            = try(var.azure_config.image, { publisher = "", offer = "", sku = "", version = "latest" })
  }
}
