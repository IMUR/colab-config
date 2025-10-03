---
title: "Network Topology"
description: "Co-lab cluster network architecture and connectivity design"
version: "1.0"
date: "2025-09-27"
category: "architecture"
tags: ["network", "topology", "dns", "nfs", "security"]
applies_to: ["all_nodes"]
related:
  - "CLUSTER-ARCHITECTURE.md"
  - "HYBRID-STRATEGY.md"
  - "../guides/SERVICE-MANAGEMENT.md"
---

# Network Topology

## Executive Summary

The Co-lab cluster implements a **3-node private network architecture** designed for high availability, shared storage, and specialized workload distribution. The network topology provides secure internal connectivity while enabling controlled external access through a dedicated gateway node.

## Network Architecture Overview

### Primary Network: 192.168.254.0/24

**Network Design:**
- **Subnet**: 192.168.254.0/24 (254 available addresses)
- **Gateway**: cooperator (192.168.254.10)
- **DNS**: Pi-hole on cooperator (.ism.la domain)
- **NFS**: Shared storage from cooperator
- **Inter-node**: Direct SSH connectivity using ed25519 keys

### Node Network Assignments

| Node | Hostname | IP Address | Role | Network Function |
|------|----------|------------|------|------------------|
| crtr | cooperator | 192.168.254.10 | Gateway | Internet gateway, DNS, NFS server |
| prtr | projector | 192.168.254.20 | Compute | High-performance compute workloads |
| drtr | director | 192.168.254.30 | ML Platform | Machine learning and inference |

## Gateway Node (cooperator) Network Services

### External Connectivity

**Internet Gateway Functions:**
- **Public IP**: Via cooperator gateway
- **Port Forwarding**: 22 (SSH), 80 (HTTP), 443 (HTTPS)
- **Web Services**: Proxied through Caddy on cooperator
- **Remote Access**: SSH jump host through cooperator

**Caddy Reverse Proxy Configuration:**
```caddyfile
# External web services routing
*.ism.la {
    tls internal
    reverse_proxy {
        to projector:8080 director:3000
        health_path /health
        health_interval 30s
    }
}

# Archon services
archon.ism.la {
    reverse_proxy projector:8181
}

# Monitoring services
monitor.ism.la {
    reverse_proxy cooperator:9090
}
```

### Internal DNS Services (Pi-hole)

**DNS Configuration:**
- **Domain**: .ism.la (internal cluster domain)
- **Upstream**: 1.1.1.1, 8.8.8.8 (Cloudflare, Google)
- **Ad Blocking**: Pi-hole filtering enabled
- **Local Records**: Cluster node resolution

**Internal DNS Records:**
```dns
cooperator.ism.la    -> 192.168.254.10
projector.ism.la     -> 192.168.254.20
director.ism.la      -> 192.168.254.30

# Service aliases
gateway.ism.la       -> 192.168.254.10
compute.ism.la       -> 192.168.254.20
ml.ism.la            -> 192.168.254.30

# Application services
archon.ism.la        -> 192.168.254.20
pihole.ism.la        -> 192.168.254.10
```

### Network File System (NFS)

**NFS Server Configuration:**
- **Server**: cooperator (192.168.254.10)
- **Export Path**: `/cluster-nas`
- **Mount Point**: `/cluster-nas` on all nodes
- **Permissions**: 777/666 (world-writable for application compatibility)
- **Protocol**: NFSv4 with Kerberos authentication

**NFS Exports (/etc/exports):**
```nfs
/cluster-nas 192.168.254.0/24(rw,sync,no_subtree_check,no_root_squash)
/cluster-nas/configs 192.168.254.0/24(rw,sync,no_subtree_check,no_root_squash)
/cluster-nas/backups 192.168.254.0/24(rw,sync,no_subtree_check,no_root_squash)
/cluster-nas/shared 192.168.254.0/24(rw,sync,no_subtree_check,no_root_squash)
```

**NFS Client Configuration (all nodes):**
```fstab
cooperator.ism.la:/cluster-nas /cluster-nas nfs4 defaults,_netdev 0 0
```

## Compute Nodes Network Configuration

### projector (Multi-GPU Compute Node)

**Network Configuration:**
- **IP**: 192.168.254.20 (static)
- **Gateway**: 192.168.254.10 (cooperator)
- **DNS**: 192.168.254.10 (Pi-hole)
- **NFS Mount**: /cluster-nas from cooperator

**Service Ports:**
```yaml
SSH: 22
Archon-MCP: 8051
Archon-Server: 8181
Archon-Agents: 8052
Ollama: 11434
PostgreSQL: 54322
PostgREST: 54321
Adminer: 54323
```

### director (ML Platform Node)

**Network Configuration:**
- **IP**: 192.168.254.30 (static)
- **Gateway**: 192.168.254.10 (cooperator)
- **DNS**: 192.168.254.10 (Pi-hole)
- **NFS Mount**: /cluster-nas from cooperator

