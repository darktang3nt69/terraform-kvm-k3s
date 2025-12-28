terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # Legacy schema (matches source/base_volume_id/size/cloudinit/disk blocks)
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.1"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.2"
    }
  }
}
