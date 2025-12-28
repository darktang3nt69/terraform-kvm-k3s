provider "libvirt" {
  uri = var.libvirt_uri
}

locals {
  ssh_pubkey      = trimspace(file(var.ssh_public_key_path))
  disk_size_bytes = var.disk_size_gb * 1024 * 1024 * 1024
  wait_for_lease  = var.network_mode == "nat"
}

# 1. Base Image: Use a dedicated name to avoid collisions
resource "libvirt_volume" "base_image" {
  name = "debian-12-base-template.qcow2"
  pool = var.pool_name
  
  create = {
    content = {
      url = var.base_image_url
    }
  }
  
  target = {
    format = {
      type = "qcow2"
    }
  }
}

# 2. VM Disk: Layered on top of the base image
resource "libvirt_volume" "vm_disk" {
  name = "${var.vm_name}-disk.qcow2"
  pool = var.pool_name
  
  backing_store = {
    path = libvirt_volume.base_image.id
  }
  
  capacity = local.disk_size_bytes
  
  target = {
    format = {
      type = "qcow2"
    }
  }
}

# 3. Cloud-Init
resource "libvirt_cloudinit_disk" "cloudinit" {
  name = "${var.vm_name}-cloudinit.iso"
  # pool argument unsupported in 0.9.1 validation for cloudinit usually, relying on default or implicit
  
  user_data = templatefile("${path.module}/cloud_init.cfg", {
    vm_name        = var.vm_name
    vm_user        = var.vm_user
    hostname       = var.vm_name
    ssh_public_key = local.ssh_pubkey
  })
  
  meta_data = ""
}

# 4. The Domain (VM)
resource "libvirt_domain" "vm" {
  name   = var.vm_name
  type   = "kvm"
  memory = var.memory_mb
  vcpu   = var.vcpu_count

  cpu = {
    mode = "host-passthrough"
  }

  os = {
    type = "hvm"
  }

  devices = {
    disk = [
      {
        volume_id = libvirt_volume.vm_disk.id
      },
      {
        volume_id = libvirt_cloudinit_disk.cloudinit.id
        target = {
            dev = "sda"
        }
      }
    ]

    interface = [
      {
        network_name   = var.network_mode == "nat" ? var.libvirt_network_name : null
        bridge         = var.network_mode == "bridge" ? var.bridge_interface : null
        wait_for_lease = local.wait_for_lease
      }
    ]

    console = [
      {
        type        = "pty"
        target_type = "serial"
        target_port = "0"
      }
    ]
  }
}

# Data source to fetch IP addresses
data "libvirt_domain_interface_addresses" "vm" {
  domain = libvirt_domain.vm.id
  source = "lease"

}