# CLAUDE.md

This file provides guidance when working with the Co-lab cluster infrastructure configuration repository.

## Repository Overview

This repository (`colab-config`) contains comprehensive infrastructure configuration for the 3-node Co-lab cluster. It serves as the authoritative source for cluster automation, user environment configurations, service management, and deployment procedures.

## CURRENT STATUS: Strategic Hybrid Configuration Repository ✅

**Repository Type**: Comprehensive Infrastructure Configuration Management  
**Scope**: 3-node cluster (cooperator, projector, director)
**Methodology**: **Strategic Hybrid** - Minimal Ansible + Pure Chezmoi + Service Configs  
**Safety Level**: Production-ready with layered risk management

**Repository Structure:**
```
colab-config/
├── 🎯 omni-config/             # PRIMARY: User environments (chezmoi)
├── 🔧 ansible/                 # MINIMAL: System health & monitoring  
├── 🛠️ services/                # Service-specific configurations
├── 🏗️ infrastructure/          # SSH, tooling, system configs
├── 📜 scripts/                 # Utility automation scripts
├── 📚 documentation/           # Architecture and deployment guidance
└── 🧭 AI-AGENT-QUICKSTART.md   # Agent assessment guide
```

## Cluster Architecture

**Core Cluster Nodes:**
- **cooperator (crtr)** - Gateway, NFS server, DNS, services (Pi5, 16GB RAM, 192.168.254.10)
- **projector (prtr)** - Compute power, multi-GPU (x86, 128GB RAM, 192.168.254.20)
- **director (drtr)** - ML platform, single GPU (x86, 64GB RAM, 192.168.254.30)

**Mobile Access Point (Independent):**
- **snitcher** - Remote access laptop (separate snitcher-config repository)

## Infrastructure Services Context

### Web Interfaces (via cooperator gateway)
- **Semaphore**: https://cfg.ism.la (Ansible automation UI)
- **Cockpit**: https://mng.ism.la (System management)
- **SSH Terminal**: https://ssh.ism.la (Web-based terminal)
- **DNS Management**: https://dns.ism.la (Pi-hole interface)

### Core Infrastructure
- **NFS Server**: Shared storage at `/cluster-nas` (on cooperator)
- **Pi-hole DNS**: Internal `.ism.la` domain resolution (on cooperator)
- **Caddy Proxy**: Web service routing and SSL (on cooperator)
- **Configuration Management**: Hybrid approach (minimal ansible + pure chezmoi)

## Strategic Hybrid Configuration Approach

### **Architectural Decision Context**

**System-Level (Minimal Ansible)**:
- Package installation and essential system services
- Health monitoring and system validation capabilities
- /etc/profile.d/ system-wide environment when needed
- Focused, low-risk operations preserving system stability

**User-Level (Pure Chezmoi)**:
- Rich shell environments with modern tool integration
- Cross-node consistency with intelligent tool detection
- Node-specific customization through templating (when implemented)
- User configuration domain with safe rollback capabilities

**Service & Infrastructure Management**:
- Service-specific configurations in services/ directory
- Infrastructure tooling and SSH configurations
- Utility scripts for specialized cluster operations
- Independent management appropriate to each domain

### **Strategic Advantages**
```yaml
Right Tool Selection:
  - Ansible: System administration, monitoring, infrastructure
  - Chezmoi: User dotfiles, cross-machine consistency
  - Service configs: Domain-specific management

Risk Management:
  - User-level changes preserve SSH access
  - System-level changes minimal and targeted
  - Service configurations isolated from core infrastructure

Operational Efficiency:
  - Fast user configuration deployment
  - Simple rollback procedures
  - Clear separation of concerns
  - Agent-friendly documentation and workflows
```

## Working with This Repository

### **Configuration Management Workflows**

#### **User Environment Management (Primary)**
```bash
# Context: omni-config/ contains user shell and tool configurations
# Approach: Pure chezmoi deployment for cross-node consistency

# Assessment suggestion:
ssh drtr "chezmoi diff"  # Preview changes on least critical node

# Deployment suggestion:  
for node in crtr prtr drtr; do
    ssh "$node" "chezmoi apply"  # Apply user configuration changes
done

# Validation approach:
for node in crtr prtr drtr; do
    ssh "$node" 'source ~/.zshrc && echo "$node: user environment ready"'
done
```

