# design.md - Architectural Decisions

This document outlines the reasoning behind the infrastructure choices for this local homelab.

## 1. Why KVM instead of Docker/Kind/Minikube?

While Docker-based solutions like Kind or k3d are excellent for pure application development, this homelab aims to simulate a "real" infrastructure environment.

- **VM Isolation**: KVM provides strong isolation, mimicking bare-metal or cloud instances more closely than containers.
- **Networking**: VMs allow us to test real networking scenarios (bridging, separate IPs) that are harder to replicate cleanly with Docker networking hacks.
- **Resource Management**: explicit CPU/Memory allocation per node.
- **Learning**: Gaining experience with `libvirt` and Terraform's interaction with hypervisors.

## 2. Why Bridged Networking?

We use a bridged network where VMs connect directly to the host's physical network (or a software bridge interacting with it).

- **Simplicity**: VMs get their own IP addresses on the LAN (or host-only subnets that feel "real").
- **Accessibility**: No need for port forwarding to access services running inside the cluster; we can access them via their LAN IP.
- **MetalLB Support**: Bridged networking makes Layer 2 Load Balancing with MetalLB trivial, as it relies on ARP/NDP updates on the local segment.

## 3. Why Host as Control Plane?

Typically, control planes run in isolation. However, to save resources on a single laptop:

- **Resource Efficiency**: The host is already running and powerful. Running the CP in a VM wastes RAM on effective "overhead" (kernel, OS processes).
- **Simplicity**: The host is the "bastion" of this setup.
- **k3s Footprint**: k3s is extremely lightweight. Running the server process on the host is negligible.

## 4. Terraform Scope Boundaries

Terraform is strictly for **Infrastructure Provisioning**.

- **IN SCOPE**:
    - Defining VM specs (vCPU, RAM, Disk).
    - defining Cloud-init user data (bootstrapping SSH keys, hostnames).
    - Managing libvirt storage pools and network definitions.

- **OUT OF SCOPE**:
    - Application deployment (Helm/ArgoCD will handle this later).
    - K3s installation inside the VMs (Ansible or manual scripts will handle this initially, or cloud-init).
    - Host OS configuration.
