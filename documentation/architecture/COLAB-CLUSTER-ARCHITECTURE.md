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
- **Examples**: .zshrc.tmpl, .bashrc.tmpl, .profile, .config/starship.toml, user aliases
- **Template System**: .tmpl files with shared includes (.chezmoitemplate files)
- **Deployment**: GitHub remote (https://github.com/IMUR/colab-config.git)
- **Risk Level**: Low (user-level only, preserves SSH access)
- **Frequency**: Regular (daily configuration refinements)

### **Current State Analysis**

**Production Reality ✅ IMPLEMENTED**:
- ✅ **Chezmoi Active**: All 3 nodes use GitHub remote deployment
- ✅ **Template System**: Node-specific rendering (cooperator/projector/director roles)
- ✅ **Unified Shell Management**: Both bash and zsh with shared NVM loading
- ✅ **No NFS Dependency**: Each node operates independently after initialization
- ✅ **Battle Tested**: Template system stable, in daily production use
- ✅ **User Experience**: Modern shell with eza, bat, fzf, starship working consistently

**Implementation Achievements**:
- ✅ **Node-Specific Templating**: Different configs per node role via .chezmoi.toml.tmpl
- ✅ **Offline Capability**: Chezmoi stores configs locally (no NFS dependency)
- ✅ **Version Control**: Git-tracked changes with GitHub remote workflow
- ✅ **Proper Tool Usage**: Chezmoi templates with shared includes (.chezmoitemplate files)
- ✅ **Cross-Shell Support**: Unified bash (.bashrc.tmpl) and zsh (.zshrc.tmpl) environments

### **Current Implemented Architecture** ✅

**System-Wide Foundation (Minimal Ansible)**:
```bash
/etc/profile.d/cluster-base.sh:
  - Basic PATH management (/usr/local/bin, ~/.local/bin)
  - Cluster-wide environment variables (CLUSTER_NODE, etc.)
  - Tool availability for ALL users (including root)
  - Emergency fallback configurations
```

**User Configuration Layer (Pure Chezmoi with Templates)**:
```bash
~/.profile:
  - Rich tool detection (HAS_* flags)
  - NVM_DIR environment variable (no manual PATH management)
  - User-specific PATH additions
  - Development environment setup

~/.zshrc (from dot_zshrc.tmpl):
  - Modern shell features (history, completion)
  - Tool integrations (starship, fzf, zoxide, atuin)
  - Shared NVM loading via template include
  - Node-specific aliases and functions via templating

~/.bashrc (from dot_bashrc.tmpl):
  - Interactive bash environment with modern tool support
  - Unified tool integration matching zsh environment
  - Shared NVM loading via template include
  - Starship prompt with fallback to colorized bash prompt

~/.config/starship.toml:
  - Professional prompt configuration
  - Cluster-aware elements and shortcuts
  - Cross-shell compatibility (bash and zsh)

Shared Templates:
.chezmoitemplate.nvm-loader.sh:
  - Unified NVM shell function loading
  - Bash completion support
  - Error handling and existence checks
```

### **Implementation Status: Completed Successfully** ✅

**Phase 1: Foundation Implementation** ✅ **COMPLETED**
```bash
Technical Implementation Achieved:
✅ Created .chezmoi.toml.tmpl with node templating (cooperator/projector/director)
✅ Converted shell configs to templates (dot_zshrc.tmpl, dot_bashrc.tmpl)
✅ Implemented shared template system (.chezmoitemplate.nvm-loader.sh)
✅ Structured omni-config/ as proper chezmoi source with .chezmoiroot
✅ Deployed to all nodes via GitHub remote

Validation Results:
✅ Chezmoi templates render correctly per node with specific roles
✅ Shell functionality enhanced (unified bash + zsh environments)
✅ Easy rollback confirmed (chezmoi forget + GitHub remote re-init)
```

**Phase 2: GitHub Remote Deployment** ✅ **COMPLETED**
```bash
Implementation Achieved:
✅ GitHub remote deployment: https://github.com/IMUR/colab-config.git
✅ .chezmoiroot configuration for omni-config subdirectory usage
✅ No NFS dependency for chezmoi operations
✅ Template processing with node-specific variables
✅ Unified update workflow: commit → push → chezmoi update

Operational Benefits:
✅ 15-minute deployment time (improved from 20+ minutes)
✅ Industry-standard Git workflow
✅ No single point of failure dependency
✅ Professional template system with shared includes
```

**Phase 3: Unified Shell Management** ✅ **COMPLETED**
```bash
Implementation Achieved:
✅ Both bash and zsh environments managed by chezmoi templates
✅ Shared NVM loading template eliminates code duplication
✅ Node-specific customization via .chezmoi.toml.tmpl variables
✅ Consistent tool integration across all shells and nodes
✅ Fixed PATH and tool availability issues (zoxide, starship, NVM)

Rollback Strategy Available:
- chezmoi forget --force (remove chezmoi management)
- chezmoi init --apply https://github.com/IMUR/colab-config.git (re-initialize)
- No system-level changes to reverse
```

### **Steady State Goals & Success Criteria**

**Operational Objectives** ✅ **ACHIEVED**:
- ✅ **15-minute deployments**: GitHub remote deployment significantly faster
- ✅ **Zero system risk**: User-level changes preserve SSH access
- ✅ **Cross-node consistency**: Identical user experience on all nodes via templates
- ✅ **Node-specific adaptation**: Configs adapt to node roles automatically via .chezmoi.toml.tmpl
- ✅ **Maintainer efficiency**: Simple git workflow (edit → commit → push → chezmoi update)

**User Experience Objectives** ✅ **ACHIEVED**:
- ✅ **Modern shell**: Both ZSH and Bash with starship prompt, modern tools
- ✅ **Smart tool detection**: Handles missing tools gracefully via HAS_* variables
- ✅ **Performance**: Optimized shell startup with timing monitoring
- ✅ **Consistency**: Same aliases, functions, integrations everywhere via templates
- ✅ **Cross-shell compatibility**: Unified experience in bash and zsh

**System Administration Objectives** ✅ **ACHIEVED**:
- ✅ **Minimal ansible**: System-level operations only when necessary
- ✅ **Template system**: Professional dotfile management with shared includes
- ✅ **Safe operations**: No dangerous system modifications, user-level only
- ✅ **Emergency access**: Multiple access methods preserved
- ✅ **NVM unification**: Consistent Node.js environment across all shells and nodes

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
