---
title: "Repository Restructure Guide"
description: "Semantic implementation guide for organizing colab-config repository structure"
version: "1.0"
date: "2025-09-27"
category: "guide"
tags: ["restructure", "organization", "chezmoi", "git", "documentation"]
applies_to: ["repository"]
related:
  - "../architecture/HYBRID-STRATEGY.md"
  - "PROJECT-COMPLETION.md"
  - "../archive/decisions/001-hybrid-approach.md"
---

# Repository Restructure Guide

## Core Understanding: The Repository's Evolution

### What Has Been Achieved

The repository has successfully evolved from a complex Ansible-heavy approach to a **hybrid configuration management system** where:
- **Chezmoi manages user environments** via `omni-config/` (working, deployed, successful)
- **System-level changes are minimal** (Ansible reduced to essential operations only)
- **`.chezmoiroot = omni-config`** enables flexible repository organization
- **Node-specific templating works** via `.chezmoi.toml.tmpl`

### What Needs Organization

While the configuration management works, the repository structure has accumulated complexity that needs rationalization:
- **Mixed purposes** in directories (scripts everywhere, multiple Ansible locations)
- **Unclear separation** between system and user configurations
- **Node-specific configurations** scattered rather than organized
- **Tool installation methods** evolving (NVM → System Node transition)

## Essential Goals of Restructuring

### 1. Preserve What Works

**The `omni-config/` directory is sacred** - it's deployed, working, and managing user environments across all nodes. The `.chezmoiroot` configuration means we can organize around it without breaking it.

### 2. Create Clear Domains

```
Universal (omni-config/) → All nodes, user-level
Node-Specific (node-configs/) → Per-node customizations
System (system-ansible/) → Infrastructure operations
Deployment (deployment/) → Orchestration and tooling
```

### 3. Enable Future Growth

The structure should accommodate:
- GPU-specific configurations for `prtr` and `drtr`
- Service-specific setups for `crtr` (gateway role)
- Tool migrations (like claude-code from NVM to system)

## Pre-Restructure Verification

### Verify Chezmoi Deployment Status

```bash
# Check that omni-config is properly deployed on all nodes
for node in crtr prtr drtr; do
    echo "=== $node Chezmoi Status ==="
    ssh $node "
        # Verify chezmoi is managing files
        chezmoi managed | head -5

        # Check source path configuration
        chezmoi source-path

        # Verify templates are working
        grep -q 'Node: $node' ~/.profile && echo '✅ Templates working' || echo '❌ Templates not applied'
    "
done
```

### Verify Dual Node.js Environment

```bash
# Check the transition from NVM to system Node
for node in crtr prtr drtr; do
    echo "=== $node Node.js Environment ==="
    ssh $node "
        # System Node (new approach)
        echo -n 'System Node: '
        /usr/bin/node --version 2>/dev/null || echo 'Not installed'

        # NVM Node (legacy, being phased out for tools)
        echo -n 'NVM Node: '
        [ -d ~/.nvm ] && echo 'Present' || echo 'Not found'

        # Claude-code location (indicates installation method)
        echo -n 'Claude-code: '
        which claude-code 2>/dev/null || echo 'Not found'
    "
done
```

### Verify Repository Integrity

```bash
# Check current repository structure and git status
cd /cluster-nas/colab/colab-config

echo "=== Repository Structure Validation ==="

# Verify .chezmoiroot configuration
[ -f .chezmoiroot ] && echo "✅ .chezmoiroot: $(cat .chezmoiroot)" || echo "❌ Missing .chezmoiroot"

# Check for directory conflicts or issues
echo "=== Directory Status ==="
for dir in omni-config ansible scripts deployment node-configs system-ansible; do
    if [ -e "$dir" ]; then
        [ -L "$dir" ] && echo "📎 $dir (symlink → $(readlink $dir))" || echo "📁 $dir (directory)"
    else
        echo "❌ $dir (not found)"
    fi
done

# Git status check
echo "=== Git Status ==="
git status --short
```

### Verify Shell Environments

```bash
# Test that shells work correctly with current setup
for node in crtr prtr drtr; do
    echo "=== $node Shell Environment ==="
    ssh $node "
        # Test bash environment
        bash -c 'source ~/.bashrc 2>/dev/null && echo \"✅ Bash loads\" || echo \"❌ Bash error\"'

        # Test zsh environment
        zsh -c 'source ~/.zshrc 2>/dev/null && echo \"✅ Zsh loads\" || echo \"❌ Zsh error\"'

        # Check for PATH issues
        echo \"PATH entries: \$(echo \$PATH | tr ':' '\n' | wc -l)\"

        # Verify tool availability
        for tool in eza bat fzf zoxide starship; do
            command -v \$tool >/dev/null && echo \"  ✅ \$tool\" || echo \"  ❌ \$tool\"
        done
    "
done
```

