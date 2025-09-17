# AI Agent Safe Deployment Guide

**Target Audience**: Independent AI agents operating from snitcher
**Purpose**: Comprehensive cluster assessment and deployment planning
**Safety Level**: Maximum - assumes agent has no prior cluster knowledge

## 🎯 Mission Objective

As an AI agent operating from snitcher, your mission is to:
1. **Assess** the current state of all 3 cluster nodes
2. **Validate** repository readiness for deployment
3. **Create** a safe deployment action plan
4. **Present** findings and recommendations

## 🔍 Phase 1: Cluster Discovery and Assessment

### 1.1 Initial Connectivity Assessment

**Execute these commands from snitcher to test cluster access:**

```bash
#!/bin/bash
# Cluster Discovery Script - Run from snitcher

echo "=== CLUSTER DISCOVERY ASSESSMENT ==="
echo "Timestamp: $(date)"
echo "Operating from: $(hostname) as $(whoami)"
echo

# Test network connectivity to all cluster nodes
NODES=("crtr:192.168.254.10" "prtr:192.168.254.20" "drtr:192.168.254.30")

echo "=== NETWORK CONNECTIVITY ==="
for node_entry in "${NODES[@]}"; do
    IFS=':' read -r node ip <<< "$node_entry"
    echo -n "Testing $node ($ip): "
    if ping -c 1 -W 2 "$ip" >/dev/null 2>&1; then
        echo "✅ REACHABLE"
    else
        echo "❌ UNREACHABLE"
    fi
done
echo

# Test SSH connectivity
echo "=== SSH CONNECTIVITY ==="
for node_entry in "${NODES[@]}"; do
    IFS=':' read -r node ip <<< "$node_entry"
    echo -n "SSH to $node: "
    if timeout 5 ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no "$node" 'echo "SSH_OK"' 2>/dev/null | grep -q "SSH_OK"; then
        echo "✅ SSH ACCESSIBLE"
    else
        echo "❌ SSH FAILED"
    fi
done
```

**Assessment Criteria:**
- ✅ **PROCEED**: All nodes reachable and SSH accessible
- ⚠️ **CAUTION**: 1-2 nodes unreachable (partial deployment possible)
- ❌ **ABORT**: Majority of nodes unreachable

### 1.2 Node Health Assessment

**For each accessible node, gather system information:**

```bash
#!/bin/bash
# Node Health Assessment - Run for each node

assess_node() {
    local node="$1"
    echo "=== ASSESSING NODE: $node ==="

    # Basic system info
    echo "--- System Information ---"
    ssh "$node" "echo 'Hostname: \$(hostname)'; echo 'User: \$(whoami)'; echo 'UID: \$(id -u)'; echo 'Groups: \$(groups)'"

    # System resources
    echo "--- Resource Status ---"
    ssh "$node" "echo 'Uptime: \$(uptime)'; echo 'Memory: \$(free -h | grep Mem)'; echo 'Disk: \$(df -h / | tail -1)'"

    # Critical services
    echo "--- Critical Services ---"
    ssh "$node" "systemctl is-active ssh sshd 2>/dev/null || echo 'SSH service check failed'"

    # NFS mount status
    echo "--- NFS Mount Status ---"
    ssh "$node" "if mount | grep -q '/cluster-nas'; then echo '✅ NFS mounted'; else echo '❌ NFS not mounted'; fi"

    # Current shell configuration
    echo "--- Shell Configuration ---"
    ssh "$node" "ls -la ~/.zshrc ~/.bashrc 2>/dev/null | head -5"

    # Configuration dependencies
    echo "--- Config Dependencies ---"
    ssh "$node" "if [[ -L ~/.zshrc ]]; then echo 'Symlink: \$(readlink ~/.zshrc)'; ls -la \$(readlink ~/.zshrc) 2>/dev/null || echo 'BROKEN SYMLINK'; fi"

    echo
}

# Run assessment for each node
for node in crtr prtr drtr; do
    assess_node "$node"
done
```

**Critical Health Indicators:**
- ✅ **Healthy**: SSH accessible, NFS mounted, configs working
- ⚠️ **Degraded**: Accessible but NFS issues or config problems
- ❌ **Critical**: Major service failures or inaccessible

### 1.3 Current Configuration State Assessment

**Determine the current configuration management approach:**

```bash
#!/bin/bash
# Configuration State Assessment

echo "=== CONFIGURATION STATE ASSESSMENT ==="

# Check symlink-based configuration
echo "--- Symlink Configuration Status ---"
for node in crtr prtr drtr; do
    echo "Node $node:"
    ssh "$node" "
        if [[ -L ~/.zshrc ]]; then
            echo '  Symlink target: \$(readlink ~/.zshrc)'
            if [[ -f \$(readlink ~/.zshrc) ]]; then
                echo '  ✅ Symlink working'
            else
                echo '  ❌ Symlink broken'
            fi
        else
            echo '  📄 Local file (not symlinked)'
        fi
    "
done

# Check chezmoi status
echo "--- Chezmoi Status ---"
for node in crtr prtr drtr; do
    echo "Node $node:"
    ssh "$node" "
        if command -v chezmoi >/dev/null; then
            echo '  ✅ Chezmoi installed: \$(which chezmoi)'
            if chezmoi status >/dev/null 2>&1; then
                echo '  📋 Chezmoi initialized'
                chezmoi status 2>/dev/null | head -3
            else
                echo '  ⚪ Chezmoi not initialized'
            fi
        else
            echo '  ❌ Chezmoi not installed'
        fi
    "
done

# Check cluster-nas accessibility
echo "--- Cluster-NAS Accessibility ---"
for node in crtr prtr drtr; do
    echo "Node $node:"
    ssh "$node" "
        if [[ -d /cluster-nas ]]; then
            if timeout 2 ls /cluster-nas >/dev/null 2>&1; then
                echo '  ✅ /cluster-nas accessible'
                echo '  📁 Contents: \$(ls /cluster-nas | wc -l) directories'
            else
                echo '  ⚠️ /cluster-nas exists but not accessible'
            fi
        else
            echo '  ❌ /cluster-nas not mounted'
        fi
    "
done
```

## 🔍 Phase 2: Repository Validation

### 2.1 Repository Accessibility Assessment

**Validate the colab-config repository from snitcher:**

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