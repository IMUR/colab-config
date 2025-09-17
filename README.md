# Co-lab Cluster Configuration

Comprehensive infrastructure configuration for the 3-node co-lab cluster (cooperator, projector, director).

## 🏗️ Modern Hybrid Architecture

This repository manages all co-lab cluster configurations using a **strategic hybrid approach** following 2024 best practices:

- **Minimal Ansible**: System-level only (packages, services, /etc/profile.d/)
- **Pure Chezmoi**: User configurations (dotfiles, shell, tools)
- **Clear Separation**: Right tool for the right job

### **Why Hybrid?**
- ✅ **Ansible**: Perfect for system administration, package management
- ✅ **Chezmoi**: Purpose-built for user dotfiles and cross-machine consistency
- ✅ **Safer**: User-level changes vs dangerous system modifications  
- ✅ **Faster**: 20-minute deployment vs hours of complex orchestration

## 📁 Repository Structure

```
colab-config/
├── 🎯 omni-config/        # PRIMARY: User configurations (chezmoi)
│   ├── dot_zshrc         # Modern shell configuration
│   ├── dot_profile       # Universal profile + tool detection
│   ├── dot_config/       # Tool configurations (starship, etc.)
│   └── tools/            # Tool-specific settings
├── 🔧 ansible/            # MINIMAL: System-level only
│   ├── playbooks/        # Health checks, basic system setup
│   ├── inventory/        # Node definitions
│   └── group_vars/       # Basic node grouping
├── 📚 documentation/      # Comprehensive guides
│   ├── architecture/     # System design
│   ├── procedures/       # Deployment guides
│   └── AI-AGENT-*.md     # Agent-focused procedures
├── 🛠️ services/          # Optional service configs
├── 🏗️ infrastructure/    # Supporting configurations
└── 📜 scripts/           # Utility scripts
```