## Restructure Implementation Strategy

### Phase 1: Non-Destructive Preparation

**Create new structure without breaking existing**

#### Semantic Understanding

The goal is to create the new organizational structure alongside the existing one, allowing gradual migration without disruption.

#### Implementation Approach

```bash
# Create new directories that don't conflict
mkdir -p node-configs/{crtr-config,prtr-config,drtr-config}
mkdir -p deployment/{scripts,workflows,validation}
mkdir -p omni-config/{scripts,validation}

# Document what each directory will contain
cat > node-configs/README.md << 'EOF'
# Node-Specific Configurations

Each node directory contains configurations specific to that node's role:
- crtr-config/ - Gateway services, DNS, NFS server
- prtr-config/ - Multi-GPU compute, high-memory workloads
- drtr-config/ - ML platform, single GPU, Jupyter

These augment the universal omni-config with node-specific needs.
EOF
```

### Phase 2: Identify and Categorize

**Understand what belongs where before moving anything**

#### Script Categorization

```bash
# Analyze scripts to determine their proper location
echo "=== Script Analysis ==="

for script in scripts/*/*.sh scripts/*.sh; do
    [ -f "$script" ] || continue

    # Determine script category
    if grep -q "omni-config\|chezmoi" "$script" 2>/dev/null; then
        echo "$script → omni-config/validation/"
    elif grep -q "ansible-playbook\|cluster\|deploy" "$script" 2>/dev/null; then
        echo "$script → deployment/scripts/"
    elif grep -q "node-specific\|crtr\|prtr\|drtr" "$script" 2>/dev/null; then
        echo "$script → node-configs/{node}/scripts/"
    else
        echo "$script → deployment/scripts/ (general)"
    fi
done
```

### Phase 3: Git-Aware Migration

**Use git mv to preserve history**

#### Critical Principle

Every move operation must preserve git history. This means using `git mv` instead of `mv`, and committing logically related changes together.

```bash
# Example migration with git history preservation
git mv ansible system-ansible
git commit -m "refactor: Rename ansible/ to system-ansible/ for clarity

- Distinguishes system-level from user-level (omni-config/ansible/)
- Aligns with restructure plan
- No functional changes, pure rename"
```

### Phase 4: Symlink Compatibility Layer

**Maintain backward compatibility during transition**

```bash
# Create compatibility symlinks
ln -s system-ansible ansible
ln -s deployment/scripts scripts

# Add to .gitignore
echo "# Compatibility symlinks (temporary)" >> .gitignore
echo "ansible" >> .gitignore
echo "scripts" >> .gitignore
```

## Detailed Restructure Procedures

### Step 1: Create Directory Structure

**New Directory Organization:**
```bash
# Create the complete new structure
mkdir -p docs/{architecture,guides,reference,archive}
mkdir -p docs/archive/{decisions,migrations}
mkdir -p docs/examples/{node-configs,templates,playbooks}

mkdir -p node-configs/{crtr-config,prtr-config,drtr-config}
mkdir -p node-configs/crtr-config/{services,configs}
mkdir -p node-configs/prtr-config/{gpu,ml-services,configs}
mkdir -p node-configs/drtr-config/{gpu,ml-platform,configs}

mkdir -p deployment/{scripts,workflows,validation}
mkdir -p deployment/scripts/{infrastructure,applications,monitoring}

# Prepare omni-config subdirectories (without moving template files)
mkdir -p omni-config/{validation,documentation}
```

### Step 2: Migrate Documentation

**Documentation Reorganization:**
```bash
# Move governance documents
git mv colab-config-strict-rules.md docs/governance/STRICT-RULES.md

# Move guide documents
git mv colab-restructure-semantic-guide.md docs/guides/RESTRUCTURE-GUIDE.md
git mv colab-config-completion-guide.md docs/guides/COMPLETION-PATH.md

# Move architecture documents
git mv documentation/architecture/COLAB-CLUSTER-ARCHITECTURE.md docs/architecture/
git mv documentation/architecture/NVIDIA-CUDA-IMPLEMENTATION-STRATEGY.md docs/architecture/GPU-COMPUTE-STRATEGY.md
git mv documentation/architecture/DOCKER-CLEAN-REINSTALL-STRATEGY.md docs/architecture/CONTAINER-PLATFORM-STRATEGY.md

# Move procedure documents to guides
git mv documentation/procedures/COMPLETE-INFRASTRUCTURE-RESET-SEQUENCE.md docs/guides/INFRASTRUCTURE-RESET.md
git mv documentation/procedures/SYSTEMD-SERVICE-MANAGEMENT-ADDENDUM.md docs/guides/SERVICE-MANAGEMENT.md

# Archive migration documents
git mv CLAUDE-CODE-NVM-MIGRATION.md docs/archive/migrations/
git mv CRTR-CLAUDE-CODE-ASSESSMENT-REPORT.md docs/archive/migrations/
git mv migrate-installer.md docs/archive/migrations/

# Commit documentation migration
git commit -m "refactor: Reorganize documentation into structured hierarchy

- Move governance to docs/governance/
- Move guides to docs/guides/
- Move architecture to docs/architecture/
- Archive migration documents
- Preserve git history for all moves"
```

