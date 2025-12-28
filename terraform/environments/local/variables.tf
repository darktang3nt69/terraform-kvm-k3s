variable "libvirt_uri" {
  type        = string
  default     = "qemu:///system"
  description = "URI for the libvirt connection (e.g. qemu:///system for local)"
}

variable "pool_name" {
  type        = string
  default     = "default"
  description = "Libvirt storage pool name (commonly 'default')"
}

variable "vm_name" {
  type        = string
  default     = "k3s-worker-1"
  description = "Name of the Virtual Machine"
}

variable "memory_mb" {
  type        = number
  default     = 4096
  description = "RAM amount in MiB"
}

variable "vcpu_count" {
  type        = number
  default     = 2
  description = "Number of vCPUs"
}

variable "disk_size_gb" {
  type        = number
  default     = 30
  description = "Disk size in GB"
}

variable "base_image_url" {
  type        = string
  default     = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  description = "URL to the QCOW2 cloud image (Debian 12 Bookworm)"
}

variable "network_mode" {
  type        = string
  default     = "nat"
  description = "VM networking mode: nat (libvirt default network) or bridge (host br0)"
  validation {
    condition     = contains(["nat", "bridge"], var.network_mode)
    error_message = "network_mode must be either 'nat' or 'bridge'."
  }
}

variable "libvirt_network_name" {
  type        = string
  default     = "k3s-nat"
  description = "Libvirt network name when using NAT mode (usually 'default')."
}

variable "bridge_interface" {
  type        = string
  default     = "br0"
  description = "Name of the host bridge interface (when network_mode=bridge)"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the public SSH key to inject into the VM (e.g. ~/.ssh/id_ed25519.pub)"
  validation {
    condition     = fileexists(var.ssh_public_key_path)
    error_message = "ssh_public_key_path must point to an existing .pub file on disk."
  }
}

variable "vm_user" {
  type        = string
  default     = "debian"
  description = "Primary user to create inside the VM (Debian cloud images commonly use 'debian')"
}
