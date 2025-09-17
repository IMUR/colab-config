# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the Co-lab cluster infrastructure configuration repository.

## Repository Overview

This repository (`colab-config`) contains the complete infrastructure configuration for the 3-node Co-lab cluster. It serves as the authoritative source for cluster automation, universal configurations, and deployment procedures.

## CURRENT STATUS: Infrastructure Configuration Repository ✅

**Repository Type**: Infrastructure Configuration Management
**Scope**: 3-node cluster (cooperator, projector, director)
**Management**: Ansible + Chezmoi hybrid approach
**Safety Level**: Production-critical infrastructure

**Current Structure:**
```
colab-config/
├── ansible/                    # Cluster automation (Ansible)
├── services/                   # Service configurations
├── infrastructure/             # Infrastructure tooling
├── omni-config/               # Universal configurations (Chezmoi)
├── documentation/             # Architecture and procedures
├── scripts/                   # Utility scripts
├── AI-AGENT-QUICKSTART.md     # AI agent deployment guide
└── CLAUDE.md                  # This file
```

## Cluster Architecture

**Core Cluster Nodes (3+1 Architecture):**
- **cooperator (crtr)** - Gateway, NFS server, DNS, services (Pi5, 16GB RAM, 192.168.254.10)
- **projector (prtr)** - Compute power, multi-GPU (x86, 128GB RAM, 192.168.254.20)
- **director (drtr)** - ML platform, single GPU (x86, 64GB RAM, 192.168.254.30)

**Mobile Access Point (Separate Configuration):**
- **snitcher** - Remote access laptop (has its own repository: snitcher-config)

## Key Infrastructure Services

### Web Interfaces (via cooperator gateway)
- **Semaphore**: https://cfg.ism.la (Ansible automation UI)
- **Cockpit**: https://mng.ism.la (System management)
- **SSH Terminal**: https://ssh.ism.la (Web-based terminal)
- **DNS Management**: https://dns.ism.la (Pi-hole interface)

### Core Services
- **NFS Server**: Shared storage at `/cluster-nas` (on cooperator)
- **Pi-hole DNS**: Internal `.ism.la` domain resolution (on cooperator)
- **Caddy Proxy**: Web service routing and SSL (on cooperator)
- **Ansible Controller**: Configuration management (from cooperator)

## Configuration Management Strategy

### Current State (Stable Production)
- **Universal Configs**: Deployed via symlinks to `/cluster-nas/configs/zsh/`
- **Working System**: All 3 nodes functional with shared shell configurations
- **Battle Tested**: Proven stable for daily operations

### Target State (Migration in Progress)
- **Universal Configs**: Chezmoi-based omni-config deployment
- **Enhanced Management**: Git-based configuration source of truth
- **Node Templating**: Support for node-specific variations

### Migration Strategy (Zero Downtime)
1. **Phase 1**: Repository establishment ✅
2. **Phase 2**: Parallel testing (symlinks + chezmoi)
3. **Phase 3**: Gradual cutover maintaining stability
4. **Phase 4**: Full chezmoi deployment with symlink removal

## Working with This Repository

### Prerequisites for Development
- **Network Access**: Must be able to reach cluster nodes
- **SSH Keys**: Ed25519 keys configured for cluster access
- **Ansible**: Installed and configured
- **Git**: For version control operations

### Common Operations

#### Cluster Health Check
```bash
# Quick health assessment
ansible-playbook ansible/playbooks/cluster-health.yml

# Detailed status check
ansible all -m setup -a "filter=ansible_load*"
```

#### Configuration Deployment
```bash
# Deploy infrastructure changes
ansible-playbook ansible/playbooks/site.yml

# Deploy universal configs (when migration complete)
ansible-playbook ansible/playbooks/deploy-omni-config.yml
```

#### Backup and Safety
```bash
# Create backup before changes
ansible-playbook ansible/playbooks/backup-verify.yml

# Verify backup integrity
ls -la /cluster-nas/backups/$(date +%Y%m%d)*
```

### Directory Deep Dive

