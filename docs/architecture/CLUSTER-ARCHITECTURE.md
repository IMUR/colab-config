---
meta:
  document_type: "cluster_architecture"
  scope: "complete_3_node_cluster_design"
  last_updated: "2025-09-27"
  validation_status: "operational"
agent_context:
  purpose: "Complete Co-lab cluster architecture documentation"
  technical_domains: ["hardware", "networking", "services", "storage"]
  safe_operations: ["architecture_reading", "specification_analysis"]
  restricted_operations: ["infrastructure_modification", "service_changes"]
---

# Co-lab Cluster Architecture

Complete architectural documentation for the 3-node Co-lab cluster implementing hybrid configuration management with Ansible + Chezmoi.

## Node Architecture

### cooperator (crtr) - Gateway & Services Node
**Hardware**: Raspberry Pi 5, 16GB RAM, ARM64 architecture
**Role**: Cluster gateway, infrastructure services, network controller
**Network**: 192.168.254.10 (static), public internet gateway
**UID**: 1001 (required for NFS file ownership)

**Primary Services**:
- **NFS Server**: Shared storage for entire cluster (`/cluster-nas`)
- **Pi-hole DNS**: Internal `.ism.la` domain resolution
- **Caddy Reverse Proxy**: Web service routing and SSL termination
- **Ansible Controller**: Configuration management hub
- **Cockpit**: Web-based system management
- **Semaphore**: Ansible automation UI

### projector (prtr) - Compute Power Node
**Hardware**: x86_64, 128GB RAM, Multi-GPU configuration (4x GPU: 2x GTX 1080, 2x GTX 970)
**Role**: High-performance computing, ML training, burst processing
**Network**: 192.168.254.20 (static)
**UID**: 1000 (standard user)

**Primary Services**:
- **GPU Workloads**: CUDA, machine learning frameworks
- **Development Environments**: Code compilation, testing
- **Compute Orchestration**: Heavy processing tasks

### director (drtr) - ML Platform Node
**Hardware**: x86_64, 64GB RAM, Single dedicated GPU (RTX 2080)
**Role**: Machine learning platform, model serving, specialized ML workloads
**Network**: 192.168.254.30 (static)
**UID**: 1000 (standard user)

**Primary Services**:
- **ML Frameworks**: PyTorch, TensorFlow deployment
- **Model Serving**: Inference endpoints
- **Data Processing**: ML pipeline execution

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

## Modern Hybrid Configuration Strategy

### Hybrid Management Approach
**Philosophy**: Right tool for the right job, minimal system intervention

**Chezmoi (User Environment)**:
- User dotfiles and shell configurations
- Modern CLI tools and development environments
- Node-specific template rendering
- Safe rollback capabilities

**Ansible (System Infrastructure)**:
- System package installation
- Service configuration
- Network setup and security
- GPU drivers and system-level optimization

### Template System
**Universal Configurations**: Identical across all 3 nodes
- Shell environments (zsh, bash)
- Modern CLI tools (eza, bat, fd, rg, fzf)
- Development tooling (git, tmux)
- Universal aliases and functions

**Node-Specific Configurations**:
- **cooperator**: NFS, DNS, proxy, gateway networking
- **projector**: Multi-GPU drivers, high-memory optimization
- **director**: ML frameworks, single GPU optimization

### Deployment Strategy
**Method**: GitHub remote deployment via Chezmoi
```bash
chezmoi init --apply https://github.com/IMUR/colab-config.git
```

**Benefits**:
- 15-minute deployments
- Zero system risk (user-level changes only)
- Cross-node consistency via templates
- Node-specific adaptation via .chezmoi.toml.tmpl
- Simple git workflow (edit → commit → push → chezmoi update)

## Service Distribution

### Infrastructure Services (cooperator)
- NFS Server: Shared storage backbone
- Pi-hole DNS: .ism.la domain resolution
- Caddy Proxy: Web service routing
- Ansible Hub: Configuration management
- Monitoring: Cluster health and performance

### Compute Services (projector)
- CUDA Workloads: GPU-accelerated computing
- Development: Code compilation and testing
- Data Processing: Large dataset operations

### ML Platform (director)
- Model Training: Specialized ML workloads
- Inference Serving: Model deployment endpoints
- Research: ML experimentation environment

## Success Criteria & Validation

### Operational Achievements ✅
- **15-minute deployments**: GitHub remote deployment significantly faster
- **Zero system risk**: User-level changes preserve SSH access
- **Cross-node consistency**: Identical user experience via templates
- **Node-specific adaptation**: Configs adapt to roles via templates
- **Maintainer efficiency**: Simple git workflow

### User Experience ✅
- **Modern shell**: Both ZSH and Bash with starship prompt
- **Smart tool detection**: Handles missing tools gracefully
- **Performance**: Optimized shell startup with timing monitoring
- **Consistency**: Same aliases, functions, integrations everywhere
- **Cross-shell compatibility**: Unified experience in bash and zsh

### System Administration ✅
- **Minimal ansible**: System-level operations only when necessary
- **Template system**: Professional dotfile management
- **Safe operations**: No dangerous system modifications
- **Rollback capability**: Multiple recovery mechanisms

## Integration Points

### Critical Applications
- **Archon Services**: Container orchestration and management
- **Ollama Services**: Local LLM deployment and management
- **Development Environments**: Integrated development tooling

### External Dependencies
- **GitHub Repository**: Configuration source and version control
- **NFS Storage**: Shared file access and configuration persistence
- **Internet Gateway**: External service access via cooperator

This architecture successfully balances performance, reliability, and operational simplicity while providing a solid foundation for cluster computing and machine learning workloads.