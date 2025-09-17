# Co-lab Cluster Configuration Assessment Guide

**Target**: AI agents operating from snitcher  
**Scope**: Complete colab-config repository implementation  
**Approach**: **Strategic Hybrid** - Minimal Ansible + Pure Chezmoi  
**Context**: Production cluster requires careful assessment before any changes

## 🎯 **HYBRID CONFIGURATION STRATEGY**

**Decision**: Use minimal ansible for system-level operations, pure chezmoi for user configurations

**System-Level (Minimal Ansible)**:
- Package installation and basic system services
- /etc/profile.d/ system-wide environment when needed
- Health monitoring and system validation

**User-Level (Pure Chezmoi)**:
- Rich shell environments (.zshrc, .profile) 
- Modern CLI tools with cross-architecture detection
- Node-specific templating and customizations

**Infrastructure & Services**:
- SSH configuration templates (infrastructure/ssh/)
- Service-specific configurations (services/templates/)
- Utility scripts for cluster operations (scripts/)

## 📋 Repository Scope Assessment

**Constraint**: colab-config manages comprehensive cluster infrastructure, not just shell configurations

### **Configuration Domains to Evaluate**

**User Environment (omni-config/)**:
```bash
# Discovery suggestion: Agents may assess current user configuration state
for node in crtr prtr drtr; do
    ssh "$node" "
        echo '=== $node Configuration Status ==='
        [[ -L ~/.zshrc ]] && echo 'Config: Symlink to \$(readlink ~/.zshrc)' || echo 'Config: Local file'
        command -v chezmoi >/dev/null && echo 'Chezmoi: Available' || echo 'Chezmoi: Missing'
        echo
    "
done
```

**Infrastructure & Services (infrastructure/, services/)**:
```bash
# Discovery suggestion: Agents may evaluate infrastructure configurations
echo "=== Infrastructure Assessment ==="
[[ -f "infrastructure/ssh/remote-access-config" ]] && echo "SSH: Gateway configuration available"
[[ -f "infrastructure/starship/starship.toml" ]] && echo "Starship: Infrastructure variant exists"
[[ -f "infrastructure/fastfetch/config.jsonc" ]] && echo "Fastfetch: System info configuration"

echo "=== Service Configuration Assessment ==="
[[ -d "services/semaphore" ]] && echo "Semaphore: Ansible UI configuration present"
[[ -f "services/templates/modern-zshrc" ]] && echo "Templates: Alternative shell configurations"

echo "=== Utility Scripts Assessment ==="
ls scripts/*.sh | while read script; do
    echo "Script: $(basename "$script") available"
done
```

**System Health (ansible/ - when needed)**:
```bash
# Context: Ansible playbooks exist for system validation, but many may be outdated
# Suggestion: Agents may validate ansible inventory and safe playbooks only

echo "=== Ansible Infrastructure Assessment ==="
[[ -f "ansible/inventory/hosts.yml" ]] && echo "Inventory: Node definitions available"
[[ -f "ansible/playbooks/cluster-health.yml" ]] && echo "Health: Basic monitoring available"

# Caution: Some ansible playbooks are dangerous and should not be used
# Refer to architecture documentation for guidance on safe vs unsafe playbooks
```

### **Repository Structure Discovery**
```bash
# Context: colab-config contains multiple configuration domains
# Suggestion: Agents may assess readiness across all domains

echo "=== Full Repository Assessment ==="
for domain in omni-config ansible services infrastructure scripts documentation; do
    [[ -d "$domain" ]] && echo "✅ $domain/ domain available" || echo "❌ $domain/ missing"
done

echo "=== Omni-Config Readiness ==="
# Note: omni-config requires chezmoi templating setup to function properly
[[ -f "omni-config/dot_zshrc" ]] && echo "✅ Modern shell configuration available"
[[ -f "omni-config/dot_profile" ]] && echo "✅ Tool detection system available" 
[[ -f "omni-config/dot_config/starship.toml" ]] && echo "✅ Prompt configuration available"
```

## 🧭 Assessment Decision Framework

**Context**: Agents should evaluate cluster readiness across multiple dimensions before proceeding

### **Connectivity Assessment**
```bash
# Suggestion: Verify SSH accessibility to cluster nodes
# Context: All operations depend on SSH connectivity from snitcher

for node in crtr prtr drtr; do
    echo -n "Node $node: "
    timeout 3 ssh -o ConnectTimeout=2 "$node" 'echo "accessible"' 2>/dev/null && echo "✅" || echo "❌"
done
```

### **Configuration State Discovery**
```bash
# Context: Cluster may be using symlinks OR chezmoi OR mixed approach
# Suggestion: Agents may discover current configuration method to plan appropriately

for node in crtr prtr drtr; do
    echo "=== $node Current State ==="
    ssh "$node" "
        if [[ -L ~/.zshrc ]]; then
            echo 'Method: Symlink to \$(readlink ~/.zshrc)'
            [[ -f \$(readlink ~/.zshrc) ]] && echo 'Status: Working' || echo 'Status: Broken'
        else
            echo 'Method: Local configuration'
        fi
        
        if command -v chezmoi >/dev/null; then
            echo 'Chezmoi: Installed at \$(which chezmoi)'
            chezmoi status >/dev/null 2>&1 && echo 'Chezmoi state: Initialized' || echo 'Chezmoi state: Available but not configured'
        else
            echo 'Chezmoi: Not installed'
        fi
    "
done
```

