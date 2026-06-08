output "network_id" {
  description = "ID of the private network"
  value       = module.network.network_id
}

output "network_name" {
  description = "Name of the private network"
  value       = module.network.network_name
}

output "subnet_ids" {
  description = "Map of region to subnet ID"
  value       = module.network.subnet_ids
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = module.vm.vm_name
}

output "vm_private_ip" {
  description = "Private IP of the VM on the vRack network"
  value       = module.vm.vm_ip
}

output "vm_public_ip" {
  description = "Public IP of the VM via Ext-Net (null if public_net = false)"
  value       = module.vm.public_ip
}

output "ssh_private_key" {
  description = "Generated SSH private key — only set when no sshkey was provided"
  value       = module.vm.ssh_private_key
  sensitive   = true
}

output "client_vm_private_ip" {
  description = "Private IP of the client VM on the vRack network"
  value       = module.clientvm.vm_ip
}

output "client_ssh_private_key" {
  description = "Generated SSH private key for client VM"
  value       = module.clientvm.ssh_private_key
  sensitive   = true
}
