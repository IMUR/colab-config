# Co-lab Cluster Configuration

Comprehensive infrastructure configuration for the 3-node co-lab cluster (cooperator, projector, director).

## 🏗️ Architecture

This repository manages all infrastructure configurations for the co-lab cluster using a hybrid approach:
- **Ansible** for infrastructure deployment and management
- **Chezmoi** for universal user configurations (omni-config)
- **Service configurations** for cluster services and applications

## 📁 Repository Structure

```
colab-config/
├── ansible/              # Cluster management automation
│   ├── playbooks/        # Deployment and maintenance playbooks
│   ├── inventory/        # Node definitions and grouping
│   ├── group_vars/       # Group-specific variables
│   ├── host_vars/        # Host-specific variables
│   └── roles/           # Reusable automation roles
├── services/            # Service-specific configurations
│   ├── semaphore/       # Ansible UI and automation
│   └── templates/       # Service configuration templates
├── infrastructure/     # Infrastructure tooling and configs
│   ├── ssh/            # SSH client configurations
│   ├── starship/       # Shell prompt configurations
│   └── fastfetch/      # System information display
├── omni-config/        # Universal user configurations (chezmoi)
│   ├── dot_zshrc       # Shared shell configuration
│   ├── dot_profile     # Universal profile settings
│   ├── .chezmoi.toml.tmpl # Node-specific templating
│   └── tools/          # Tool-specific configurations
├── documentation/      # Architecture and procedures
│   ├── architecture/   # System design decisions
│   ├── procedures/     # Operational procedures
│   └── troubleshooting/ # Common issues and solutions
└── scripts/           # Utility scripts for cluster management
```

## 🎯 Three Node Cluster

**Core Cluster Nodes:**
- **cooperator (crtr)** - Gateway, NFS server, DNS (Pi5, 16GB RAM)
- **projector (prtr)** - Compute power, multi-GPU (x86, 128GB RAM)
- **director (drtr)** - ML platform, dedicated GPU (x86, 64GB RAM)

**Network Configuration:**
- **Internal Network**: 192.168.254.0/24
- **DNS**: .ism.la domain via Pi-hole on cooperator
- **Public Access**: Port forwarding through cooperator (22, 80, 443)

## 🚀 Quick Start

### Prerequisites
- Ansible installed on control node
- SSH key access to all cluster nodes
- Network connectivity to cluster

### Basic Deployment
```bash
# Clone repository
git clone https://github.com/IMUR/colab-config.git
cd colab-config

# Deploy infrastructure
ansible-playbook ansible/playbooks/site.yml

# Check cluster health
ansible-playbook ansible/playbooks/cluster-health.yml
```

### Universal Configuration Deployment
```bash
# Deploy omni-config via chezmoi (when migration is complete)
ansible-playbook ansible/playbooks/deploy-omni-config.yml
```

## 🔧 Configuration Management

### Current Status: Hybrid Approach

**✅ Active (Symlinks)**: Universal configs currently deployed via symlinks to `/cluster-nas/configs/zsh/`
**🔄 Transitioning**: Moving to chezmoi-based omni-config deployment
**📋 Planned**: Gradual migration maintaining zero downtime

### Universal Configurations (omni-config)
Deployed identically to all 3 cluster nodes:
- Shell environment (zsh, bash)
- Modern CLI tools (eza, bat, fd, rg, fzf, nnn, delta)
- Development tools (git, tmux)
- Universal aliases and functions

### Node-Specific Configurations
Tailored per node role:
- **cooperator**: NFS server, Pi-hole, Caddy, gateway services
- **projector**: Multi-GPU setup, compute environments
- **director**: Single GPU, ML-specific configurations

## 📚 Key Services

### Web Interfaces
- **Semaphore**: https://cfg.ism.la (Ansible automation UI)
- **Cockpit**: https://mng.ism.la (System management)
- **SSH Terminal**: https://ssh.ism.la (Web-based terminal)
- **DNS Management**: https://dns.ism.la (Pi-hole interface)

### Core Infrastructure
- **NFS Server**: Shared storage at `/cluster-nas`
- **DNS Resolution**: Pi-hole with custom .ism.la domain
- **Reverse Proxy**: Caddy for web service routing
- **Monitoring**: System health and performance tracking

## 🛡️ Security & Maintenance

### Backup Strategy
- **Daily Automated Backups**: All configurations backed up to `/cluster-nas/backups/`
- **Version Control**: All changes tracked in git
- **Rollback Capability**: Quick reversion using Ansible playbooks

### Security Features
- **SSH Key Authentication**: No password access
- **Internal Network**: Services isolated on private network
- **Controlled Access**: Public access only through designated ports
- **Regular Updates**: Automated security updates via Ansible

## 📋 Operational Procedures

### Daily Operations
```bash
# Check cluster health
ansible-playbook ansible/playbooks/cluster-health.yml

# View system status
ansible all -m setup -a "filter=ansible_load*"

# Update all systems
ansible-playbook ansible/playbooks/system-update.yml
```

### Maintenance Tasks
```bash
# Backup configurations
ansible-playbook ansible/playbooks/backup-verify.yml

# Deploy service changes
ansible-playbook ansible/playbooks/cluster-deploy.yml

# Restart services if needed
ansible-playbook ansible/playbooks/restart-services.yml
```

## 🚨 Emergency Procedures

### Access Methods
1. **Primary**: SSH via cooperator (192.168.254.10 or public IP)
2. **Web Management**: Cockpit interface at https://mng.ism.la
3. **Direct Console**: Physical access to cooperator Pi5

### Quick Recovery
```bash
# Restore from backup
cd /cluster-nas/backups/YYYYMMDD_HHMMSS/
ansible-playbook restore-configs.yml

# Restart all services
ansible-playbook ansible/playbooks/restart-services.yml
```

## 📖 Documentation

- [Architecture Overview](documentation/architecture/README.md)
- [Deployment Procedures](documentation/procedures/deployment.md)
- [Troubleshooting Guide](documentation/troubleshooting/README.md)

## 🎯 Migration Status

### Completed
- ✅ Ansible infrastructure automation
- ✅ Service configuration management
- ✅ 3-node architecture implementation
- ✅ Web service deployment

### In Progress
- 🔄 Symlinks → Chezmoi migration for universal configs
- 🔄 Enhanced monitoring and alerting
- 🔄 Automated tool standardization

### Planned
- 📋 Complete omni-config deployment
- 📋 Enhanced backup strategies
- 📋 Performance optimization

---

**Maintained by**: Co-lab Infrastructure Team
**Repository**: https://github.com/IMUR/colab-config
**License**: Private - Co-lab Cluster Infrastructure