#### `ansible/` - Cluster Automation
- **playbooks/**: Deployment and maintenance automation
- **inventory/**: Node definitions (hosts.yml)
- **group_vars/**: Configuration for node groups
- **host_vars/**: Node-specific configurations
- **roles/**: Reusable automation components

#### `omni-config/` - Universal Configurations
- **dot_zshrc**: Shared shell configuration for all nodes
- **dot_profile**: Universal profile settings
- **.chezmoi.toml.tmpl**: Node-specific templating logic
- **tools/**: Tool-specific configurations

#### `services/` - Service Configurations
- **semaphore/**: Ansible UI configuration and data
- **templates/**: Service configuration templates

#### `documentation/` - Architecture and Procedures
- **architecture/**: System design and decisions
- **procedures/**: Operational procedures and guides

### Critical UID/GID Information

**Current Working Configuration (DO NOT CHANGE):**
- **cooperator (crtr)**: UID 1001, GID 1001 + cluster(2000) - NFS ownership requirement
- **projector (prtr)**: UID 1000, GID 1000 + cluster(2000) - standard user
- **director (drtr)**: UID 1000, GID 1000 + cluster(2000) - standard user

**File Permissions Strategy:**
- **NFS Compatibility**: 777/666 permissions (world-writable) required for applications
- **Security Trade-off**: Acceptable within trusted cluster network
- **Cluster Group**: GID 2000 provides shared access without UID conflicts

### Safety Protocols

#### Before Making Changes
1. **Always create backup**: `ansible-playbook ansible/playbooks/backup-verify.yml`
2. **Test on single node**: Use `--limit drtr` for testing
3. **Verify current state**: Run health checks first
4. **Have rollback plan**: Know how to restore from backup

#### Emergency Procedures
- **Configuration Restore**: `/cluster-nas/backups/YYYYMMDD_HHMMSS/restore.sh`
- **Service Restart**: `ansible-playbook ansible/playbooks/restart-services.yml`
- **Emergency Access**: Physical console on cooperator or web terminal

#### Rollback Strategy
- **Symlink Restore**: Revert to known working symlink configuration
- **Backup Restoration**: Full restore from daily automated backups
- **Service Recovery**: Individual service restart and validation

## AI Agent Integration

### For AI Agents Operating from Snitcher
- **Quick Assessment**: Use `AI-AGENT-QUICKSTART.md` for 10-minute evaluation
- **Full Deployment**: Follow `documentation/procedures/AI-AGENT-DEPLOYMENT-GUIDE.md`
- **Safety First**: All procedures designed for maximum caution

### Decision Authority
- **Green Light**: All systems accessible, healthy, and backed up
- **Yellow Light**: Partial deployment possible with increased caution
- **Red Light**: Abort deployment, resolve prerequisites first

## Development Guidelines

### Code Changes
- **Ansible Playbooks**: Always test with `--check` and `--diff` first
- **Configuration Templates**: Validate templating logic before deployment
- **Shell Scripts**: Test on single node before cluster-wide deployment

### Documentation
- **Architecture Changes**: Update `documentation/architecture/README.md`
- **Procedure Updates**: Maintain `documentation/procedures/` accuracy
- **README Sync**: Keep main README.md current with changes

### Version Control
- **Commit Messages**: Descriptive, include impact assessment
- **Branching**: Use feature branches for major changes
- **Testing**: Validate changes before merging to main

## Monitoring and Maintenance

### Daily Operations
- **Health Monitoring**: Automated via Ansible playbooks
- **Backup Verification**: Daily automated backups with integrity checks
- **Service Status**: Monitor via Cockpit web interface
- **Resource Usage**: Track CPU, memory, disk via standard tools

### Weekly Maintenance
- **Security Updates**: Coordinated via Ansible automation
- **Performance Review**: Resource utilization and optimization
- **Backup Rotation**: Cleanup old backups, verify restore procedures
- **Documentation Review**: Keep procedures current

## Troubleshooting Common Issues

### SSH Connectivity Problems
- **Check SSH keys**: Verify ed25519 keys in place
- **Network connectivity**: Test ping to all cluster nodes
- **SSH config**: Validate `~/.ssh/config` for cluster hosts

### Ansible Execution Issues
- **Inventory problems**: Validate `ansible-inventory --list`
- **Playbook syntax**: Use `ansible-playbook --syntax-check`
- **Connection testing**: Run `ansible all -m ping`

### Configuration Deployment Failures
- **Backup restoration**: Revert to known working state
- **Single node testing**: Isolate issues with `--limit`
- **Service restart**: Often resolves configuration loading issues

### NFS Mount Issues
- **Server status**: Check NFS server on cooperator
- **Client mounts**: Verify `/cluster-nas` accessibility on all nodes
- **Permissions**: Ensure proper UID/GID cluster membership

## Important Notes

- **Production Environment**: This manages live cluster infrastructure
- **Safety First**: Always backup before changes, test before full deployment
- **Documentation**: Keep all changes documented and procedures updated
- **Coordination**: Major changes should be planned and communicated
- **Rollback Ready**: Every deployment should have a tested rollback plan

## Repository Relationships

### Related Repositories
- **snitcher-config**: Independent configuration for snitcher mobile access
- **Original cluster-nas**: Parent directory structure (not version controlled)

### Data Flow
- **Source of Truth**: This repository for infrastructure configuration
- **Deployment Target**: `/cluster-nas/configs/` on cooperator
- **Backup Storage**: `/cluster-nas/backups/` for safety and recovery

This repository is designed for safe, reliable infrastructure management with maximum operational safety and clear rollback procedures.