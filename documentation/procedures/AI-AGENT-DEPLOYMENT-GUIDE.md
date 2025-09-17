# AI Agent Modern Hybrid Deployment Guide

**Target Audience**: Independent AI agents operating from snitcher  
**Purpose**: Fast, safe deployment using modern hybrid approach  
**Safety Level**: High confidence - user-level changes only  
**Deployment Time**: ~20 minutes total

## 🎯 Mission Objective

As an AI agent operating from snitcher, your mission is to:
1. **Assess** cluster connectivity and basic health (5 minutes)
2. **Deploy** user configurations via chezmoi (10 minutes)  
3. **Validate** deployment success (5 minutes)
4. **Report** completion status and next steps

## 🏗️ **Modern Hybrid Approach**

**System-Level (Minimal)**:
- Install chezmoi binary on each node
- Optional: Basic system environment (/etc/profile.d/)
- Health monitoring only

**User-Level (Primary Focus)**:
- Rich shell configurations (.zshrc, .profile)
- Modern CLI tools with smart detection
- Cross-node consistency with templating  
- Node-specific customizations

## 🔍 Phase 1: Quick Cluster Assessment (5 minutes)

### 1.1 **Simplified Connectivity Check**

**Execute from snitcher - simple and fast:**

```bash
#!/bin/bash
# Quick Hybrid Assessment - Run from snitcher

echo "=== HYBRID DEPLOYMENT ASSESSMENT ==="
echo "Timestamp: $(date)"
echo "Method: Modern Hybrid (Minimal Ansible + Pure Chezmoi)"
echo

# Quick SSH connectivity test
NODES=(crtr prtr drtr)

echo "=== SSH CONNECTIVITY ==="
ACCESSIBLE=0
for node in "${NODES[@]}"; do
    echo -n "Testing $node: "
    if timeout 3 ssh -o ConnectTimeout=2 "$node" 'echo OK' 2>/dev/null | grep -q "OK"; then
        echo "✅ ACCESSIBLE"
        ((ACCESSIBLE++))
    else
        echo "❌ FAILED"  
    fi
done

echo
echo "=== ASSESSMENT RESULT ==="
if [[ $ACCESSIBLE -eq 3 ]]; then
    echo "🟢 ALL NODES ACCESSIBLE - PROCEED with hybrid deployment"
    exit 0
elif [[ $ACCESSIBLE -ge 2 ]]; then
    echo "🟡 PARTIAL ACCESS ($ACCESSIBLE/3) - Proceed with accessible nodes only"
    exit 1  
else
    echo "🔴 INSUFFICIENT ACCESS ($ACCESSIBLE/3) - Fix connectivity first"
    exit 2
fi
```

**Decision Matrix:**
- **3/3 nodes**: ✅ **FULL DEPLOYMENT** - proceed immediately
- **2/3 nodes**: ⚠️ **PARTIAL DEPLOYMENT** - deploy to accessible nodes  
- **1/3 nodes**: ❌ **ABORT** - fix connectivity issues first

### 1.2 **Quick Health Check** (Optional)

**Simple validation for accessible nodes:**

```bash
#!/bin/bash
# Quick Health Check - Hybrid Deployment Focus

echo "=== QUICK HEALTH VALIDATION ==="

for node in crtr prtr drtr; do
    echo -n "Node $node: "
    
    # Test SSH access and basic commands
    if ssh "$node" "
        echo 'Host: \$(hostname)'
        echo 'Disk: \$(df -h / | tail -1 | awk '{print \$5}')'
        echo 'NFS: \$(mount | grep cluster-nas >/dev/null && echo mounted || echo missing)'
        echo 'Chezmoi: \$(command -v chezmoi >/dev/null && echo installed || echo missing)'
    " 2>/dev/null; then
        echo "✅ HEALTHY"
    else
        echo "❌ HEALTH CHECK FAILED"
    fi
    echo
done

echo "✅ Health check complete - ready for hybrid deployment"
```

**Health Indicators (Simplified):**
- ✅ **Ready**: SSH works, basic commands respond  
- ⚠️ **Proceed**: SSH works, some issues (will be resolved by deployment)
- ❌ **Skip**: SSH issues (exclude from deployment)

---

## 🚀 Phase 2: Hybrid Deployment (10 minutes)

### 2.1 **System Preparation** (2 minutes)

**Install chezmoi on all accessible nodes:**