#### **System Infrastructure (Minimal Use)**
```bash
# Context: ansible/ contains system monitoring and basic infrastructure
# Constraint: Many playbooks have been removed due to safety concerns
# Suggestion: Use only validated safe operations

# Health assessment:
ansible-playbook ansible/playbooks/cluster-health.yml  # If available

# Basic connectivity:
ansible all -m ping  # System reachability validation
```

#### **Service & Infrastructure Configuration**
```bash
# Context: services/ and infrastructure/ contain specialized configurations
# Approach: Domain-specific management as needed

# SSH configuration assessment:
[[ -f "infrastructure/ssh/remote-access-config" ]] && echo "SSH gateway config available"

# Service configuration evaluation:
[[ -d "services/semaphore" ]] && echo "Semaphore automation config present"

# Utility script availability:
ls scripts/*.sh  # Available automation utilities
```

### **Development Philosophy**

**User-First Approach**:
- omni-config/ provides rich user experience foundation
- User-level changes preserve system access and stability
- Fast iteration through chezmoi vs complex system orchestration

**System-Minimal Approach**:
- Ansible usage limited to essential system operations
- Health monitoring and basic infrastructure only
- Avoid complex system modifications that introduce risks

**Service-Specific Management**:
- Service configurations managed independently
- Infrastructure tooling separate from user environments
- Utility scripts for specialized operations

## Critical Infrastructure Context

### **Current Working Configuration (Preserve)**
```yaml
UID/GID Strategy (DO NOT MODIFY):
  - cooperator (crtr): UID 1001, GID 1001 + cluster(2000) - NFS ownership
  - projector (prtr): UID 1000, GID 1000 + cluster(2000) - standard user
  - director (drtr): UID 1000, GID 1000 + cluster(2000) - standard user

File Permissions (NFS Compatibility):
  - 777/666 permissions required for shared applications
  - Security trade-off acceptable within trusted cluster network
  - Cluster group (GID 2000) provides shared access without UID conflicts
```

### **Safety Context**

**User-Level Safety (Primary Domain)**:
- Configuration errors preserve SSH access
- Fast rollback through chezmoi state management
- Simple validation through shell source testing
- Isolated impact - shell configs don't affect system services

**System-Level Caution**:
- Minimal ansible usage reduces system modification risks
- Health monitoring provides visibility without changes
- Service management isolated from user configuration deployment

## Repository Integration

### **Configuration Domains**
```yaml
User Environments:
  - Managed through omni-config/ and chezmoi deployment
  - Cross-node consistency with node-specific adaptation
  - Modern shell experience with tool detection and fallbacks

System Infrastructure:
  - Minimal ansible for essential system operations
  - Health monitoring and connectivity validation
  - Basic system preparation when needed

Service Management:
  - Service-specific configurations in services/
  - Infrastructure tooling in infrastructure/
  - Specialized automation through scripts/
```

### **Documentation Ecosystem**
- **AI-AGENT-QUICKSTART.md**: Comprehensive assessment guide for agents
- **documentation/architecture/COLAB-CLUSTER-ARCHITECTURE.md**: Complete hybrid strategy and implementation details
- **omni-config/documentation/**: User environment design philosophy and technical details

### **Agent Integration Context**

**Assessment Approach**:
- Multi-domain evaluation (user, system, services, infrastructure)
- Risk-appropriate strategies for each configuration domain
- Collaborative decision-making support through contextual guidance

**Implementation Flexibility**:
- Agents may choose appropriate scope based on cluster conditions
- Multiple rollback and recovery options available
- Clear separation of concerns supports targeted interventions

**Documentation Philosophy**:
- Context over commands - provide decision-making information
- Collaborative language supporting multiple agent workflows
- Honest assessment of current capabilities vs future possibilities

## Repository Relationships

### **Related Infrastructure**
- **snitcher-config**: Independent mobile access configuration
- **Cluster NFS**: Shared storage infrastructure (`/cluster-nas`)
- **Service Infrastructure**: Web interfaces, automation, monitoring

### **Configuration Flow**
- **Source of Truth**: This repository for infrastructure configuration
- **User Deployment**: omni-config/ via chezmoi to user environments
- **System Operations**: Minimal ansible for essential infrastructure
- **Service Management**: Domain-specific configurations as needed

This repository supports comprehensive cluster infrastructure management through strategic tool selection and clear separation of concerns, enabling safe and efficient operations across all configuration domains.