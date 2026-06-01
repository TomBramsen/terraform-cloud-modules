######################################
###           Outputs              ###
######################################

output "vm_name" {
  description = "The name of the created virtual machine"
  value       = local.is_windows ? one(openstack_compute_instance_v2.VMWindows[*].name) : one(openstack_compute_instance_v2.VMLinux[*].name)
}

output "vm_ip" {
  description = "The primary IPv4 address of the virtual machine"
  value       = local.is_windows ? one(openstack_compute_instance_v2.VMWindows[*].access_ip_v4) : one(openstack_compute_instance_v2.VMLinux[*].access_ip_v4)
}

output "public_ip" {
  description = "Den offentlige IP-adresse tildelt fra Ext-Net"
  value       = local.is_windows ? one([for net in flatten(openstack_compute_instance_v2.VMWindows[*].network) : net.fixed_ip_v4 if net.name == "Ext-Net"]) : one([for net in flatten(openstack_compute_instance_v2.VMLinux[*].network) : net.fixed_ip_v4 if net.name == "Ext-Net"])
}