```bash
#!/bin/bash
# Install Chezmoi - Simple System Preparation

echo "=== INSTALLING CHEZMOI ==="

NODES=(crtr prtr drtr)  # Adjust if nodes are unreachable

for node in "${NODES[@]}"; do
    echo "Installing chezmoi on $node..."
    
    if ssh "$node" "curl -sfL https://get.chezmoi.io | sh -s -- -b ~/.local/bin"; then
        echo "✅ $node: chezmoi installed"
        
        # Verify installation
        ssh "$node" "~/.local/bin/chezmoi --version" && echo "   Version confirmed"
    else
        echo "❌ $node: chezmoi installation failed"
    fi
    echo
done

echo "✅ System preparation complete"
```

**Why This Is Safe:**
- ✅ User-level installation only (no system modifications)
- ✅ Downloads from official chezmoi source  
- ✅ Installs to ~/.local/bin (no root required)
- ✅ Quick rollback (just delete ~/.local/bin/chezmoi)

### 2.2 **Deploy User Configurations** (5 minutes)

**Copy omni-config source and deploy via chezmoi:**

```bash
#!/bin/bash
# Deploy User Configurations via Chezmoi

echo "=== DEPLOYING USER CONFIGURATIONS ==="

# 1. Copy omni-config source to cluster-nas
echo "Copying omni-config to cluster-nas..."
if scp -r omni-config/ crtr:/cluster-nas/configs/colab-omni-config/; then
    echo "✅ Source copied to cluster-nas"
else
    echo "❌ Failed to copy source - check NFS access"
    exit 1
fi

# 2. Deploy to director first (least critical node for testing)
echo
echo "=== TESTING ON DIRECTOR (drtr) ==="
if ssh drtr "~/.local/bin/chezmoi init --apply --source /cluster-nas/configs/colab-omni-config"; then
    echo "✅ Director deployment successful"
    
    # Quick validation
    if ssh drtr 'source ~/.zshrc && echo "Shell configuration loaded successfully"'; then
        echo "✅ Director validation passed"
    else
        echo "⚠️ Director validation issues (may still be functional)"
    fi
else
    echo "❌ Director deployment failed - aborting"
    exit 1
fi

# 3. Deploy to remaining nodes
echo
echo "=== DEPLOYING TO REMAINING NODES ==="
for node in prtr crtr; do
    echo "Deploying to $node..."
    
    if ssh "$node" "~/.local/bin/chezmoi init --apply --source /cluster-nas/configs/colab-omni-config"; then
        echo "✅ $node: deployment successful"
        
        # Quick validation  
        ssh "$node" 'source ~/.zshrc 2>/dev/null && echo "✅ '$node': config loaded"'
    else
        echo "❌ $node: deployment failed"
    fi
    echo
done

echo "✅ User configuration deployment complete"
```

---

## ✅ Phase 3: Validation & Completion (5 minutes)

### 3.1 **Comprehensive Validation**

**Verify deployment success across all nodes:**

```bash
#!/bin/bash
# Repository Validation - Run from snitcher

echo "=== REPOSITORY VALIDATION ==="

# Test GitHub connectivity
echo "--- GitHub Connectivity ---"
if curl -s --connect-timeout 5 https://api.github.com >/dev/null; then
    echo "✅ GitHub accessible"
else
    echo "❌ GitHub not accessible"
    exit 1
fi

# Test repository access
echo "--- Repository Access ---"
REPO_URL="https://github.com/IMUR/colab-config.git"
if git ls-remote "$REPO_URL" >/dev/null 2>&1; then
    echo "✅ Repository accessible: $REPO_URL"
else
    echo "❌ Repository not accessible: $REPO_URL"
    exit 1
fi

# Clone repository for inspection
echo "--- Repository Clone ---"
TEMP_DIR="/tmp/colab-config-assessment-$(date +%s)"
if git clone "$REPO_URL" "$TEMP_DIR" >/dev/null 2>&1; then
    echo "✅ Repository cloned to: $TEMP_DIR"
    cd "$TEMP_DIR"
else
    echo "❌ Repository clone failed"
    exit 1
fi

# Validate repository structure
echo "--- Repository Structure Validation ---"
REQUIRED_DIRS=("ansible" "services" "infrastructure" "omni-config" "documentation" "scripts")
MISSING_DIRS=()

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "✅ $dir/ present"
    else
        echo "❌ $dir/ missing"
        MISSING_DIRS+=("$dir")
    fi
done

if [[ ${#MISSING_DIRS[@]} -gt 0 ]]; then
    echo "⚠️ Missing directories: ${MISSING_DIRS[*]}"
fi

# Validate critical files
echo "--- Critical Files Validation ---"
CRITICAL_FILES=(
    "README.md"
    "ansible/playbooks/site.yml"
    "ansible/inventory/hosts.yml"
    "omni-config/dot_zshrc"
    "documentation/architecture/README.md"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file present ($(wc -l < "$file") lines)"
    else
        echo "❌ $file missing"
    fi
done

echo "Repository validation complete."
echo "Working directory: $TEMP_DIR"
```

