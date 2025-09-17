# Co-lab Cluster Architecture

## Overview

The co-lab cluster implements a **3-node core architecture** designed for high availability, shared storage, and specialized workload distribution.

## Node Architecture

### cooperator (crtr) - Gateway & Services Node
- **Hardware**: Raspberry Pi 5, 16GB RAM, ARM64 architecture
- **Role**: Cluster gateway, infrastructure services, network controller
- **Primary Services**:
  - **NFS Server**: Shared storage for entire cluster (`/cluster-nas`)
  - **Pi-hole DNS**: Internal `.ism.la` domain resolution
  - **Caddy Reverse Proxy**: Web service routing and SSL termination
  - **Ansible Controller**: Configuration management hub
  - **Cockpit**: Web-based system management
  - **Semaphore**: Ansible automation UI
- **Network**: 192.168.254.10 (static), public internet gateway
- **UID**: 1001 (required for NFS file ownership)

### projector (prtr) - Compute Power Node
- **Hardware**: x86_64, 128GB RAM, Multi-GPU configuration
- **Role**: High-performance computing, ML training, burst processing
- **Primary Services**:
  - **GPU Workloads**: CUDA, machine learning frameworks
  - **Development Environments**: Code compilation, testing
  - **Compute Orchestration**: Heavy processing tasks
- **Network**: 192.168.254.20 (static)
- **UID**: 1000 (standard user)

### director (drtr) - ML Platform Node
- **Hardware**: x86_64, 64GB RAM, Single dedicated GPU
- **Role**: Machine learning platform, model serving, specialized ML workloads
- **Primary Services**:
  - **ML Frameworks**: PyTorch, TensorFlow deployment
  - **Model Serving**: Inference endpoints
  - **Data Processing**: ML pipeline execution
- **Network**: 192.168.254.30 (static)
- **UID**: 1000 (standard user)

## Network Architecture

### Internal Network: 192.168.254.0/24
- **Gateway**: cooperator (192.168.254.10)
- **DNS**: Pi-hole on cooperator (.ism.la domain)
- **NFS**: Shared storage from cooperator
- **Inter-node**: Direct SSH connectivity using ed25519 keys

### External Access
- **Public IP**: Via cooperator gateway
- **Port Forwarding**: 22 (SSH), 80 (HTTP), 443 (HTTPS)
- **Web Services**: Proxied through Caddy on cooperator
- **Remote Access**: SSH jump host through cooperator

## Storage Architecture

### Shared Storage (NFS)
- **Server**: cooperator (crtr)
- **Mount Point**: `/cluster-nas` on all nodes
- **Contents**: Configurations, shared data, cluster resources
- **Permissions**: 777/666 (world-writable for application compatibility)
- **Backup**: Daily automated backups with rotation

### Local Storage
- **Node-specific**: Each node maintains local system storage
- **Caching**: Local caches for performance optimization
- **Logs**: Node-specific logging to local storage

## Configuration Management

### Universal Configurations (omni-config)
**Target**: Identical across all 3 nodes
- Shell environments (zsh, bash)
- Modern CLI tools (eza, bat, fd, rg, fzf)
- Development tooling (git, tmux)
- Universal aliases and functions

**Current State**: Symlinks to `/cluster-nas/configs/zsh/`
**Migration Target**: Chezmoi-based deployment

### Node-Specific Configurations
**cooperator-specific**:
- NFS server configuration
- Pi-hole DNS settings
- Caddy reverse proxy rules
- Gateway networking setup

**projector-specific**:
- Multi-GPU drivers and configuration
- High-memory optimization
- Compute environment setup

**director-specific**:
- ML framework configuration
- Single GPU optimization
- Model serving environments

## Service Distribution

### Infrastructure Services (cooperator)
- **DNS Resolution**: Pi-hole
- **Web Proxy**: Caddy
- **File Sharing**: NFS
- **Automation**: Ansible + Semaphore
- **Monitoring**: Cockpit
- **Backup**: Automated backup system

### Compute Services (projector + director)
- **Development**: Code environments, compilation
- **Machine Learning**: Model training and inference
- **Data Processing**: Large-scale data operations
- **Application Hosting**: User applications and services

## Security Model

