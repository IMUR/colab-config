# Strategic Ansible Implementation for Hybrid Approach

**Philosophy**: Minimal system-level operations complementing chezmoi user configurations
**Scope**: Infrastructure, security, monitoring, and service management only

## Directory Structure

### Core Infrastructure
- **infrastructure/**: Core cluster setup (NFS, networking, system preparation)
- **security/**: Security baseline (SSH hardening, firewall, fail2ban)
- **monitoring/**: System health monitoring and performance tracking

### Service Management
- **services/**: Node-specific service configurations
- **validation/**: Omni-config integration and validation orchestration

### Tools & Health
- **tools/**: Modern CLI tool installation (system-level only, no user configs)
- **health/**: Health monitoring and system validation
- **deployment/**: Legacy system preparation scripts

## Strategic Hybrid Principles

### ✅ Ansible Domain (System-Level)
- Package installation and system dependencies
- Service configuration and management
- Security hardening and firewall rules
- System monitoring and health checks
- Infrastructure setup (NFS, networking)
- Cross-node orchestration and validation

### ❌ NOT Ansible Domain (User-Level)
- Shell configurations (.bashrc, .zshrc, .profile)
- User dotfiles and personalization
- Tool-specific configurations (starship.toml, etc.)
- User environment variables and aliases
- Development environment setup

### 🔄 Bridge Components
- Chezmoi installation and system preparation
- Validation script deployment
- System-wide PATH configuration
- Tool availability detection (not configuration)

## Key Playbooks

### Essential Infrastructure
```bash
# Complete cluster infrastructure setup
ansible-playbook playbooks/infrastructure/cluster-infrastructure.yml

# Security baseline for all nodes
ansible-playbook playbooks/security/security-baseline.yml

# System monitoring setup
ansible-playbook playbooks/monitoring/system-monitoring.yml
```

### Service Management
```bash
# Configure node-specific services
ansible-playbook playbooks/services/node-specific-services.yml

# Install modern CLI tools (system-level only)
ansible-playbook playbooks/tools/modern-cli-tools.yml
```

### Integration & Validation
```bash
# Prepare systems for omni-config deployment
ansible-playbook playbooks/validation/omni-config-integration.yml

# Health monitoring and validation
ansible-playbook playbooks/health/cluster-health.yml
```

## Complete Deployment Workflow

### 1. System Foundation
```bash
# Infrastructure and security
ansible-playbook playbooks/infrastructure/cluster-infrastructure.yml
ansible-playbook playbooks/security/security-baseline.yml
ansible-playbook playbooks/monitoring/system-monitoring.yml
```

### 2. Service Configuration
```bash
# Node-specific services and tools
ansible-playbook playbooks/services/node-specific-services.yml
ansible-playbook playbooks/tools/modern-cli-tools.yml
```

### 3. User Configuration Bridge
```bash
# Prepare for and deploy omni-config
ansible-playbook playbooks/validation/omni-config-integration.yml
```

### 4. Validation & Monitoring
```bash
# Ongoing health monitoring
ansible-playbook playbooks/health/cluster-health.yml

# Manual validation commands
cluster-validate standard
cluster-validate changes
```

## Safety Guidelines

### Risk Management
- **Low-Risk Operations**: Package installation, service management, monitoring setup
- **Medium-Risk Operations**: Security configuration, firewall rules (with fallbacks)
- **Avoided Operations**: Complex system modifications, user directory changes

### Rollback Strategies
- All configuration files backed up automatically
- Service configurations can be reverted via systemctl
- Firewall rules can be reset via `ufw --force reset`
- SSH configuration tested before applying changes

### Validation Approach
- Each playbook includes validation tasks
- System health checks after major changes
- Integration with omni-config validation scripts
- Monitoring setup for ongoing health tracking

## Integration with Omni-Config

### Clear Boundaries
- **Ansible**: System preparation and infrastructure
- **Chezmoi**: User experience and shell configurations
- **Bridge**: Validation and orchestration scripts

### Workflow Integration
1. Ansible prepares system infrastructure
2. Ansible installs and configures chezmoi
3. Omni-config deploys via chezmoi
4. Validation scripts (deployed by ansible) verify complete setup
5. Monitoring (ansible) tracks ongoing health

### Shared Resources
- `/usr/local/bin/cluster-*` commands for system management
- `/etc/profile.d/` for system-wide environment (minimal)
- Validation scripts accessible system-wide
- Monitoring and health check integration

## Available Commands Post-Deployment

### System Management
- `cluster-health-check` - Automated health diagnostics
- `cluster-security-status` - Security monitoring
- `cluster-dashboard` - Real-time monitoring
- `cluster-tools-check` - Tool availability verification

### Service Management
- `cooperator-status` / `projector-status` / `director-status`
- `cluster-validate` - Omni-config validation wrapper

### Monitoring & Maintenance
- Automated health checks every 5 minutes
- Daily performance reports
- Weekly log cleanup
- Security monitoring with fail2ban

## Strategic Advantages

### Operational Benefits
- **Clear Separation**: No overlap between system and user domains
- **Safety First**: Minimal system modifications reduce risk
- **Validation Integration**: Comprehensive validation across domains
- **Monitoring Coverage**: System health and user configuration validation

### Maintenance Benefits
- **Focused Updates**: System changes via ansible, user changes via chezmoi
- **Independent Rollback**: System and user configurations managed separately
- **Comprehensive Monitoring**: Full-stack health and performance tracking
- **Documentation**: Self-documenting through command availability