### 2.2 Ansible Playbook Validation

**Validate ansible configurations and dependencies:**

```bash
#!/bin/bash
# Ansible Validation - Run from repository directory

echo "=== ANSIBLE CONFIGURATION VALIDATION ==="

cd "$TEMP_DIR"  # From previous step

# Check ansible installation
echo "--- Ansible Installation ---"
if command -v ansible >/dev/null; then
    echo "✅ Ansible installed: $(ansible --version | head -1)"
else
    echo "❌ Ansible not installed"
fi

if command -v ansible-playbook >/dev/null; then
    echo "✅ Ansible-playbook available"
else
    echo "❌ Ansible-playbook not available"
fi

# Validate inventory
echo "--- Inventory Validation ---"
if ansible-inventory --list >/dev/null 2>&1; then
    echo "✅ Inventory syntax valid"
    echo "--- Inventory Hosts ---"
    ansible-inventory --list | grep -A 10 '"hosts"'
else
    echo "❌ Inventory syntax invalid"
fi

# Validate critical playbooks
echo "--- Playbook Validation ---"
CRITICAL_PLAYBOOKS=(
    "ansible/playbooks/site.yml"
    "ansible/playbooks/cluster-health.yml"
    "ansible/playbooks/backup-verify.yml"
)

for playbook in "${CRITICAL_PLAYBOOKS[@]}"; do
    if [[ -f "$playbook" ]]; then
        echo -n "Validating $playbook: "
        if ansible-playbook --syntax-check "$playbook" >/dev/null 2>&1; then
            echo "✅ Valid syntax"
        else
            echo "❌ Syntax errors"
        fi
    else
        echo "❌ $playbook not found"
    fi
done

# Test connection to cluster from ansible
echo "--- Ansible Connectivity Test ---"
if ansible all -m ping >/dev/null 2>&1; then
    echo "✅ Ansible can reach all hosts"
    ansible all -m ping | grep -E "(pong|UNREACHABLE)"
else
    echo "⚠️ Ansible connectivity issues detected"
fi
```

## 🔍 Phase 3: Risk Assessment and Prerequisites

### 3.1 Safety Prerequisites Check

**Verify all safety requirements before deployment:**

```bash
#!/bin/bash
# Safety Prerequisites Check

echo "=== SAFETY PREREQUISITES ASSESSMENT ==="

# Check for existing backups
echo "--- Backup Status ---"
ssh crtr "
    if [[ -d /cluster-nas/backups ]]; then
        LATEST_BACKUP=\$(ls -t /cluster-nas/backups/ | head -1)
        if [[ -n \"\$LATEST_BACKUP\" ]]; then
            echo \"✅ Latest backup: \$LATEST_BACKUP\"
            echo \"📅 Backup date: \$(date -r /cluster-nas/backups/\$LATEST_BACKUP)\"
        else
            echo \"⚠️ Backup directory exists but empty\"
        fi
    else
        echo \"❌ No backup directory found\"
    fi
"

# Check for active users and processes
echo "--- Active Users Check ---"
for node in crtr prtr drtr; do
    echo "Node $node:"
    ssh "$node" "
        echo '  Users: \$(who | wc -l) active sessions'
        echo '  Load: \$(uptime | awk -F'load average:' '{print \$2}')'
        if ps aux | grep -v grep | grep -E '(ansible|deployment|update)' >/dev/null; then
            echo '  ⚠️ Active deployment processes detected'
        else
            echo '  ✅ No conflicting processes'
        fi
    "
done

# Check for pending updates or maintenance
echo "--- System Maintenance Status ---"
for node in crtr prtr drtr; do
    echo "Node $node:"
    ssh "$node" "
        if command -v apt >/dev/null; then
            UPDATES=\$(apt list --upgradable 2>/dev/null | wc -l)
            echo \"  📦 Pending updates: \$UPDATES\"
        fi
        if systemctl is-failed --quiet || systemctl list-units --failed --quiet | grep -q failed; then
            echo \"  ⚠️ Failed services detected\"
        else
            echo \"  ✅ All services healthy\"
        fi
    "
done

# Check disk space
echo "--- Disk Space Check ---"
for node in crtr prtr drtr; do
    echo "Node $node:"
    ssh "$node" "
        df -h / | tail -1 | awk '{
            if (\$5+0 > 90) print \"  ❌ Disk space critical: \" \$5
            else if (\$5+0 > 80) print \"  ⚠️ Disk space warning: \" \$5
            else print \"  ✅ Disk space adequate: \" \$5
        }'
    "
done
```