### Network Security
- **Internal Network**: Private 192.168.254.0/24
- **External Access**: Only through cooperator gateway
- **SSH Keys**: Ed25519 authentication only
- **Service Isolation**: Services bound to specific interfaces

### Access Control
- **User Management**: Cluster group (GID 2000) for shared access
- **File Permissions**: NFS-compatible world-writable approach
- **SSH Access**: Key-based authentication, no passwords
- **Service Authentication**: Individual service-level security

### Backup and Recovery
- **Daily Backups**: All configurations and critical data
- **Version Control**: Git-based configuration tracking
- **Rollback Capability**: Ansible-based restoration
- **Multiple Access Points**: Console, SSH, web interfaces

## Modern Hybrid Configuration Strategy

### **Strategic Decision: Hybrid Approach** ✅ **ADOPTED**

**OBJECTIVE**: Implement the most effective configuration management strategy by using the right tool for the right job, following 2024 industry best practices.

### **Tool Separation Strategy**

**System-Level Configuration (Minimal Ansible)**:
- **Scope**: Package installation, system services, /etc/ configurations only
- **Justification**: Ansible excels at idempotent system administration
- **Examples**: Installing packages, managing systemd services, creating system users
- **Risk Level**: Moderate (requires root, affects system stability)
- **Frequency**: Infrequent (initial setup, major system changes)

**User-Level Configuration (Pure Chezmoi)**:
- **Scope**: Dotfiles, shell environments, user-specific tool configurations
- **Justification**: Chezmoi is purpose-built for cross-machine dotfile consistency
- **Examples**: .zshrc, .profile, .config/starship.toml, user aliases
- **Risk Level**: Low (user-level only, preserves SSH access)
- **Frequency**: Regular (daily configuration refinements)

### **Current State Analysis**

**Production Reality (DO NOT BREAK)**:
- ✅ **Symlinks Active**: All 3 nodes use `/cluster-nas/configs/zsh/zshrc` symlinks
- ✅ **NFS Dependency**: Shared storage provides instant cluster-wide updates  
- ✅ **Battle Tested**: Current system stable, in daily production use
- ✅ **User Experience**: Modern shell with eza, bat, fzf already working

**Migration Drivers**:
- 🎯 **Node-Specific Templating**: Different aliases/configs per node role
- 🎯 **Offline Capability**: Chezmoi stores configs locally (backup if NFS fails)
- 🎯 **Version Control**: Git-tracked changes vs direct file edits
- 🎯 **Proper Tool Usage**: Use chezmoi for what it's designed for

### **Target State Architecture**

**System-Wide Foundation (Minimal Ansible)**:
```bash
/etc/profile.d/cluster-base.sh:
  - Basic PATH management (/usr/local/bin, ~/.local/bin)
  - Cluster-wide environment variables (CLUSTER_NODE, etc.)
  - Tool availability for ALL users (including root)
  - Emergency fallback configurations

System Package Management:
  - Core packages (zsh, tmux, git, modern CLI tools)
  - Architecture-specific packages (x86 vs ARM)
  - Development dependencies (build-essential, etc.)
```

**User Configuration Layer (Pure Chezmoi)**:
```bash
~/.profile:
  - Rich tool detection (HAS_* flags)
  - User-specific PATH additions
  - Development environment setup

~/.zshrc:
  - Modern shell features (history, completion)
  - Tool integrations (starship, fzf, zoxide)
  - Node-specific aliases and functions

~/.config/starship.toml:
  - Templated prompt configuration
  - Node-role specific prompt elements
```

### **Implementation Strategy: Zero-Downtime Migration**

**Phase 1: Foundation Completion** ⚡ **IMMEDIATE** (30 minutes)
```bash
Technical Implementation Required:
1. Create .chezmoi.toml.tmpl with node templating
2. Add template variables to dot_zshrc ({{ .chezmoi.hostname }})
3. Structure omni-config/ as proper chezmoi source
4. Test deployment on director (drtr) - least critical node

Validation Criteria:
- Chezmoi templates render correctly per node
- Shell functionality preserved/enhanced
- Easy rollback confirmed (rm ~/.local/share/chezmoi)
```

