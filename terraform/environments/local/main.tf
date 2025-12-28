# Main Terraform Configuration for Local Homelab
# ===============================================

# NOTE: This is currently a SKELETON file. 
# Actual resource logic will be implemented in future steps.

# -------------------------------------------------------------
# 1. Network Configuration
# -------------------------------------------------------------
# We will define a libvirt network here.
# For now, we assume bridged networking or use the functional default 'default' network.

# resource "libvirt_network" "k3s_net" {
#   name = "k3s_net"
#   ...
# }


# -------------------------------------------------------------
# 2. Storage Pool
# -------------------------------------------------------------
# Define where VM disk images are stored on the host.

# resource "libvirt_pool" "cluster_pool" {
#   name = "k3s_pool"
#   type = "dir"
#   path = "/var/lib/libvirt/images/k3s-cluster"
# }


# -------------------------------------------------------------
# 3. Base OS Image
# -------------------------------------------------------------
# We will check only one Base Volume (e.g. from a cloud image)

# resource "libvirt_volume" "os_image" {
#   name   = "ubuntu-base.qcow2"
#   pool   = libvirt_pool.cluster_pool.name
#   source = var.base_image_url
#   format = "qcow2"
# }


# -------------------------------------------------------------
# 4. Cloud-Init Configuration
# -------------------------------------------------------------
# To bootstrap keys and hostname.

# data "template_file" "user_data" {
#   template = file("${path.module}/cloud_init.cfg")
# }

# resource "libvirt_cloudinit_disk" "commoninit" {
#   name      = "commoninit.iso"
#   user_data = data.template_file.user_data.rendered
#   pool      = libvirt_pool.cluster_pool.name
# }


# -------------------------------------------------------------
# 5. Virtual Machines (K3s Worker Nodes)
# -------------------------------------------------------------
# Iterate over a variable map to create multiple VMs

# resource "libvirt_domain" "k3s_node" {
#   count = var.node_count
#   
#   name   = "k3s-worker-${count.index}"
#   memory = var.memory_per_node
#   vcpu   = var.vcpu_per_node
#   
#   network_interface {
#     network_name = "default" 
#     # bridge = "br0" # Future bridged setup
#   }
#
#   disk {
#     volume_id = libvirt_volume.node_disk[count.index].id
#   }
#   
#   cloudinit = libvirt_cloudinit_disk.commoninit.id
#
#   console {
#     type        = "pty"
#     target_port = "0"
#     target_type = "serial"
#   }
# }