### 3.2 Deployment Impact Analysis

**Assess the impact of proposed changes:**

```bash
#!/bin/bash
# Deployment Impact Analysis

echo "=== DEPLOYMENT IMPACT ANALYSIS ==="

# Analyze configuration changes
echo "--- Configuration Change Analysis ---"
cd "$TEMP_DIR"

# Compare omni-config with current cluster configs
echo "Comparing omni-config with current cluster state..."

# Check if this would be a breaking change
echo "--- Breaking Change Assessment ---"
BREAKING_CHANGES=0

# Check shell configuration differences
if [[ -f "omni-config/dot_zshrc" ]]; then
    echo "🔍 Analyzing shell configuration changes..."

    # Compare with current symlinked config
    ssh crtr "cat /cluster-nas/configs/zsh/zshrc" > /tmp/current_zshrc 2>/dev/null
    if diff -q "omni-config/dot_zshrc" /tmp/current_zshrc >/dev/null 2>&1; then
        echo "✅ Shell config unchanged"
    else
        echo "⚠️ Shell configuration differences detected"
        echo "--- Diff Summary ---"
        diff -u /tmp/current_zshrc "omni-config/dot_zshrc" | head -20
        BREAKING_CHANGES=$((BREAKING_CHANGES + 1))
    fi
fi

# Check for UID/GID impacts
echo "--- UID/GID Impact Assessment ---"
for node in crtr prtr drtr; do
    echo "Node $node:"
    ssh "$node" "
        echo '  Current UID: \$(id -u)'
        echo '  Current groups: \$(groups)'
        if id cluster >/dev/null 2>&1; then
            echo '  ✅ Cluster group exists'
        else
            echo '  ⚠️ Cluster group missing'
        fi
    "
done

# Assess service impact
echo "--- Service Impact Assessment ---"
echo "Services that may be affected by deployment:"
echo "  - Shell environments (all users)"
echo "  - SSH configurations"
echo "  - Development tools and aliases"
echo "  - Modern CLI tool integrations"

if [[ $BREAKING_CHANGES -gt 0 ]]; then
    echo "⚠️ BREAKING CHANGES DETECTED: $BREAKING_CHANGES"
    echo "   Deployment requires careful planning and testing"
else
    echo "✅ No breaking changes detected"
    echo "   Deployment should be safe"
fi
```

## 📋 Phase 4: Deployment Plan Generation

### 4.1 Create Deployment Action Plan

**Based on assessments, generate deployment recommendations:**

