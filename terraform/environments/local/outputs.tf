output "vm_name" {
  value = libvirt_domain.vm.name
}

output "vm_ip" {
  value = data.libvirt_domain_interface_addresses.vm.interfaces
}
