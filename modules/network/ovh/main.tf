# Create the private vRack network across the selected regions
# - Remember : Only one network per vlan
resource "ovh_cloud_project_network_private" "net" {
  service_name = var.ovh_project_id
  name         = var.network_name
  vlan_id      = var.vlan_id
  regions = [
    for r in var.regions : r.region
  ]
}

# Create subnets in the respective regions
resource "ovh_cloud_project_network_private_subnet" "subnet" {
  for_each = {
    for r in var.regions : r.region => r
  }
  service_name = var.ovh_project_id
  network_id   = ovh_cloud_project_network_private.net.id

  region  = each.value.region
  network = each.value.subnet


  start = cidrhost(each.value.subnet, each.value.ip_allocation_start) 
  end   = cidrhost(each.value.subnet, each.value.ip_allocation_stop) 

  dhcp       = each.value.dhcp
  no_gateway = false

}