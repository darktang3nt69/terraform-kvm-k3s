# KVM + k3s Homelab Infrastructure

This repository contains the Terraform configuration and documentation for a local Kubernetes homelab running on Pop!_OS using KVM/libvirt and k3s.

## High-Level Architecture

Methods and tools used to achieve the infrastructure goals:

- **Host OS**: Pop!_OS (acting as the Hypervisor and k3s Control Plane).
- **Virtualization**: KVM + libvirt (managed via Terraform).
- **Container Orchestration**: k3s (Lightweight Kubernetes).
- **Networking**: Bridged networking (VMs are on the same L2 network as the host).
- **Infrastructure as Code**: Terraform (managing VM lifecycle, DNS/DHCP entries in libvirt).

## Setup Overview

Detailed design decisions can be found in [docs/design.md](docs/design.md).

### Automated vs. Manual

- **Automated (Terraform)**:
    - Creation of KVM Virtual Machines.
    - Configuration of libvirt resources (volumes, networks if needed).
    - IP allocation (via DHCP/cloud-init handled by libvirt/Terraform).
    - *Future*: DNS records.

- **Manual (for now)**:
    - Installation of k3s on the Host (Control Plane).
    - Joining Worker Nodes (VMs) to the cluster.
    - OS-level bridge configuration on the host.

### Intentionally NOT Automated

- **Host OS Setup**: We assume the host is already running Pop!_OS with necessary virtualization packages installed.
- **Complex Overlays**: We stick to simple bridged networking for simplicity and performance locally.

## Directory Structure

```
├── docs/                       # Architectural documentation
├── terraform/
│   ├── environments/
│   │   └── local/              # Main environment for local laptop
│   └── modules/                # Reusable Terraform modules (currently empty)
└── README.md
```

## Prerequisites

1. **Pop!_OS / Linux** with KVM support.
2. **libvirt** and `virt-manager` installed.
3. **Terraform** installed.
4. **k3s** installed on the host (acting as server).

## Getting Started

Navigate to the local environment:

```bash
cd terraform/environments/local
# terraform init
# terraform plan
```
