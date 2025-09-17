**📍 File Location**: `README.md` (Project Root)

---

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
│   ├── tools/            # Tool-specific settings
│   └── PLATONIC-NODE-GUIDE.md # Reference for theoretical ideal state
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
# 1. Ensure chezmoi is installed on all nodes (5 minutes)
for node in crtr prtr drtr; do
    ssh "$node" "command -v chezmoi >/dev/null || curl -sfL https://get.chezmoi.io | sh -s -- -b ~/.local/bin"
done

# 2. Deploy user configurations via chezmoi from GitHub remote (10 minutes)
for node in crtr prtr drtr; do
    echo "Deploying to $node..."
    ssh "$node" "chezmoi init --apply https://github.com/IMUR/colab-config.git"
    ssh "$node" 'source ~/.zshrc && echo "✅ '$node' ready"'
done

# 3. Validate deployment and templating (3 minutes)
echo "🎉 Deployment complete! Testing functionality..."
for node in crtr prtr drtr; do
    ssh "$node" "echo 'Node:' \$(hostname) && chezmoi data | grep node_role && command -v eza starship >/dev/null && echo '✅ Modern tools and templating ready'"
done

# 4. Test shell consistency across nodes
for node in crtr prtr drtr; do
    ssh "$node" "bash -c 'source ~/.bashrc && command -v nvm >/dev/null && echo \"$node: Bash+NVM working\"'"
    ssh "$node" "zsh -c 'source ~/.zshrc && command -v nvm >/dev/null && echo \"$node: ZSH+NVM working\"'"
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
- Rich shell environments managed via chezmoi templates
- Modern CLI tool suite with intelligent detection and fallbacks
- Development environment configurations with cross-node consistency
- **Template System**: Node-specific customization via .tmpl files
- **Deployment**: GitHub remote with local working directory
- **Details**: See [omni-config/README.md](omni-config/README.md) for comprehensive configuration details

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
# 1. Edit configs in /cluster-nas/colab/colab-config/omni-config/
# 2. Commit and push changes to GitHub
git add omni-config/
git commit -m "Update configurations"
git push origin main

# 3. Apply updates across cluster via GitHub remote
for node in crtr prtr drtr; do
    ssh "$node" "chezmoi update"
done

# 4. Validate template rendering and functionality
for node in crtr prtr drtr; do
    ssh "$node" "chezmoi data | grep node_role && source ~/.zshrc"
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