### Step 3: Migrate Scripts and Tools

**Script Reorganization:**
```bash
# Categorize and move scripts
git mv scripts/testing deployment/scripts/infrastructure/
git mv scripts/deployment deployment/scripts/applications/
git mv scripts/monitoring deployment/scripts/monitoring/

# Move validation scripts to omni-config
git mv scripts/validate-omniconfig.sh omni-config/validation/

# Commit script migration
git commit -m "refactor: Reorganize scripts by function and scope

- Infrastructure scripts → deployment/scripts/infrastructure/
- Application scripts → deployment/scripts/applications/
- Monitoring scripts → deployment/scripts/monitoring/
- Omni-config validation → omni-config/validation/
- Maintain git history for all moves"
```

### Step 4: System Configuration Migration

**Ansible Reorganization:**
```bash
# Rename ansible to system-ansible for clarity
git mv ansible system-ansible

# Create node-specific configurations
git mv system-ansible/host_vars/crtr.yml node-configs/crtr-config/
git mv system-ansible/host_vars/prtr.yml node-configs/prtr-config/
git mv system-ansible/host_vars/drtr.yml node-configs/drtr-config/

# Commit system configuration migration
git commit -m "refactor: Separate system and node-specific configurations

- Rename ansible/ → system-ansible/ for clarity
- Move node-specific vars to node-configs/
- Distinguish system-level from node-specific configs
- Preserve ansible functionality"
```

### Step 5: Create Compatibility Layer

**Backward Compatibility:**
```bash
# Create symlinks for compatibility
ln -s system-ansible ansible
ln -s deployment/scripts scripts
ln -s docs/guides/RESTRUCTURE-GUIDE.md RESTRUCTURE-GUIDE.md

# Update .gitignore
cat >> .gitignore << 'EOF'
# Compatibility symlinks (temporary)
ansible
scripts
RESTRUCTURE-GUIDE.md
EOF

# Commit compatibility layer
git commit -m "feat: Add compatibility symlinks for transition period

- ansible → system-ansible (temporary)
- scripts → deployment/scripts (temporary)
- Maintain backward compatibility during transition
- Update .gitignore for symlinks"
```

## Post-Restructure Validation

### Verify Nothing Broke

```bash
# Comprehensive validation after restructure

echo "=== Chezmoi Still Works ==="
for node in crtr prtr drtr; do
    ssh $node "chezmoi status" || echo "WARNING: Chezmoi issue on $node"
done

echo "=== Ansible Playbooks Still Accessible ==="
ansible-playbook --list-hosts system-ansible/playbooks/cluster-health.yml

echo "=== Scripts Still Findable ==="
which validate-omniconfig.sh 2>/dev/null || echo "Path issue for validation script"

echo "=== Git Repository Clean ==="
git status
```

### Update Documentation References

```bash
# Update internal documentation links
find docs/ -name "*.md" -exec sed -i 's|documentation/procedures/|docs/guides/|g' {} \;
find docs/ -name "*.md" -exec sed -i 's|documentation/architecture/|docs/architecture/|g' {} \;

# Update README.md references
sed -i 's|ansible/|system-ansible/|g' README.md
sed -i 's|scripts/|deployment/scripts/|g' README.md

# Commit documentation updates
git commit -am "docs: Update internal documentation references

- Fix links after restructure
- Update README.md paths
- Ensure documentation consistency"
```

## Success Criteria

### Organizational Success

- **Clear separation** between universal, node-specific, and system configurations
- **Intuitive locations** for new additions
- **Consistent naming** patterns throughout

### Technical Success

- **Zero breakage** of existing functionality
- **Git history preserved** for all moved files
- **Backward compatibility** via symlinks where needed
- **Chezmoi unaffected** by repository reorganization

### Operational Success