**Phase 2: Safe System Preparation** ⚡ **IMMEDIATE** (15 minutes)
```bash
Ansible Cleanup Required:
1. DELETE dangerous playbooks:
   - uid-standardization.yml (will break cluster)
   - tool-standardization.yml (security issues)
   - system-update.yml (dist-upgrade danger)

2. KEEP useful minimal ansible:
   - cluster-health.yml (monitoring)
   - chezmoi-audit.yml (validation)
   - service-status.yml (basic health)

3. CREATE minimal system-environment.yml:
   - Install core packages only
   - Basic /etc/profile.d/cluster-base.sh
   - No dangerous system modifications
```

**Phase 3: Gradual User Configuration Migration** 📋 **PLANNED** (20 minutes)
```bash
Deployment Sequence:
1. Install chezmoi binary on all nodes (user-level)
2. Copy omni-config to /cluster-nas/configs/colab-omni-config/
3. Deploy to director first (validation node)
4. Deploy to projector and cooperator
5. Validate modern shell experience across cluster

Rollback Strategy:
- Remove ~/.local/share/chezmoi
- Symlinks remain as fallback
- No system-level changes to reverse
```

**Phase 4: Symlink Retirement** 📋 **FUTURE** (10 minutes)
```bash
After 30-day validation period:
1. Confirm chezmoi stability across all use cases
2. Archive symlink configurations to /cluster-nas/archive/
3. Update documentation to reflect chezmoi-primary approach
4. Clean up old configuration directories
```

### **Steady State Goals & Success Criteria**

**Operational Objectives**:
- ✅ **20-minute deployments**: Configuration changes deploy rapidly
- ✅ **Zero system risk**: User-level changes preserve SSH access
- ✅ **Cross-node consistency**: Same user experience on all nodes
- ✅ **Node-specific adaptation**: Configs adapt to node roles automatically
- ✅ **Maintainer efficiency**: Simple git workflow for configuration changes

**User Experience Objectives**:
- ✅ **Modern shell**: ZSH with starship prompt, modern tools
- ✅ **Smart tool detection**: Handles missing tools gracefully
- ✅ **Performance**: Sub-100ms shell startup times
- ✅ **Consistency**: Same aliases, functions, integrations everywhere

**System Administration Objectives**:
- ✅ **Minimal ansible**: System-level operations only when necessary
- ✅ **Health monitoring**: Automated cluster health validation
- ✅ **Safe operations**: No dangerous system modifications
- ✅ **Emergency access**: Multiple access methods preserved

### **Reasoning Behind Radical Aspects**

**Why Abandon Complex Ansible Orchestration?**
```yaml
EVIDENCE-BASED DECISION:
❌ Current ansible playbooks: 75% broken/dangerous
❌ Complex orchestration: Hours to deploy, high risk
❌ Wrong tool choice: Using ansible for dotfile management

✅ Hybrid approach: Right tool for right job
✅ Industry standard: Ansible for systems, Chezmoi for users
✅ Risk reduction: User-level changes only
✅ Speed improvement: 20 minutes vs hours
```

**Why Preserve Symlink Approach During Transition?**
```yaml
SAFETY-FIRST REASONING:
✅ Production stability: Current system works
✅ Zero-downtime migration: No disruption to daily operations  
✅ Emergency fallback: Proven working configuration available
✅ Risk mitigation: Two working systems better than one broken system
```

**Why User-Level Focus?**
```yaml
OPERATIONAL EVIDENCE:
✅ SSH access preservation: Configuration errors won't lock out users
✅ Service isolation: Shell configs don't affect critical services (DNS, NFS)
✅ Fast rollback: Delete ~/.local/share/chezmoi vs complex system restoration
✅ Individual user impact: Problems affect single user, not entire cluster
```

### **Critical Success Factors**

**Technical Requirements**:
1. **Chezmoi templating functional**: .chezmoi.toml.tmpl with node detection
2. **Source structure correct**: omni-config/ formatted as chezmoi source
3. **NFS accessibility maintained**: /cluster-nas/configs/colab-omni-config/ available
4. **Rollback tested**: Proven procedures for quick reversion

**Operational Requirements**:
1. **User experience preserved**: No degradation in shell functionality
2. **Node-specific adaptation**: Templates render correctly per node
3. **Performance maintained**: Shell startup times remain fast
4. **Documentation alignment**: All guides reflect hybrid approach consistently

This architecture enables **modern, safe, efficient configuration management** while preserving production stability and operational safety.
