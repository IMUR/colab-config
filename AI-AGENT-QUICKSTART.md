# AI Agent Quick Start Guide

**Target**: Independent AI agents operating from snitcher
**Mission**: Assess cluster and plan safe deployment of colab-config
**Safety**: Maximum caution - assume no prior knowledge

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
# Assess current shell configuration approach
for node in crtr prtr drtr; do
    echo "=== $node ==="
    ssh "$node" "
        if [[ -L ~/.zshrc ]]; then
            echo 'Symlink: \$(readlink ~/.zshrc)'
            ls -la \$(readlink ~/.zshrc) 2>/dev/null && echo '✅ Working' || echo '❌ Broken'
        else
            echo '📄 Local file'
        fi
        echo 'Chezmoi: \$(command -v chezmoi >/dev/null && echo installed || echo missing)'
    "
done
```

### 3. Validate Repository (2 minutes)
```bash
# Test repository access and clone
REPO="https://github.com/IMUR/colab-config.git"
TEMP_DIR="/tmp/colab-config-$(date +%s)"

if git clone "$REPO" "$TEMP_DIR"; then
    echo "✅ Repository accessible"
    cd "$TEMP_DIR"

    # Quick structure check
    for dir in ansible services omni-config documentation; do
        [[ -d "$dir" ]] && echo "✅ $dir/" || echo "❌ $dir/ missing"
    done
else
    echo "❌ Repository clone failed"
    exit 1
fi
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

Based on assessment results:

| Connectivity | Health | Repository | Backup | **Recommendation** |
|--------------|--------|------------|--------|-------------------|
| All ✅ | All ✅ | ✅ | ✅ | **PROCEED** with deployment |
| All ✅ | All ✅ | ✅ | ❌ | **CREATE BACKUP FIRST** |
| All ✅ | Some ⚠️ | ✅ | ✅ | **CAUTION** - limited deployment |
| Some ❌ | Any | Any | Any | **RESTORE CONNECTIVITY** |
| Any | Any | ❌ | Any | **FIX REPOSITORY** |

## 📋 Quick Deployment Plan Template

**IF ALL SYSTEMS GREEN:**

```bash
# Deployment sequence from snitcher
cd "$TEMP_DIR"  # Repository directory

# 1. Create backup
ansible-playbook ansible/playbooks/backup-verify.yml

# 2. Test on one node (director - least critical)
ansible-playbook ansible/playbooks/deploy-omni-config.yml --limit drtr

# 3. Validate test
ssh drtr 'source ~/.zshrc && echo "✅ Test successful"'

# 4. Deploy to remaining nodes
ansible-playbook ansible/playbooks/deploy-omni-config.yml --limit prtr,crtr

# 5. Final validation
ansible-playbook ansible/playbooks/cluster-health.yml
```

## 🚨 Emergency Stop Conditions

**ABORT DEPLOYMENT IF:**
- Any node becomes unreachable during deployment
- Configuration errors detected
- Services fail to start
- Users report shell access issues

**Emergency Rollback:**
```bash
# Quick restore from backup
ssh crtr "cd /cluster-nas/backups/\$(ls -t | head -1) && ./restore.sh"
```

## 📊 Quick Report Format

```
CLUSTER ASSESSMENT REPORT
========================
Timestamp: $(date)
Agent: AI Agent from snitcher

Connectivity: [3/3] nodes accessible
Health: [ALL OK | WARNINGS | CRITICAL]
Repository: [VALID | INVALID]
Backup: [RECENT | OLD | MISSING]

RECOMMENDATION: [PROCEED | HOLD | ABORT]
RISK LEVEL: [LOW | MEDIUM | HIGH]

Next Action: [Specific command or requirement]
```

## 🔧 Troubleshooting Quick Fixes

**SSH Connection Issues:**
```bash
# Test SSH key
ssh-add -l
# Verify SSH config
cat ~/.ssh/config | grep -A 5 "Host crtr"
```

**NFS Mount Issues:**
```bash
# Check NFS status
ssh crtr "systemctl status nfs-server"
ssh prtr "mount | grep cluster-nas"
```

**Repository Access Issues:**
```bash
# Test GitHub connectivity
curl -s https://api.github.com/repos/IMUR/colab-config
# Verify git configuration
git config --list | grep user
```

---

**For complete detailed procedures, see**: `documentation/procedures/AI-AGENT-DEPLOYMENT-GUIDE.md`