```bash
#!/bin/bash
# Deployment Plan Generator

echo "=== DEPLOYMENT ACTION PLAN GENERATION ==="

# Collect all assessment results
CONNECTIVITY_STATUS="TBD"  # From Phase 1.1
NODE_HEALTH="TBD"         # From Phase 1.2
CONFIG_STATE="TBD"        # From Phase 1.3
REPO_VALID="TBD"          # From Phase 2
SAFETY_CHECK="TBD"        # From Phase 3.1
IMPACT_LEVEL="TBD"        # From Phase 3.2

echo "--- Assessment Summary ---"
echo "Connectivity: $CONNECTIVITY_STATUS"
echo "Node Health: $NODE_HEALTH"
echo "Config State: $CONFIG_STATE"
echo "Repository: $REPO_VALID"
echo "Safety Prerequisites: $SAFETY_CHECK"
echo "Impact Level: $IMPACT_LEVEL"

# Generate plan based on assessment
echo
echo "=== RECOMMENDED DEPLOYMENT PLAN ==="

# Determine deployment strategy
if [[ "$CONNECTIVITY_STATUS" == "ALL_ACCESSIBLE" && "$NODE_HEALTH" == "HEALTHY" && "$REPO_VALID" == "VALID" ]]; then
    echo "📋 DEPLOYMENT STRATEGY: Full Cluster Deployment"
    echo

    echo "Phase 1: Pre-deployment Safety"
    echo "  1.1 Create cluster backup"
    echo "      ansible-playbook ansible/playbooks/backup-verify.yml"
    echo
    echo "  1.2 Verify cluster health"
    echo "      ansible-playbook ansible/playbooks/cluster-health.yml"
    echo
    echo "  1.3 Stop non-essential services"
    echo "      # Minimize disruption during deployment"
    echo

    echo "Phase 2: Single Node Testing"
    echo "  2.1 Deploy to test node (drtr - least critical)"
    echo "      ansible-playbook ansible/playbooks/deploy-omni-config.yml --limit drtr"
    echo
    echo "  2.2 Validate test deployment"
    echo "      ssh drtr 'source ~/.zshrc && echo \"Test successful\"'"
    echo
    echo "  2.3 Rollback test if failed"
    echo "      ansible-playbook ansible/playbooks/rollback.yml --limit drtr"
    echo

    echo "Phase 3: Gradual Rollout"
    echo "  3.1 Deploy to projector (prtr)"
    echo "      ansible-playbook ansible/playbooks/deploy-omni-config.yml --limit prtr"
    echo
    echo "  3.2 Deploy to cooperator (crtr) - LAST"
    echo "      ansible-playbook ansible/playbooks/deploy-omni-config.yml --limit crtr"
    echo

    echo "Phase 4: Validation and Cleanup"
    echo "  4.1 Full cluster validation"
    echo "      ansible-playbook ansible/playbooks/cluster-health.yml"
    echo
    echo "  4.2 Remove old symlinks (after validation)"
    echo "      ansible-playbook ansible/playbooks/cleanup-symlinks.yml"
    echo

    echo "📅 ESTIMATED TIMELINE: 2-4 hours"
    echo "⚠️ RISK LEVEL: LOW (with proper testing)"

elif [[ "$CONNECTIVITY_STATUS" == "PARTIAL" ]]; then
    echo "📋 DEPLOYMENT STRATEGY: Partial Deployment"
    echo
    echo "⚠️ Only accessible nodes will be configured"
    echo "🔄 Unreachable nodes must be handled separately"

else
    echo "📋 DEPLOYMENT STRATEGY: ABORT"
    echo
    echo "❌ Prerequisites not met for safe deployment"
    echo "🔧 Required actions before deployment:"

    if [[ "$CONNECTIVITY_STATUS" != "ALL_ACCESSIBLE" ]]; then
        echo "  - Restore connectivity to all cluster nodes"
    fi

    if [[ "$NODE_HEALTH" != "HEALTHY" ]]; then
        echo "  - Resolve node health issues"
    fi

    if [[ "$REPO_VALID" != "VALID" ]]; then
        echo "  - Fix repository validation issues"
    fi
fi
```

### 4.2 Risk Mitigation Plan

**Generate specific risk mitigation strategies:**

```bash
#!/bin/bash
# Risk Mitigation Plan

echo "=== RISK MITIGATION PLAN ==="

echo "🛡️ Pre-deployment Safeguards:"
echo "  1. Full cluster backup verification"
echo "  2. Rollback playbooks tested and ready"
echo "  3. Emergency access methods confirmed"
echo "  4. Service restart procedures documented"
echo
echo "🚨 Emergency Procedures:"
echo "  1. Configuration Failure:"
echo "     - Restore from backup: /cluster-nas/backups/LATEST/"
echo "     - Revert to symlinks: ansible-playbook rollback-to-symlinks.yml"
echo "     - Emergency shell: ssh with -t 'bash --norc'"
echo
echo "  2. SSH Access Loss:"
echo "     - Physical console access on cooperator"
echo "     - Web terminal: https://ssh.ism.la"
echo "     - Cockpit management: https://mng.ism.la"
echo
echo "  3. Service Failures:"
echo "     - systemctl restart [service]"
echo "     - journalctl -u [service] for diagnosis"
echo "     - Fallback to previous working config"
echo
echo "📞 Escalation Path:"
echo "  1. Automated rollback (if possible)"
echo "  2. Manual intervention via documented procedures"
echo "  3. Physical access to cooperator if needed"
echo
echo "⏱️ Maximum Downtime Tolerance:"
echo "  - Individual nodes: 15 minutes"
echo "  - Cluster services: 5 minutes"
echo "  - Critical services (NFS, DNS): 2 minutes"
```

## 📊 Phase 5: Final Report Generation

### 5.1 Comprehensive Assessment Report

