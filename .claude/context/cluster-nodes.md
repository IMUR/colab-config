# Cluster Node Reference

Quick reference for Claude Code when working with cluster nodes.

## Node Details

### cooperator (crtr) - Gateway Node
- **IP**: 192.168.254.10
- **SSH**: `ssh crtr` or `ssh crtr@192.168.254.10`
- **Role**: Gateway, NFS server, DNS, Ansible controller
- **Hardware**: Raspberry Pi 5, 16GB RAM, ARM64
- **UID**: 1001 (special - for NFS ownership)
- **Services**: Pi-hole, Caddy, NFS, Cockpit, Semaphore
- **Web Access**: Entry point for all .ism.la domains

### projector (prtr) - Compute Node
- **IP**: 192.168.254.20
- **SSH**: `ssh prtr` or `ssh prtr@192.168.254.20`
- **Role**: High-performance computing, ML training
- **Hardware**: x86_64, 128GB RAM, Multi-GPU
- **UID**: 1000 (standard)
- **Services**: GPU workloads, development environments

### director (drtr) - ML Platform
- **IP**: 192.168.254.30
- **SSH**: `ssh drtr` or `ssh drtr@192.168.254.30`
- **Role**: ML platform, model serving
- **Hardware**: x86_64, 64GB RAM, Single GPU
- **UID**: 1000 (standard)
- **Services**: ML frameworks, model deployment

## Quick Commands

### Test All Nodes
```bash
for node in crtr prtr drtr; do
    echo -n "$node: "
    ssh "$node" "echo OK" 2>/dev/null || echo "FAILED"
done
```

### Check Node Health
```bash
ansible all -m ping
ansible all -m setup -a "filter=ansible_load*"
```

### Access Web Interfaces
- Semaphore: https://cfg.ism.la
- Cockpit: https://mng.ism.la
- SSH Terminal: https://ssh.ism.la
- DNS: https://dns.ism.la

## Important Paths

### Shared Storage
- **NFS Mount**: `/cluster-nas` (on all nodes)
- **Config Location**: `/cluster-nas/configs/`
- **Backup Location**: `/cluster-nas/backups/`

### User Configurations
- **Current Method**: Symlinks to `/cluster-nas/configs/zsh/`
- **Target Method**: Chezmoi-based omni-config
- **Shell Config**: `~/.zshrc` on each node