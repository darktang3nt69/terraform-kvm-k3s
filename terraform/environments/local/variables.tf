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

variable "vm_count" {
  type        = number
  default     = 2
  description = "Number of VMs to provision"
}

variable "vm_name" {
  type        = string
  default     = "k3s-node"
  description = "Base name for the VMs"
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

# Networking
variable "libvirt_network_name" {
  type        = string
  default     = "br0"
  description = "Libvirt network name"
}

variable "vm_ips" {
  type        = list(string)
  default     = ["192.168.1.16", "192.168.1.17"]
  description = "List of static IPs for the VMs"
}

variable "gateway" {
  type        = string
  default     = "192.168.1.1"
  description = "Default gateway"
}

variable "nameserver" {
  type        = string
  default     = "1.1.1.1"
  description = "DNS nameserver"
}