**Generate final deployment readiness report:**

```bash
#!/bin/bash
# Final Assessment Report Generator

echo "=== CLUSTER DEPLOYMENT READINESS REPORT ==="
echo "Generated: $(date)"
echo "Assessment Agent: AI Agent operating from snitcher"
echo "Repository: https://github.com/IMUR/colab-config"
echo

# Executive Summary
echo "📋 EXECUTIVE SUMMARY"
echo "=================="
echo "Cluster Status: [READY/NOT_READY/PARTIAL]"
echo "Recommended Action: [PROCEED/HOLD/ABORT]"
echo "Risk Level: [LOW/MEDIUM/HIGH]"
echo "Estimated Timeline: [X hours]"
echo

# Detailed Findings
echo "🔍 DETAILED FINDINGS"
echo "=================="
echo
echo "Connectivity Assessment:"
echo "  crtr (cooperator): [✅/❌] [Details]"
echo "  prtr (projector):  [✅/❌] [Details]"
echo "  drtr (director):   [✅/❌] [Details]"
echo
echo "Node Health Status:"
echo "  System Resources: [OK/WARNING/CRITICAL]"
echo "  Service Status: [OK/WARNING/CRITICAL]"
echo "  Configuration State: [SYMLINKS/CHEZMOI/MIXED/BROKEN]"
echo
echo "Repository Validation:"
echo "  Repository Access: [✅/❌]"
echo "  Structure Validation: [✅/❌]"
echo "  Ansible Syntax: [✅/❌]"
echo "  Playbook Testing: [✅/❌]"
echo
echo "Safety Prerequisites:"
echo "  Recent Backups: [✅/❌] [Date of latest]"
echo "  Disk Space: [✅/⚠️/❌]"
echo "  Active Processes: [✅/⚠️]"
echo "  Service Health: [✅/⚠️/❌]"
echo

# Recommendations
echo "💡 RECOMMENDATIONS"
echo "=================="
echo
echo "Immediate Actions Required:"
echo "  [ ] Create fresh backup"
echo "  [ ] Verify rollback procedures"
echo "  [ ] Test deployment on single node"
echo
echo "Deployment Sequence:"
echo "  1. [Phase] [Description] [Estimated time]"
echo "  2. [Phase] [Description] [Estimated time]"
echo "  3. [Phase] [Description] [Estimated time]"
echo
echo "Risk Mitigation:"
echo "  - Backup strategy: [Details]"
echo "  - Rollback plan: [Details]"
echo "  - Emergency access: [Details]"
echo

# Approval Checklist
echo "✅ DEPLOYMENT APPROVAL CHECKLIST"
echo "==============================="
echo "  [ ] All cluster nodes accessible"
echo "  [ ] Repository validated and tested"
echo "  [ ] Fresh backup created and verified"
echo "  [ ] Rollback procedures tested"
echo "  [ ] Emergency access confirmed"
echo "  [ ] Service impact understood"
echo "  [ ] Timeline and maintenance window agreed"
echo "  [ ] Risk mitigation strategies in place"
echo
echo "Approved by: [AI Agent Assessment]"
echo "Date: $(date)"
echo "Next Review: [Date + 24h if not deployed]"
```

## 🎯 Usage Instructions for AI Agents

### Quick Start
1. **Clone this repository** to snitcher
2. **Run Phase 1** assessments to discover cluster state
3. **Execute Phase 2** to validate repository readiness
4. **Perform Phase 3** risk assessment
5. **Generate Phase 4** deployment plan
6. **Compile Phase 5** final report

### Decision Tree
```
Connectivity Test → All nodes accessible?
├─ YES → Health Check → All healthy?
│  ├─ YES → Repository Test → Valid?
│  │  ├─ YES → Safety Check → Prerequisites met?
│  │  │  ├─ YES → RECOMMEND: Proceed with deployment
│  │  │  └─ NO → RECOMMEND: Address safety issues first
│  │  └─ NO → RECOMMEND: Fix repository issues
│  └─ NO → RECOMMEND: Resolve health issues
└─ NO → RECOMMEND: Restore connectivity first
```

### Output Format
All assessment scripts should output:
- **Status indicators**: ✅ (pass), ⚠️ (warning), ❌ (fail)
- **Structured data**: JSON or key-value format when possible
- **Human-readable**: Clear descriptions for review
- **Actionable**: Specific next steps for issues found

This guide ensures any AI agent can safely assess and deploy cluster configurations with maximum safety and minimum risk.