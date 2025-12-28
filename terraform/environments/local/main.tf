provider "libvirt" {
  uri = var.libvirt_uri
}

locals {
  ssh_pubkey = trimspace(file(var.ssh_public_key_path))

  password_lines = var.enable_console_password ? [
    "ssh_pwauth: true",
    "chpasswd:",
    "  expire: false",
    "  users:",
    "    - name: ${var.vm_user}",
    "      password: ${var.vm_password}",
  ] : []

  password_yaml = join("\n", local.password_lines)
}

# VM disk downloaded directly (NO backing file)
resource "libvirt_volume" "vm_disk" {
  count  = var.vm_count
  name   = "${var.vm_name}-${count.index}.qcow2"
  pool   = var.pool_name
  source = var.base_image_url
  format = "qcow2"
}

# Resize disk after download (qemu-img resize)
resource "null_resource" "resize_disk" {
  count = var.vm_count
  triggers = {
    disk_file = libvirt_volume.vm_disk[count.index].id
    size_gb   = tostring(var.disk_size_gb)
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      echo "Resizing disk: ${libvirt_volume.vm_disk[count.index].id} -> ${var.disk_size_gb}G"
      sudo qemu-img resize "${libvirt_volume.vm_disk[count.index].id}" ${var.disk_size_gb}G

      # Ensure qemu can read it (homelab mode)
      sudo chmod 0755 /var/lib/libvirt /var/lib/libvirt/images || true
      sudo setfacl -b "${libvirt_volume.vm_disk[count.index].id}" 2>/dev/null || true
      sudo chown root:root "${libvirt_volume.vm_disk[count.index].id}" || true
      sudo chmod 0644 "${libvirt_volume.vm_disk[count.index].id}" || true

      sudo ls -l "${libvirt_volume.vm_disk[count.index].id}" || true
    EOT
  }
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  count = var.vm_count
  name  = "${var.vm_name}-${count.index}-cloudinit.iso"
  pool  = var.pool_name

  user_data = templatefile("${path.module}/cloud_init.cfg", {
    hostname       = "${var.vm_name}-${count.index}"
    vm_user        = var.vm_user
    ssh_public_key = local.ssh_pubkey
    password_yaml  = local.password_yaml
  })

  network_config = templatefile("${path.module}/network_config.cfg", {
    ip_address = var.vm_ips[count.index]
    gateway    = var.gateway
    nameserver = var.nameserver
  })

  meta_data = <<-EOF
    instance-id: ${var.vm_name}-${count.index}
    local-hostname: ${var.vm_name}-${count.index}
  EOF
}

resource "libvirt_domain" "vm" {
  count      = var.vm_count
  depends_on = [null_resource.resize_disk]

  name   = "${var.vm_name}-${count.index}"
  type   = "kvm"
  memory = var.memory_mb
  vcpu   = var.vcpu_count

  cloudinit = libvirt_cloudinit_disk.cloudinit[count.index].id

  disk {
    volume_id = libvirt_volume.vm_disk[count.index].id
  }

  # Keep NIC, but DO NOT wait for DHCP lease (prevents terraform timeout)
  network_interface {
    network_name   = var.libvirt_network_name
    wait_for_lease = false
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "none"
  }
}
