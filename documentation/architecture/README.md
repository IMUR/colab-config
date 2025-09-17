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

## Migration Architecture

### Current State (Stable)
- **Universal Configs**: Symlinks to `/cluster-nas/configs/zsh/`
- **Working System**: All nodes functional with shared configurations
- **Proven Reliability**: Battle-tested setup

### Target State (Planned)
- **Universal Configs**: Chezmoi-based omni-config deployment
- **Enhanced Flexibility**: Node-specific templating capability
- **Improved Management**: Git-based configuration source of truth

### Migration Strategy
1. **Phase 1**: Repository establishment (complete)
2. **Phase 2**: Parallel testing (symlinks + chezmoi)
3. **Phase 3**: Gradual cutover maintaining stability
4. **Phase 4**: Full chezmoi deployment with symlink removal

## Monitoring and Maintenance

### Health Monitoring
- **Ansible Playbooks**: Automated health checks
- **Service Monitoring**: systemd service status tracking
- **Resource Monitoring**: CPU, memory, disk usage via Cockpit
- **Network Monitoring**: Connectivity and performance checks

### Maintenance Procedures
- **Updates**: Coordinated via Ansible automation
- **Configuration Changes**: Version-controlled via git
- **Service Management**: Centralized via Semaphore UI
- **Backup Verification**: Automated backup integrity checks

This architecture provides high availability, scalability, and maintainability while supporting both shared infrastructure and specialized workload requirements.