- **Easier maintenance** due to logical organization
- **Faster onboarding** for new configurations
- **Cleaner deployment** workflows

## Risk Mitigation

### Before Starting

1. **Full backup** of current working state
2. **Test on non-critical branch** first
3. **Document current working paths** that scripts depend on

### During Implementation

1. **Test after each phase** rather than all at once
2. **Keep changes atomic** and reversible
3. **Maintain compatibility symlinks** until all references updated

### Rollback Plan

```bash
# If issues arise, quickly revert
git reset --hard HEAD~1  # Undo last commit
git clean -fd            # Remove untracked directories
# Restore from backup if needed
```

## Future Considerations

### Tool Migrations

As tools migrate from NVM to system installation (like claude-code), their configurations may move from user-space (`omni-config/`) to system-space (`system-ansible/`).

### Service Deployments

Node-specific services (like GPU monitoring on `prtr`) should live in `node-configs/` rather than scattered throughout the repository.

### Documentation Evolution

As the structure clarifies, documentation can become more focused and maintainable, with clear ownership of different aspects.

## Directory Decision Tree

### Where does a new file go?

```
Is it a Chezmoi template?
  → omni-config/ root (no subdirectories!)

Is it for all nodes' user environments?
  → omni-config/{appropriate-subdir}/

Is it for one specific node?
  → node-configs/{node}-config/

Is it system-level configuration?
  → system-ansible/

Is it for deployment/orchestration?
  → deployment/

Is it documentation?
  → docs/ (or README.md if primary)
```

### File Type Guidelines

| File Type | Location | Rule |
|-----------|----------|------|
| Chezmoi templates | `omni-config/` root | NEVER move to subdirectories |
| Validation scripts | `omni-config/validation/` | Only omni-config specific |
| Node service configs | `node-configs/{node}/` | Never in omni-config |
| System playbooks | `system-ansible/` | Never in omni-config/ansible |
| Deployment scripts | `deployment/scripts/` | Never scattered in multiple locations |

## Template Integration

### Enhanced Node Detection

The restructure enables more sophisticated node-specific configurations:

```toml
# .chezmoi.toml.tmpl - Enhanced after restructure
[data]
    # Existing node identification...

    # Enhanced node-specific paths
    {{ if eq .chezmoi.hostname "cooperator" -}}
    node_config_path = "/cluster-nas/colab/colab-config/node-configs/crtr-config"
    {{- else if eq .chezmoi.hostname "projector" -}}
    node_config_path = "/cluster-nas/colab/colab-config/node-configs/prtr-config"
    {{- else if eq .chezmoi.hostname "director" -}}
    node_config_path = "/cluster-nas/colab/colab-config/node-configs/drtr-config"
    {{- end }}

    # Repository structure awareness
    docs_path = "/cluster-nas/colab/colab-config/docs"
    deployment_scripts = "/cluster-nas/colab/colab-config/deployment/scripts"
    system_ansible = "/cluster-nas/colab/colab-config/system-ansible"
```

### Template Aliases

```bash
# In shell RC templates - enhanced navigation
{{- if .cluster_member }}
# Repository navigation (post-restructure)
alias goto-docs='cd {{ .docs_path }}'
alias goto-deploy='cd {{ .deployment_scripts }}'
alias goto-node-config='cd {{ .node_config_path }}'
alias goto-system='cd {{ .system_ansible }}'

# Quick access to common operations
alias validate-config='{{ .deployment_scripts }}/infrastructure/validate-cluster.sh'
alias cluster-deploy='{{ .deployment_scripts }}/applications/deploy-cluster.sh'
{{- end }}
```

## Conclusion

This restructure is about **organizing what already works** rather than changing how things function. The hybrid approach (Chezmoi for users, minimal Ansible for system) remains unchanged. We're simply making the repository structure reflect the elegant architecture that's already been implemented.

**Key Benefits:**
- ✅ **Clear Organization**: Each directory has a specific, well-defined purpose
- ✅ **Preserved Functionality**: All existing systems continue to work
- ✅ **Git History Intact**: Complete traceability of all changes
- ✅ **Future-Ready**: Structure accommodates growth and evolution
- ✅ **Backward Compatible**: Symlinks maintain existing workflows during transition

**Success Metrics:**
- All Chezmoi deployments continue to work unchanged
- Ansible playbooks remain accessible and functional
- Scripts and tools maintain their functionality
- Documentation is more organized and discoverable
- New additions have clear homes in the structure

The restructure transforms the repository from a collection of working but scattered components into a well-organized, maintainable system that scales effectively and communicates its structure clearly to both humans and automation tools.