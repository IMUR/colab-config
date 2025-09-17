# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the Co-lab cluster infrastructure configuration repository.

## Repository Overview

This repository (`colab-config`) contains the complete infrastructure configuration for the 3-node Co-lab cluster. It serves as the authoritative source for cluster automation, universal configurations, and deployment procedures.

## CURRENT STATUS: Modern Hybrid Configuration Repository ✅

**Repository Type**: Strategic Hybrid Configuration Management  
**Scope**: 3-node cluster (cooperator, projector, director)  
**Management**: **Modern Hybrid** - Minimal Ansible + Pure Chezmoi  
**Safety Level**: Production-ready with user-level safety focus

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

## Modern Hybrid Configuration Strategy

### **Strategic Architecture** ✅ **ACTIVE**

**System-Level (Minimal Ansible)**:
- Package installation and system services  
- Basic /etc/profile.d/ environment setup
- Health monitoring and system validation
- Minimal, focused, low-risk operations only

**User-Level (Pure Chezmoi)**:
- Rich shell environments (.zshrc, .profile)
- Modern CLI tools with smart detection
- Cross-node consistency via templating
- Node-specific customizations

### **Why This Approach Works**
- ✅ **Right Tool, Right Job**: Ansible for systems, Chezmoi for users
- ✅ **Reduced Risk**: User-level changes vs dangerous system modifications
- ✅ **Faster Deployment**: 20 minutes vs hours of complex orchestration  
- ✅ **Easier Maintenance**: Simple chezmoi updates vs complex ansible playbooks
- ✅ **Better Rollback**: Instant chezmoi revert vs system restoration

### **Deployment Reality**
- **20-minute deployment** from scratch
- **User-level changes only** (SSH access preserved)
- **Simple rollback procedure** (chezmoi reset)
- **Production-ready** following 2024 best practices

## Working with This Repository

### Prerequisites for Development
- **Network Access**: Must be able to reach cluster nodes
- **SSH Keys**: Ed25519 keys configured for cluster access
- **Ansible**: Installed and configured
- **Git**: For version control operations

### **Modern Operations**

#### **Primary: User Configuration Management (Chezmoi)**
```bash
# Deploy/update user configurations (primary method)
scp -r omni-config/ crtr:/cluster-nas/configs/colab-omni-config/

for node in crtr prtr drtr; do
    ssh "$node" "chezmoi update"
done

# Validate deployment
for node in crtr prtr drtr; do
    ssh "$node" 'source ~/.zshrc && echo "✅ '$node' ready"'
done
```

#### **Secondary: System-Level Operations (Minimal Ansible)**
```bash
# Health monitoring (minimal ansible usage)
ansible-playbook ansible/playbooks/cluster-health.yml

# System validation when needed
ansible all -m ping  # Basic connectivity check
```

#### **Safe Development Workflow**
```bash
# 1. Test configuration changes
ssh drtr "chezmoi diff"  # Preview changes on least critical node

# 2. Apply to test node first
ssh drtr "chezmoi apply"

# 3. Validate functionality
ssh drtr 'timeout 5 zsh -c "source ~/.zshrc && echo SUCCESS"'

# 4. Deploy cluster-wide if successful
for node in crtr prtr; do ssh "$node" "chezmoi apply"; done
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

### **Modern Safety Protocols**

#### **Before Making Changes (Simple)**
1. **Test on director first**: `ssh drtr "chezmoi diff"` - preview changes
2. **Validate functionality**: `ssh drtr 'source ~/.zshrc && echo SUCCESS'`
3. **Check system health**: `ansible-playbook ansible/playbooks/cluster-health.yml` (optional)
4. **User-level safety**: No system modification risks

#### **Emergency Procedures (Low Risk)**
```bash
# Quick rollback (primary method)
for node in crtr prtr drtr; do
    ssh "$node" "
        # Reset chezmoi to previous state  
        chezmoi forget --force
        rm -rf ~/.local/share/chezmoi
        
        # Restore from backup if needed
        [[ -f ~/.zshrc.backup ]] && mv ~/.zshrc.backup ~/.zshrc
        
        echo '$node rolled back'
    "
done
```

#### **Why Recovery is Safer**
- ✅ **User-level only**: Configuration errors won't break SSH access
- ✅ **Fast rollback**: Seconds vs complex system restoration  
- ✅ **Simple validation**: `source ~/.zshrc` test vs full system checks
- ✅ **Isolated impact**: Shell configs don't affect critical services

## AI Agent Integration

### **For AI Agents Operating from Snitcher**
- **20-minute Assessment**: Use updated `AI-AGENT-QUICKSTART.md` for hybrid deployment
- **Comprehensive Guide**: Follow `documentation/procedures/AI-AGENT-DEPLOYMENT-GUIDE.md`  
- **Modern Approach**: Hybrid strategy - minimal ansible + pure chezmoi
- **Low Risk**: User-level changes only, SSH access preserved

### **Decision Authority (Simplified)**
- **Green Light**: All nodes accessible → **PROCEED** with hybrid deployment  
- **Yellow Light**: Partial connectivity → Deploy to accessible nodes only
- **Red Light**: Major connectivity issues → Resolve access first

### **Deployment Confidence**
- ✅ **Low Risk**: User-level configurations only
- ✅ **Fast Recovery**: Simple chezmoi rollback vs complex system restore
- ✅ **Proven Approach**: Following established best practices  
- ✅ **Minimal Dependencies**: No complex ansible orchestration required

## **Modern Development Guidelines**

### **Configuration Changes (Primary)**
```bash
# User configuration workflow (main method)
1. Edit omni-config/ files locally
2. Test changes: git diff, syntax validation  
3. Deploy to test node: scp + ssh drtr "chezmoi apply"
4. Validate: ssh drtr 'source ~/.zshrc && echo SUCCESS'
5. Deploy cluster-wide: for node in crtr prtr; do ssh "$node" "chezmoi apply"; done
```

### **System Changes (Minimal Use)**
```bash  
# Only when system-level changes required
1. Edit ansible playbooks minimally
2. Test with --check --diff first
3. Target specific nodes with --limit
4. Validate system health afterward
```

### **Version Control Best Practices**
- **User configs**: Primary development in omni-config/
- **System configs**: Minimal ansible changes only
- **Documentation**: Keep procedures updated
- **Testing**: Always test on director (drtr) first

### **Development Philosophy**
- ✅ **User-first**: Focus on omni-config for rich user experience
- ✅ **System-minimal**: Use ansible only when absolutely necessary
- ✅ **Safety-focused**: User-level changes preserve SSH access
- ✅ **Fast iteration**: Quick chezmoi updates vs slow ansible runs

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