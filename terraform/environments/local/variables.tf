variable "libvirt_uri" {
  type        = string
  default     = "qemu:///system"
  description = "URI for the libvirt connection"
}

variable "base_image_url" {
  type        = string
  description = "URL or path to the source cloud image (e.g. Ubuntu 22.04 or Debian 12)"
  # Example: "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

variable "node_count" {
  type        = number
  default     = 2
  description = "Number of worker node VMs to provision"
}

variable "memory_per_node" {
  type        = number
  default     = 2048
  description = "RAM per node in MiB"
}

variable "vcpu_per_node" {
  type        = number
  default     = 2
  description = "vCPUs per node"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key to inject into VMs via cloud-init"
}
