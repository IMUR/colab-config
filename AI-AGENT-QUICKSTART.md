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

## 🎯 Decision Matrix

| Connectivity | Config State | Repository | **Recommendation** |
|--------------|--------------|------------|-------------------|
| All ✅ | Symlinks Working | ✅ | **PROCEED** with hybrid approach |
| All ✅ | Mixed/Broken | ✅ | **PROCEED** - hybrid will fix |
| All ✅ | Any | ❌ | **FIX REPOSITORY** first |
| Some ❌ | Any | Any | **RESTORE CONNECTIVITY** |

## 📋 Modern Hybrid Deployment Plan

**IF ALL SYSTEMS GREEN:**

### **Phase 1: System Preparation** (5 minutes)
```bash
# Simple system-level setup (minimal ansible)
cd colab-config/

# Install chezmoi on all nodes
for node in crtr prtr drtr; do
    echo "Installing chezmoi on $node..."
    ssh "$node" "curl -sfL https://get.chezmoi.io | sh -s -- -b ~/.local/bin"
done

# Optional: Basic system-wide environment setup
# ansible-playbook ansible/playbooks/system-environment.yml
```

### **Phase 2: Chezmoi Deployment** (10 minutes)
```bash
# Deploy omni-config via chezmoi (pure user-level)

# 1. Copy omni-config source to cluster-nas
scp -r omni-config/ crtr:/cluster-nas/configs/colab-omni-config/

# 2. Deploy to test node first (director - least critical)
echo "Testing on director (drtr)..."
ssh drtr "~/.local/bin/chezmoi init --apply --source /cluster-nas/configs/colab-omni-config"

# 3. Validate test deployment
echo "Testing shell functionality..."
ssh drtr 'source ~/.zshrc && echo "✅ Chezmoi deployment successful"'

# 4. Deploy to remaining nodes
for node in crtr prtr; do
    echo "Deploying to $node..."
    ssh "$node" "~/.local/bin/chezmoi init --apply --source /cluster-nas/configs/colab-omni-config"
    ssh "$node" 'source ~/.zshrc && echo "✅ '$node' deployment successful"'
done
```

### **Phase 3: Validation** (5 minutes)
```bash
# Comprehensive validation
echo "=== DEPLOYMENT VALIDATION ==="

for node in crtr prtr drtr; do
    echo "Validating $node:"
    ssh "$node" "
        echo '  Shell: '\$(echo \$SHELL)
        echo '  Modern tools: '\$(command -v eza >/dev/null && echo 'eza ✅' || echo 'eza ❌')
        echo '  Chezmoi: '\$(chezmoi --version | head -1)
        echo '  Config status: '\$(timeout 3 zsh -c 'source ~/.zshrc && echo SUCCESS' || echo 'TIMEOUT')
    "
done

echo "🎉 Hybrid deployment complete!"
```

## 🚨 Emergency Stop Conditions

**ABORT DEPLOYMENT IF:**
- Any node becomes unreachable during deployment
- Configuration errors detected
- Services fail to start
- Users report shell access issues

## 🚨 Emergency Rollback

**Simple rollback strategy:**
```bash
# Quick rollback to previous state
for node in crtr prtr drtr; do
    ssh "$node" "
        # Remove chezmoi configs
        rm -rf ~/.local/share/chezmoi
        
        # Restore from backup if available
        [[ -f ~/.zshrc.backup ]] && mv ~/.zshrc.backup ~/.zshrc
        
        echo '$node rolled back'
    "
done
```

## 📊 Quick Report Format

```
HYBRID DEPLOYMENT REPORT
========================
Timestamp: $(date)
Agent: AI Agent from snitcher
Approach: Hybrid (Minimal Ansible + Pure Chezmoi)

Connectivity: [3/3] nodes accessible
System Setup: [COMPLETE/PARTIAL/FAILED]  
User Configs: [COMPLETE/PARTIAL/FAILED]
Validation: [ALL PASS/SOME ISSUES/FAILED]

RECOMMENDATION: [SUCCESS/INVESTIGATE/ROLLBACK]
NEXT ACTION: [Monitor/Fix Issues/Rollback]

Deployment Method: Modern hybrid approach
- System-level: Minimal preparation only
- User-level: Pure chezmoi configuration
- Risk Level: LOW (user-level changes only)
```

## 🔧 Troubleshooting Quick Fixes

**Chezmoi Issues:**
```bash
# Reinstall chezmoi
ssh $node "curl -sfL https://get.chezmoi.io | sh -s -- -b ~/.local/bin"

# Reset chezmoi state
ssh $node "rm -rf ~/.local/share/chezmoi && ~/.local/bin/chezmoi init --source /cluster-nas/configs/colab-omni-config"
```

**Configuration Issues:**
```bash
# Test configuration loading
ssh $node "timeout 5 zsh -c 'source ~/.zshrc && echo SUCCESS'"

# Check chezmoi status
ssh $node "~/.local/bin/chezmoi status"
```

---

**Deployment Time: ~20 minutes total**  
**Risk Level: LOW** (user-level changes only)  
**Rollback Time: ~5 minutes**

**For detailed procedures, see**: `documentation/procedures/AI-AGENT-DEPLOYMENT-GUIDE.md`