### **Focus Areas:**
- **🎯 omni-config/**: **Primary focus** - Rich user experience via chezmoi
- **🔧 ansible/**: **Minimal usage** - Basic system preparation only  
- **📚 documentation/**: **Comprehensive** - Clear deployment procedures

## 🎯 Three Node Cluster

**Core Cluster Nodes:**
- **cooperator (crtr)** - Gateway, NFS server, DNS (Pi5, 16GB RAM)
- **projector (prtr)** - Compute power, multi-GPU (x86, 128GB RAM)
- **director (drtr)** - ML platform, dedicated GPU (x86, 64GB RAM)

**Network Configuration:**
- **Internal Network**: 192.168.254.0/24
- **DNS**: .ism.la domain via Pi-hole on cooperator
- **Public Access**: Port forwarding through cooperator (22, 80, 443)

## 🚀 Quick Start (20 minutes)

### **Modern Hybrid Deployment**

```bash
# 1. Clone repository (2 minutes)
git clone https://github.com/IMUR/colab-config.git
cd colab-config

# 2. Install chezmoi on all nodes (5 minutes)
for node in crtr prtr drtr; do
    ssh "$node" "curl -sfL https://get.chezmoi.io | sh -s -- -b ~/.local/bin"
done

# 3. Deploy user configurations via chezmoi (10 minutes)  
scp -r omni-config/ crtr:/cluster-nas/configs/colab-omni-config/

for node in drtr prtr crtr; do
    echo "Deploying to $node..."
    ssh "$node" "~/.local/bin/chezmoi init --apply --source /cluster-nas/configs/colab-omni-config"
    ssh "$node" 'source ~/.zshrc && echo "✅ '$node' ready"'
done

# 4. Validate deployment (3 minutes)
echo "🎉 Deployment complete! Testing functionality..."
for node in crtr prtr drtr; do
    ssh "$node" "echo 'Node:' \$(hostname) && command -v eza >/dev/null && echo '✅ Modern tools ready'"
done
```

### **Optional: System-Level Setup**
```bash
# Only if system-wide environment needed
ansible-playbook ansible/playbooks/cluster-health.yml  # Health check
# Additional minimal ansible as needed
```

## 🔧 Modern Configuration Management

### **Hybrid Architecture** ✅ **ACTIVE**

**System-Level (Minimal Ansible)**:
- Package installation and basic system setup
- /etc/profile.d/ for system-wide environment
- Service management and health monitoring
- Minimal, focused, low-risk operations

**User-Level (Pure Chezmoi)**:
- Rich shell environments (.zshrc, .profile) 
- Modern CLI tools (eza, bat, fd, rg, fzf, starship)
- Development configurations (git, tmux)
- Cross-node consistency with templating

### **Universal User Experience**
Deployed identically across all 3 cluster nodes:
- ✅ **Modern Shell**: ZSH with advanced features
- ✅ **Tool Detection**: Smart fallbacks for missing tools
- ✅ **Performance**: Optimized startup times
- ✅ **Consistency**: Same experience on every node

### **Node-Specific Templating**
Chezmoi templates adapt automatically:
- **cooperator**: Gateway-specific aliases and paths
- **projector**: Multi-GPU development shortcuts  
- **director**: ML workflow optimizations
- **Architecture-aware**: ARM64 vs x86_64 tool handling

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

## 📋 Modern Operations

### **Daily Health Checks**
```bash
# Quick cluster health (minimal ansible)
ansible-playbook ansible/playbooks/cluster-health.yml

# Check user configurations (chezmoi)
for node in crtr prtr drtr; do
    ssh "$node" "chezmoi status && echo '$node: configs up to date'"
done
```

### **Configuration Updates**
```bash
# Update user configurations (primary method)
git pull  # Get latest omni-config changes
scp -r omni-config/ crtr:/cluster-nas/configs/colab-omni-config/

# Apply updates across cluster
for node in crtr prtr drtr; do
    ssh "$node" "chezmoi update"
done

# System-level updates (minimal, as needed)
ansible-playbook ansible/playbooks/cluster-health.yml
```

### **Maintenance Workflow**
1. **User configs**: Update omni-config, deploy via chezmoi (primary)
2. **System-level**: Use minimal ansible only when required
3. **Validation**: Test configurations on each node
4. **Rollback**: Simple `chezmoi` revert if needed

## 🚨 Emergency Procedures

### **Quick Recovery (Low Risk)**
```bash
# Configuration rollback (primary method)
for node in crtr prtr drtr; do
    ssh "$node" "
        # Simple chezmoi rollback
        chezmoi forget --force
        chezmoi init --source /cluster-nas/configs/colab-omni-config-backup
        
        # Or restore from local backup
        [[ -f ~/.zshrc.backup ]] && mv ~/.zshrc.backup ~/.zshrc
        
        echo '$node rolled back'
    "
done
```

### **Access Methods (Unchanged)**
1. **Primary**: SSH via cooperator (192.168.254.10)
2. **Web Management**: Cockpit at https://mng.ism.la  
3. **Direct Console**: Physical access to cooperator Pi5

### **Why Recovery is Easier:**
- ✅ **User-level changes**: No system modification risks
- ✅ **Fast rollback**: Chezmoi revert vs complex ansible restore
- ✅ **Safe operations**: Configuration errors won't break SSH access
- ✅ **Simple validation**: `source ~/.zshrc` test vs full system validation

## 📖 Documentation

- [Architecture Overview](documentation/architecture/README.md)
- [Deployment Procedures](documentation/procedures/deployment.md)
- [Troubleshooting Guide](documentation/troubleshooting/README.md)

## 🎯 Modern Implementation Status

### ✅ **Completed**
- **Hybrid Architecture**: Strategic separation of system vs user configs
- **Pure Chezmoi Foundation**: Rich user configuration system  
- **Minimal Ansible**: Focused system-level operations only
- **Cross-node Consistency**: Template-based configuration adaptation
- **20-minute Deployment**: Fast, safe, user-level configuration management

### 🔄 **Active**
- **Daily Operations**: Hybrid approach in production use
- **Continuous Improvement**: Ongoing omni-config refinements
- **Documentation**: Comprehensive guides and procedures

### 📋 **Future Enhancements**
- **System-wide Environment**: Optional /etc/profile.d/ configurations
- **Automated Health Monitoring**: Enhanced cluster validation
- **Advanced Templating**: Node-specific configuration variations

---

**Maintained by**: Co-lab Infrastructure Team
**Repository**: https://github.com/IMUR/colab-config
**License**: Private - Co-lab Cluster Infrastructure