# AI Agent Quick Start Guide

**Target**: Independent AI agents operating from snitcher  
**Mission**: Assess cluster and deploy hybrid configuration management  
**Approach**: **Modern Hybrid** - Minimal Ansible + Chezmoi  
**Safety**: Maximum caution - assume no prior knowledge

## 🎯 **MODERN HYBRID APPROACH**

**System-Level (Minimal Ansible)**:
- Package installation, system services
- /etc/profile.d/ system-wide environment  
- Basic system preparation

**User-Level (Pure Chezmoi)**:
- Shell configurations (.zshrc, .profile)
- Dotfiles and personal settings
- Cross-node consistency with templating

## 🚀 Quick Assessment Commands

### 1. Test Cluster Connectivity (2 minutes)
```bash
# Run from snitcher
for node in crtr prtr drtr; do
    echo -n "$node: "
    if timeout 5 ssh -o ConnectTimeout=3 "$node" 'echo OK' 2>/dev/null; then
        echo "✅ ACCESSIBLE"
    else
        echo "❌ FAILED"
    fi
done
```

### 2. Check Current Configuration State (3 minutes)
```bash
# Assess current configuration approach
for node in crtr prtr drtr; do
    echo "=== $node ==="
    ssh "$node" "
        echo 'Current config approach:'
        if [[ -L ~/.zshrc ]]; then
            echo '  📎 Symlinks: \$(readlink ~/.zshrc)'
            ls -la \$(readlink ~/.zshrc) 2>/dev/null && echo '    ✅ Working' || echo '    ❌ Broken'
        else
            echo '  📄 Local files'
        fi
        
        echo 'Chezmoi status:'
        if command -v chezmoi >/dev/null; then
            echo '  ✅ Installed: \$(which chezmoi)'
            chezmoi status 2>/dev/null | head -3 || echo '  ⚪ Not initialized'
        else
            echo '  ❌ Not installed'
        fi
    "
done
```

### 3. Repository Structure Validation (1 minute)
```bash
# Quick validation of hybrid approach readiness
cd "/path/to/colab-config"

echo "=== HYBRID SETUP VALIDATION ==="

# Check omni-config structure
echo "📁 Omni-config structure:"
[[ -f "omni-config/dot_zshrc" ]] && echo "  ✅ dot_zshrc" || echo "  ❌ Missing dot_zshrc"
[[ -f "omni-config/dot_profile" ]] && echo "  ✅ dot_profile" || echo "  ❌ Missing dot_profile"
[[ -d "omni-config/dot_config" ]] && echo "  ✅ dot_config/" || echo "  ❌ Missing dot_config/"

# Check minimal ansible structure
echo "📁 System-level setup:"
[[ -f "ansible/playbooks/cluster-health.yml" ]] && echo "  ✅ Health checks" || echo "  ❌ Missing health checks"
[[ -f "ansible/inventory/hosts.yml" ]] && echo "  ✅ Inventory" || echo "  ❌ Missing inventory"

echo "🎯 Ready for hybrid deployment!"
```

### 4. Safety Prerequisites (3 minutes)
```bash
# Check critical safety requirements
echo "=== SAFETY CHECK ==="

# Recent backup
ssh crtr "
    if [[ -d /cluster-nas/backups ]]; then
        LATEST=\$(ls -t /cluster-nas/backups/ | head -1)
        echo \"Latest backup: \$LATEST\"
    else
        echo \"❌ No backups found\"
    fi
"

# Node health
for node in crtr prtr drtr; do
    echo "$node: $(ssh "$node" "uptime | awk '{print \$3, \$4, \$5}' | sed 's/,//g'")"
done

# Disk space
for node in crtr prtr drtr; do
    echo "$node disk: $(ssh "$node" "df -h / | tail -1 | awk '{print \$5}'")"
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