### **Cluster Infrastructure Validation**
```bash
# Context: NFS shared storage is critical for cluster operations
# Suggestion: Agents may verify shared storage accessibility

echo "=== Shared Storage Assessment ==="
for node in crtr prtr drtr; do
    ssh "$node" "
        if [[ -d /cluster-nas ]]; then
            timeout 2 ls /cluster-nas >/dev/null 2>&1 && echo '$node: NFS accessible' || echo '$node: NFS timeout'
        else
            echo '$node: NFS not mounted'
        fi
    "
done
```

## 🎯 Implementation Considerations

**Context**: Agents may choose different approaches based on cluster conditions discovered

### **Configuration Strategy Decision Points**

| Connectivity | Config State | Infrastructure | **Agent Considerations** |
|--------------|--------------|--------------|--------------------------|
| All nodes accessible | Symlinks working | Complete | Consider chezmoi migration or maintain current state |
| All nodes accessible | Mixed/broken configs | Complete | Hybrid approach likely beneficial |
| Partial connectivity | Any | Complete | Focus on accessible nodes, plan for full coverage |
| Poor connectivity | Any | Any | Address connectivity before configuration changes |

### **Implementation Pathways**

**Chezmoi Deployment Approach**:
```bash
# Context: omni-config/ contains shell configurations ready for chezmoi
# Constraint: Requires chezmoi templating setup (.chezmoi.toml.tmpl missing)
# Suggestion: Agents may complete chezmoi setup before deployment

# Verify omni-config readiness:
[[ -f "omni-config/dot_zshrc" ]] && echo "Shell config: Available"
[[ -f "omni-config/dot_profile" ]] && echo "Profile: Available with tool detection"

# Note: chezmoi templating requires completion before deployment
# Reference: See architecture documentation for templating requirements
```

**System Environment Approach** (Optional):
```bash
# Context: System-wide configurations may benefit from ansible management
# Constraint: Many ansible playbooks are dangerous (see architecture docs)
# Suggestion: Use only validated safe playbooks for system-level operations

# Safe ansible operations suggestion:
ansible-playbook ansible/playbooks/cluster-health.yml  # Health monitoring
# Caution: Avoid uid-standardization.yml, tool-standardization.yml, system-update.yml
```

**Service Configuration Management**:
```bash
# Context: services/ and infrastructure/ contain additional configurations
# Suggestion: Agents may evaluate service-specific needs independently

echo "=== Service Configuration Evaluation ==="
[[ -d "services/semaphore" ]] && echo "Semaphore UI: Configuration available"
[[ -f "infrastructure/ssh/remote-access-config" ]] && echo "SSH: Gateway configuration available"

# Note: Service configurations are separate from user environment deployment
```

## 🛡️ Safety Context & Recovery Options

**Constraint**: Production cluster operations require careful consideration of impact

### **Risk Assessment Context**
```yaml
User-Level Changes (omni-config):
  Risk: Low - affects shell experience only
  Impact: Individual user shells, preserves SSH access
  Recovery: Simple file restoration or chezmoi reset

System-Level Changes (ansible):
  Risk: Variable - depends on specific playbook
  Impact: Could affect entire node or cluster services
  Recovery: May require system restoration or service restart

Service Changes (services/, infrastructure/):
  Risk: Medium - affects specific cluster services  
  Impact: Web interfaces, automation, monitoring
  Recovery: Service restart or configuration rollback
```

### **Recovery Options Available to Agents**

**Configuration Rollback Suggestions**:
```bash
# Context: Multiple recovery pathways exist depending on change type

# User configuration reversion (chezmoi):
ssh $node "rm -rf ~/.local/share/chezmoi"  # Remove chezmoi state
ssh $node "[[ -f ~/.zshrc.backup ]] && mv ~/.zshrc.backup ~/.zshrc"  # Restore backup

# System configuration assessment:
# Suggestion: Evaluate what ansible operations were performed
# Reference: ansible/playbooks/cluster-health.yml for validation

# Service configuration evaluation:
# Context: Service changes may require systemctl operations
# Constraint: Service impact varies by specific configuration
```

### **Emergency Access Context**
```yaml
SSH Access Preservation:
  - User-level changes preserve SSH connectivity
  - Multiple access paths: direct SSH, web terminal, physical console
  - Gateway routing through cooperator for external access

Service Access:
  - Web interfaces: https://mng.ism.la (Cockpit), https://cfg.ism.la (Semaphore)
  - Alternative access methods documented in infrastructure/ssh/

Physical Access:
  - Console access available on cooperator (Pi5)
  - Network recovery possible via gateway node
```

## 📊 Assessment Documentation

**Context**: Agents may document findings for collaboration with other agents

### **Suggested Reporting Structure**
```yaml
Cluster Assessment:
  Connectivity: [Node accessibility status]
  Configuration: [Current config method and status]
  Infrastructure: [Service and infrastructure availability]
  
Implementation Decisions:
  Approach: [Chosen strategy with reasoning]
  Scope: [Which configuration domains addressed]
  Risk Level: [Assessment based on change type]
  
Outcomes:
  Changes Applied: [Specific modifications made]
  Validation Results: [Functionality testing outcomes]  
  Follow-up Needed: [Additional considerations for future agents]
```

## 🔗 Reference Documentation

**Architecture**: See `documentation/architecture/COLAB-CLUSTER-ARCHITECTURE.md` for complete hybrid strategy details, technical requirements, and implementation phases.

**Omni-Config**: See `omni-config/documentation/architecture/DESIGN_PRINCIPLES.md` for user configuration design philosophy and tool integration strategy.

**Repository Context**: Complete configuration domains span user environments, system infrastructure, service management, and utility automation across all cluster nodes.