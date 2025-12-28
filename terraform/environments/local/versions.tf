terraform {
  required_version = ">= 1.5.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.7.1"
    }
  }
}

provider "libvirt" {
  # connect to the local system (Pop!_OS)
  uri = "qemu:///system"
}
