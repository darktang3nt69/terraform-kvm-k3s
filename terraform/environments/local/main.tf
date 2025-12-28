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
  name   = "${var.vm_name}.qcow2"
  pool   = var.pool_name
  source = var.base_image_url
  format = "qcow2"
}

# Resize disk after download (qemu-img resize)
resource "null_resource" "resize_disk" {
  triggers = {
    disk_file = libvirt_volume.vm_disk.id  # in your provider version, id is the file path
    size_gb   = tostring(var.disk_size_gb)
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      echo "Resizing disk: ${libvirt_volume.vm_disk.id} -> ${var.disk_size_gb}G"
      sudo qemu-img resize "${libvirt_volume.vm_disk.id}" ${var.disk_size_gb}G

      # Ensure qemu can read it (homelab mode)
      sudo chmod 0755 /var/lib/libvirt /var/lib/libvirt/images || true
      sudo setfacl -b "${libvirt_volume.vm_disk.id}" 2>/dev/null || true
      sudo chown root:root "${libvirt_volume.vm_disk.id}" || true
      sudo chmod 0644 "${libvirt_volume.vm_disk.id}" || true

      sudo ls -l "${libvirt_volume.vm_disk.id}" || true
    EOT
  }
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name = "${var.vm_name}-cloudinit.iso"
  pool = var.pool_name

  user_data = <<-EOF
    #cloud-config
    hostname: ${var.vm_name}
    manage_etc_hosts: true

    users:
      - name: ${var.vm_user}
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: users, admin
        home: /home/${var.vm_user}
        shell: /bin/bash
        ssh-authorized-keys:
          - ${local.ssh_pubkey}

    ${local.password_yaml}

    package_update: false
    package_upgrade: false

    packages:
      - qemu-guest-agent
      - curl

    runcmd:
      - systemctl enable --now qemu-guest-agent
      - echo "cloud-init done" > /var/log/cloud-init-done.txt
  EOF

  meta_data = <<-EOF
    instance-id: ${var.vm_name}
    local-hostname: ${var.vm_name}
  EOF
}

resource "libvirt_domain" "vm" {
  depends_on = [null_resource.resize_disk]

  name   = var.vm_name
  type   = "kvm"
  memory = var.memory_mb
  vcpu   = var.vcpu_count

  cloudinit = libvirt_cloudinit_disk.cloudinit.id

  disk {
    volume_id = libvirt_volume.vm_disk.id
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