**Service Ports:**
```yaml
SSH: 22
Jupyter: 8888
ML Services: 8000-8999 (configurable)
Model Serving: 9000-9999 (configurable)
```

## Security Model

### Network Security

**Internal Network Security:**
- **Private Subnet**: 192.168.254.0/24 (RFC 1918)
- **Firewall**: iptables rules on cooperator
- **External Access**: Only through cooperator gateway
- **SSH Keys**: Ed25519 authentication only
- **Service Isolation**: Services bound to specific interfaces

**Firewall Rules (cooperator):**
```bash
# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow internal cluster traffic
iptables -A INPUT -s 192.168.254.0/24 -j ACCEPT

# Allow SSH from external
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS from external
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow Pi-hole DNS
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT

# Drop all other external traffic
iptables -A INPUT -j DROP
```

### Access Control

**SSH Access Pattern:**
```bash
# External to cluster
ssh user@cooperator.external.ip

# Internal cluster access
ssh user@cooperator.ism.la
ssh user@projector.ism.la
ssh user@director.ism.la

# Jump host pattern
ssh -J user@cooperator.external.ip user@projector.ism.la
```

**User Management:**
- **Cluster Group**: GID 2000 for shared access
- **User Synchronization**: Consistent UIDs across nodes
- **SSH Key Distribution**: Automated via configuration management
- **Service Authentication**: Individual service-level security

## Inter-Node Communication

### Service Discovery

**DNS-Based Discovery:**
```bash
# Service resolution examples
archon.ism.la        # Archon services on projector
pihole.ism.la        # Pi-hole admin on cooperator
compute.ism.la       # Direct access to projector
ml.ism.la            # Direct access to director
```

**Application Communication:**
```yaml
Archon Services:
  - Database: projector:54322 (PostgreSQL)
  - API: projector:54321 (PostgREST)
  - Admin: projector:54323 (Adminer)
  - MCP: projector:8051
  - Server: projector:8181
  - Agents: projector:8052

NFS Access:
  - Config Sync: /cluster-nas/configs/
  - Data Sharing: /cluster-nas/shared/
  - Backups: /cluster-nas/backups/
```

### Load Balancing and High Availability

**Service Distribution:**
```yaml
Gateway Services (cooperator):
  - DNS Resolution: Pi-hole (primary)
  - Web Proxy: Caddy (primary)
  - File Sharing: NFS (primary)
  - Internet Gateway: iptables/NAT (primary)

Compute Services:
  - High-Performance: projector (4x GPU)
  - ML Platform: director (1x GPU)
  - Load Distribution: Based on resource requirements

Failover Strategy:
  - DNS: Secondary DNS on projector (backup)
  - NFS: Read-only mirrors on compute nodes
  - Gateway: Manual failover to projector if needed
```

## Network Performance Optimization

### NFS Performance Tuning

**Mount Options:**
```fstab
cooperator.ism.la:/cluster-nas /cluster-nas nfs4 rsize=1048576,wsize=1048576,hard,intr,tcp 0 0
```

**NFS Server Tuning:**
```bash
# /etc/default/nfs-kernel-server
RPCNFSDCOUNT=16
RPCMOUNTDOPTS="--manage-gids"

# Increase NFS performance
echo 'net.core.rmem_default = 262144' >> /etc/sysctl.conf
echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.core.wmem_default = 262144' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf
```

### Network Interface Optimization

**Interface Configuration:**
```bash
# Increase network buffer sizes
echo 'net.ipv4.tcp_rmem = 4096 65536 16777216' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 4096 65536 16777216' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control = bbr' >> /etc/sysctl.conf

# Optimize for cluster workloads
echo 'net.ipv4.tcp_slow_start_after_idle = 0' >> /etc/sysctl.conf
```

## Network Monitoring and Diagnostics

### Monitoring Infrastructure

**Network Monitoring Stack:**
```yaml
Pi-hole Metrics:
  - DNS Query Logs: /var/log/pihole.log
  - Query Analytics: Pi-hole admin interface
  - Blocked Domains: Real-time dashboard

NFS Monitoring:
  - Mount Status: systemctl status nfs-client.target
  - Performance: nfsstat -c (client stats)
  - I/O Metrics: iotop during transfers

Connectivity Monitoring:
  - Inter-node: ansible all -m ping
  - Service Health: curl health endpoints
  - Network Latency: ping between nodes
```

### Diagnostic Commands

**Network Connectivity:**
```bash
# Check cluster connectivity
ansible all -m ping

# DNS resolution test
dig @192.168.254.10 projector.ism.la

# NFS connectivity
showmount -e cooperator.ism.la

# Port connectivity
nc -zv projector.ism.la 8181

# Network performance
iperf3 -c projector.ism.la
```

**Service Health Checks:**
```bash
# Pi-hole status
systemctl status pihole-FTL
curl http://pihole.ism.la/admin/api.php

# NFS status
systemctl status nfs-server  # on cooperator
systemctl status nfs-client.target  # on clients

# Caddy proxy status
systemctl status caddy
curl -I https://archon.ism.la
```

