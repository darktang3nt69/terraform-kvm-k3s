output "vm_names" {
  value = libvirt_domain.vm[*].name
}

# In NAT mode, libvirt usually reports the DHCP IP.
# In bridge mode, this may be null (router DHCP not visible to libvirt).
output "vm_ips" {
  value = var.vm_ips
}
