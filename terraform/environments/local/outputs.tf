output "vm_name" {
  value = libvirt_domain.vm.name
}

# In NAT mode, libvirt usually reports the DHCP IP.
# In bridge mode, this may be null (router DHCP not visible to libvirt).
output "vm_ip" {
  value = try(libvirt_domain.vm.network_interface[0].addresses[0], null)
}