## Network Configuration Templates

### Chezmoi Network Templates

**Template Variables (.chezmoi.toml.tmpl):**
```toml
[data]
    # Network configuration per node
    {{ if eq .chezmoi.hostname "cooperator" -}}
    node_ip = "192.168.254.10"
    is_gateway = true
    has_dns_server = true
    has_nfs_server = true
    external_access = true
    {{- else if eq .chezmoi.hostname "projector" -}}
    node_ip = "192.168.254.20"
    is_gateway = false
    has_dns_server = false
    has_nfs_server = false
    external_access = false
    {{- else if eq .chezmoi.hostname "director" -}}
    node_ip = "192.168.254.30"
    is_gateway = false
    has_dns_server = false
    has_nfs_server = false
    external_access = false
    {{- end }}

    # Network settings
    cluster_subnet = "192.168.254.0/24"
    cluster_domain = "ism.la"
    dns_server = "192.168.254.10"
    nfs_server = "192.168.254.10"
    gateway_ip = "192.168.254.10"
```

**Network Aliases (Shell Templates):**
```bash
# In dot_bashrc.tmpl and dot_zshrc.tmpl
{{- if .is_gateway }}
# Gateway-specific network aliases
alias check-dns='dig @localhost example.com'
alias pihole-status='systemctl status pihole-FTL'
alias nfs-exports='showmount -e'
alias caddy-reload='sudo systemctl reload caddy'
{{- end }}

# Universal cluster network aliases
alias cluster-ping='ansible all -m ping'
alias cluster-dns='dig @{{ .dns_server }}'
alias nfs-status='df -h /cluster-nas'

{{- if not .is_gateway }}
# Non-gateway specific
alias gateway-ssh='ssh {{ .gateway_ip }}'
alias check-internet='ping -c 3 8.8.8.8'
{{- end }}
```

## Backup and Recovery

### Network Configuration Backup

**Configuration Preservation:**
```bash
# Backup network configurations
sudo tar czf network-config-backup.tar.gz \
    /etc/network/interfaces \
    /etc/hosts \
    /etc/resolv.conf \
    /etc/exports \
    /etc/fstab \
    /etc/caddy/ \
    /etc/pihole/

# Backup firewall rules
sudo iptables-save > iptables-backup.rules

# Backup DNS configurations
sudo tar czf dns-config-backup.tar.gz \
    /etc/pihole/ \
    /var/log/pihole.log
```

### Network Recovery Procedures

**Emergency Network Recovery:**
```bash
# Restore basic connectivity
sudo dhclient eth0  # Get temporary IP

# Restore static configuration
sudo cp interfaces.backup /etc/network/interfaces
sudo systemctl restart networking

# Restore DNS
sudo cp resolv.conf.backup /etc/resolv.conf

# Restore NFS
sudo cp fstab.backup /etc/fstab
sudo mount -a

# Restore firewall
sudo iptables-restore < iptables-backup.rules
```

## Scaling and Future Expansion

### Network Expansion Strategy

**Adding New Nodes:**
```yaml
IP Allocation:
  - Next available: 192.168.254.40, 192.168.254.50, etc.
  - Reserved ranges:
    - 192.168.254.100-199 (dynamic/DHCP)
    - 192.168.254.200-254 (future services)

DNS Updates:
  - Add A records in Pi-hole
  - Update internal domain aliases
  - Configure service-specific subdomains

NFS Access:
  - Update /etc/exports with new subnet ranges
  - Configure client mounts on new nodes
  - Test permissions and connectivity
```

**Service Distribution:**
```yaml
Load Balancing:
  - Distribute services across compute nodes
  - Use Caddy for HTTP load balancing
  - Implement health checks for failover

High Availability:
  - Secondary DNS server deployment
  - NFS failover clustering
  - Gateway redundancy planning
```

## Conclusion

The Co-lab cluster network topology provides:

- **Secure Internal Communication**: Private subnet with controlled external access
- **Centralized Services**: DNS, NFS, and gateway services on cooperator
- **Scalable Architecture**: Room for expansion with clear IP allocation
- **High Performance**: Optimized NFS and network configurations
- **Service Integration**: Template-driven network configuration management
- **Monitoring Capability**: Comprehensive network health monitoring

This network design enables efficient cluster operation while maintaining security, performance, and scalability for future growth. The combination of centralized services and distributed compute resources provides optimal resource utilization and operational efficiency.

**Key Network Benefits:**
- ✅ Single point of external access (security)
- ✅ Internal service discovery via DNS
- ✅ Shared storage across all nodes
- ✅ Template-driven configuration management
- ✅ Performance-optimized network stack
- ✅ Comprehensive monitoring and diagnostics

The network topology serves as the foundation for all cluster operations, enabling seamless communication between services while maintaining security and performance standards.