variable "libvirt_uri" {
  type        = string
  default     = "qemu:///system"
  description = "Libvirt URI"
}

variable "pool_name" {
  type        = string
  default     = "default"
  description = "Libvirt storage pool name"
}

variable "vm_name" {
  type        = string
  default     = "tf-kvm-test-1"
  description = "VM name"
}

variable "memory_mb" {
  type        = number
  default     = 2048
  description = "RAM in MiB"
}

variable "vcpu_count" {
  type        = number
  default     = 2
  description = "vCPU count"
}

variable "disk_size_gb" {
  type        = number
  default     = 20
  description = "Disk size in GB"
}

variable "base_image_url" {
  type        = string
  default     = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  description = "Debian 12 cloud image URL"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key (for later SSH once networking works)"
  validation {
    condition     = fileexists(var.ssh_public_key_path)
    error_message = "ssh_public_key_path must point to an existing .pub file."
  }
}

variable "vm_user" {
  type        = string
  default     = "debian"
  description = "VM user"
}

# Optional console password so you can login in virt-manager even with no network
variable "enable_console_password" {
  type        = bool
  default     = true
  description = "If true, sets a simple console password via cloud-init"
}

variable "vm_password" {
  type        = string
  default     = "debian"
  description = "Console password (change later). Used only if enable_console_password=true"
  sensitive   = true
}

# Networking (ignored for IP retrieval — we won't wait for DHCP)
variable "libvirt_network_name" {
  type        = string
  default     = "default"
  description = "Libvirt network name (can be broken/inactive; we won't wait for lease)"
}
