**📍 File Location**: `services/README.md`

---

# Service Configurations

**Context**: Independent service configuration management separate from user environments

**Scope**: Service-specific configurations, databases, keys, and specialized setups

## Strategic Approach

**Independence Principle**: Services managed separately from user environment (omni-config) and minimal system setup (ansible)

**Deployment**: Service-appropriate methods (manual setup, specialized scripts, service-specific automation)

**Integration**: Services may reference cluster infrastructure but don't depend on user configuration management approach

## Current Services

### **Semaphore (Ansible UI)**
- **Location**: `semaphore/`
- **Contents**: Database, SSH keys, configuration data  
- **Management**: Independent service configuration
- **Access**: https://cfg.ism.la

### **Configuration Templates**
- **Location**: `templates/` (now archived)
- **Contents**: Alternative configuration approaches
- **Status**: Archived to resolve conflicts with omni-config primary approach

## Service Management Philosophy

**Separation of Concerns**:
- User environments managed by omni-config/chezmoi
- System infrastructure managed by minimal ansible
- Service configurations managed independently as appropriate

**Service-Specific Deployment**:
- Each service may use most appropriate deployment method
- Service configurations don't interfere with user shell experience
- Independent rollback and maintenance procedures

**Cluster Integration**:
- Services reference cluster infrastructure (NFS, networking)
- Services don't depend on specific user configuration approach
- Service health independent of user environment deployment status
