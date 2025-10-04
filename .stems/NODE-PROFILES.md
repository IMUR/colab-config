# Colab Cluster Node Profiles

**Last Updated:** 2025-09-30

## Overview

This document provides quick-reference hardware and configuration profiles for all nodes in the colab cluster system, including both prime nodes (core cluster) and satellite nodes (remote/specialized systems).

## Network Topology

- **Subnet:** 192.168.254.0/24
- **Prime Nodes:** .10, .20, .30 (static)
- **Gateway:** cooperator (192.168.254.10)
- **Access:** Cockpit available on all prime nodes

---

## Prime Nodes (Debian Trixie Cluster)

### Cooperator (crtr)
- **Hostname:** cooperator / cooperator.local
- **User:** crtr
- **IP:** 192.168.254.10/24
- **Hardware:** Raspberry Pi 5 (BCM2712)
- **CPU:** 4-core @ 2.40 GHz (ARM64/aarch64)
- **GPU:** Mesa llvmpipe (software rendering)
- **Memory:** 16 GB (15.84 GiB usable)
- **Storage:** 91 GB (ext4)
- **Role:** Gateway/Coordinator, NFS Server, Network Services
- **OS:** Debian 13 (Trixie) aarch64
- **Kernel:** 6.12.47+rpt-rpi-2712
- **Shell:** zsh 5.9
- **Management:** Chezmoi + Ansible (via colab-config)
- **Notable:** Primary cluster coordinator, NAS mount point at /cluster-nas

### Projector (prtr)
- **Hostname:** projector / projector.local
- **User:** prtr
- **IP:** 192.168.254.20/24
- **Hardware:** Custom desktop build
- **CPU:** Intel Core i9-9900X (20-core @ 4.50 GHz)
- **GPUs:** 4x NVIDIA
  - 2x GeForce GTX 1080
  - 2x GeForce GTX 970
- **Memory:** 126 GB (125.50 GiB usable)
- **Swap:** 49 GB (unused)
- **Storage:** 888 GB (ext4)
- **Role:** Multi-GPU Compute Powerhouse, Heavy Parallel Processing
- **OS:** Debian 13 (Trixie) x86_64
- **Kernel:** 6.12.48+deb13-amd64
- **Shell:** zsh 5.9
- **Packages:** 2104 (dpkg)
- **Management:** Chezmoi + Ansible (via colab-config)
- **Notable:** Primary GPU compute node, highest memory capacity

### Director (drtr)
- **Hostname:** director / director.local
- **User:** drtr
- **IP:** 192.168.254.30/24
- **Hardware:** P7xxTM1 Mobile Workstation
- **CPU:** Intel Core i9-9900K (16-core @ 5.00 GHz)
- **GPU:** NVIDIA GeForce RTX 2080 Mobile
- **Memory:** 63 GB (62.75 GiB usable)
- **Swap:** 49 GB (unused)
- **Storage:** 888 GB (ext4)
- **Role:** ML Platform, Portable Heavy Lifter, Development Workstation
- **OS:** Debian 13 (Trixie) x86_64
- **Kernel:** 6.12.48+deb13-amd64
- **Shell:** zsh 5.9
- **Packages:** 1715 (dpkg)
- **Management:** Chezmoi + Ansible (via colab-config)
- **Notable:** Mobile form factor with desktop-class performance

---

## Satellite Nodes

### Terminator (trtr)
- **Hostname:** terminator
- **User:** trtr
- **IP:** 192.168.254.40/24 (Static - WiFi)
- **MAC Address:** 2c:ca:16:81:44:7b (en0)
- **Hardware:** MacBook Air (2024)
- **CPU:** Apple M4 (10-core CPU + GPU)
- **Memory:** 24 GB unified
- **Storage:** 500 GB SSD (~59 GB used, 441 GB available)
- **Role:** Remote Terminal, Mobile Access Point
- **OS:** macOS 15.7 Sequoia (Build 24G222)
- **Shell:** zsh (macOS default)
- **Management:** Independent (trtr-config repository)
- **Access Method:** Claude Desktop, SSH to prime nodes
- **Notable:** First Apple device in system, latest M4 chip, not synced with colab-config. Now on local network with static IP.

### Other Network Devices

Additional devices detected on 192.168.254.0/24 network:
- **barter** - 192.168.254.123 (Static)
- **transmitter** - 192.168.254.96 (Static)
- **Unknown** - 192.168.254.11 (Static)

*Note: Roles and specifications for these devices to be documented as needed.*

---

## Configuration Management

### Prime Nodes
- **Repository:** `/cluster-nas/colab/colab-config`
- **Method:** Hybrid Chezmoi (user configs) + Ansible (system configs)
- **Sync:** Shared NFS storage, Git-based
- **Scope:** Identical base configuration across all three nodes

### Satellite Nodes
- **Terminator (trtr):** Independent `trtr-config` repository
  - macOS-specific configurations
  - No Chezmoi/Ansible sync with prime nodes
  - Maintains separate toolchain and environment

### Future Considerations
- Potential split of node-specific configs into separate repos (crtr-config, prtr-config, drtr-config)
- Currently out of scope but documented for future reference

---

## Quick Reference

| Node | Hostname | IP | User | CPU Cores | RAM | GPUs | Role |
|------|----------|-----|------|-----------|-----|------|------|
| Cooperator | cooperator | .10 | crtr | 4 | 16GB | - | Gateway |
| Projector | projector | .20 | prtr | 20 | 126GB | 4x NVIDIA | Compute |
| Director | director | .30 | drtr | 16 | 63GB | 1x RTX 2080 | ML Platform |
| Terminator | terminator | .40 | trtr | 10 (M4) | 24GB | M4 GPU | Remote Terminal |

---

## Access Patterns

### From Terminator (Local Network)
```bash
# SSH to prime nodes directly
ssh crtr@192.168.254.10  # Cooperator
ssh prtr@192.168.254.20  # Projector  
ssh drtr@192.168.254.30  # Director

# Or using hostnames (if DNS/hosts configured)
ssh crtr@cooperator.local
ssh prtr@projector.local
ssh drtr@director.local

# Cockpit web interface
https://192.168.254.10:9090  # Cooperator
https://192.168.254.20:9090  # Projector
https://192.168.254.30:9090  # Director
```

### Between Prime Nodes
```bash
# Direct SSH (internal network)
ssh prtr  # From any node to Projector
ssh drtr  # From any node to Director
ssh crtr  # From any node to Cooperator
```

---

## Update History

- **2025-09-30:** Initial profile creation with three prime nodes + Terminator satellite
- **2025-09-30:** Completed Terminator hardware specs (M4 MacBook Air, 24GB RAM, 500GB SSD, macOS 15.7 Sequoia)
- **2025-10-02:** Updated Terminator with static IP assignment (192.168.254.40) on local network
