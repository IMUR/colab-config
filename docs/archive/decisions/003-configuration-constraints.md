---
title: "ADR-003: Configuration Management Constraints and Design Rules"
description: "Architectural Decision Record defining strict constraints for configuration management"
version: "1.0"
date: "2025-09-27"
category: "decision"
tags: ["adr", "constraints", "rules", "design", "governance"]
status: "accepted"
related:
  - "001-hybrid-approach.md"
  - "002-chezmoi-adoption.md"
  - "../../guides/REPOSITORY-RESTRUCTURE.md"
---

# ADR-003: Configuration Management Constraints and Design Rules

## Status
**Accepted** - September 2025

## Context

Following the adoption of the hybrid configuration management approach (ADR-001) and Chezmoi for user configurations (ADR-002), the cluster needed explicit constraints and design rules to prevent regression to the previous problematic state and ensure long-term maintainability.

### Historical Problems
1. **Configuration Drift**: Inconsistent configurations across nodes
2. **Tool Misuse**: Using Ansible for dotfile management
3. **Dangerous Operations**: System-level changes risking SSH access
4. **File Placement Ambiguity**: Unclear where new configurations belong
5. **Template Violations**: Breaking Chezmoi source structure

### Governance Requirements
- **Prevent Regression**: Explicit rules to avoid past mistakes
- **Clear Boundaries**: Unambiguous separation between tool responsibilities
- **Safety First**: Multiple layers of protection against dangerous operations
- **Maintainability**: Structure that remains clear as system evolves
- **Decision Preservation**: Constraints that encode architectural decisions

## Decision

**Establish strict, non-negotiable constraints** for configuration management with clear enforcement mechanisms and rationale.

## Non-Negotiable Constraints

### Chezmoi Configuration Structure

**Immutable Constraint:**
```
.chezmoiroot = omni-config
```
**Rationale:** Set in stone, enables repository flexibility
**Enforcement:** Repository validation scripts
**Violation Impact:** Breaks entire Chezmoi deployment

**Template File Placement:**
```
Template files (dot_*.tmpl) MUST remain at omni-config/ root
```
**Rationale:** Moving them breaks Chezmoi's file discovery
**Enforcement:** Pre-commit hooks
**Violation Impact:** Templates not processed

**Configuration Data:**
```
.chezmoi.toml.tmpl stays at omni-config/ root
```
**Rationale:** Required for node-specific templating
**Enforcement:** Chezmoi validation
**Violation Impact:** No node-specific configurations

**Shared Templates:**
```
.chezmoitemplate.* files stay at omni-config/ root
```
**Rationale:** Template includes require root location
**Enforcement:** Template dependency checking
**Violation Impact:** Shared functionality breaks

### Directory Structure (Final)

**Established Structure:**
```
colab-config/
├── .chezmoiroot                    # IMMUTABLE: Points to "omni-config"
├── omni-config/                    # PROTECTED: Chezmoi source root
├── node-configs/                   # DECIDED: Node-specific configurations
│   ├── crtr-config/               # Gateway node
│   ├── prtr-config/               # Compute node (multi-GPU)
│   └── drtr-config/               # ML platform (single GPU)
├── system-ansible/                 # DECIDED: Renamed from ansible/
├── deployment/                     # DECIDED: Consolidated scripts/workflows
│   ├── scripts/
│   └── workflows/
└── docs/                          # DECIDED: Consolidated documentation
```

**Enforcement Rules:**
- No new top-level directories without architectural review
- Node-configs must follow {hostname}-config pattern
- System-ansible only for root-required operations
- Deployment for orchestration and cluster-wide operations

### Tool Separation Rules

**System-Level Configuration (Minimal Ansible):**
```yaml
Scope: Package installation, system services, /etc/ configurations ONLY
Examples: Installing packages, managing systemd services, creating system users
Frequency: Infrequent (initial setup, major system changes)
Risk Level: Moderate (requires root, affects system stability)
```

**User-Level Configuration (Pure Chezmoi):**
```yaml
Scope: Dotfiles, shell environments, user-specific tool configurations
Examples: .zshrc.tmpl, .bashrc.tmpl, .profile, .config/starship.toml
Frequency: Regular (daily configuration refinements)
Risk Level: Low (user-level only, preserves SSH access)
```

**Violation Prevention:**
- No user configurations in system-ansible/
- No system configurations in omni-config/
- No root-required operations in Chezmoi templates
- No dotfile management in Ansible playbooks

### Git Operations Rules

**History Preservation:**
```bash
ALWAYS use git mv - Never use plain mv for tracked files
```
**Rationale:** Preserves file history and enables tracking changes
**Enforcement:** Pre-commit hooks checking for untracked moves
**Violation Impact:** Lost history and audit trail

**Atomic Commits:**
```bash
One logical change per commit
```
**Rationale:** Clear history and easy rollback
**Enforcement:** Commit message validation
**Violation Impact:** Difficult debugging and rollback

**No History Rewriting:**
```bash
No force pushes, no history rewrites
```
**Rationale:** Preserves audit trail and collaboration safety
**Enforcement:** Repository protection rules
**Violation Impact:** Lost history and team confusion

### File Organization Rules

**Strict Placement Matrix:**
| File Type | Location | Rule |
|-----------|----------|------|
| Chezmoi templates | `omni-config/` root | NEVER move to subdirectories |
| Validation scripts | `omni-config/validation/` | Only omni-config specific |
| Node service configs | `node-configs/{node}/` | Never in omni-config |
| System playbooks | `system-ansible/` | Never in omni-config/ansible |
| Deployment scripts | `deployment/scripts/` | Never scattered in multiple locations |

**Migration Rules:**
- Create before moving (new directories first, then migrate)
- Symlinks for compatibility (old paths work during transition)
- Test after each phase (never proceed without validation)

### Safety Constraints

**Forbidden Operations:**
```bash
❌ Move Chezmoi template files to subdirectories
❌ Break .chezmoiroot configuration
❌ Use plain mv instead of git mv
❌ Mix system and user Ansible playbooks
❌ Install development tools with system npm
❌ Duplicate README content in AGENTS.md
❌ Force push or rewrite git history
❌ Proceed without validation
```

**Required Validations:**
```bash
# These MUST pass before any change:
chezmoi status          # No pending changes
git status              # Clean working directory
ansible all -m ping     # All nodes responsive

# These MUST work after restructure:
chezmoi apply --dry-run           # Templates still process
system-ansible/playbooks/*.yml    # Playbooks still findable
deployment/scripts/*.sh           # Scripts still executable
```

### Node Architecture Constraints

**Fixed Node Roles:**
| Node | Hostname | Role | Hardware | Constraints |
|------|----------|------|----------|-------------|
| crtr | cooperator | Gateway, NFS, DNS | ARM64, No GPU | No GPU configs |
| prtr | projector | Compute, Development | x86_64, 4x GPU | Multi-GPU configs only |
| drtr | director | ML Platform | x86_64, 1x GPU | Single GPU configs only |

**Configuration Precedence (Immutable Order):**
1. **Universal** (`omni-config/`) - Applies to all nodes
2. **Node-specific** (`node-configs/{node}-config/`) - Overrides universal
3. **Local** (uncommitted changes) - Testing only

### Tool Installation Strategy

**Dual Node.js Environment (Decided):**
```yaml
System Node: /usr/bin/node - For global tools (claude-code, etc.)
NVM Node: ~/.nvm/ - For development projects only
Rule: Never mix - Tools use system, projects use NVM
```

**Installation Matrix:**
| Tool | Method | Location | Constraint |
|------|--------|----------|------------|
| chezmoi | System package or binary | `/usr/local/bin/` | Never user-local |
| claude-code | System npm | `/usr/local/bin/` | Never NVM |
| ansible | System package | `/usr/bin/` | Never user installation |
| Development deps | NVM | `~/.nvm/versions/` | Never system |

## Enforcement Mechanisms

### Automated Enforcement

**Pre-commit Hooks:**
```bash
#!/bin/bash
# Check Chezmoi structure integrity
if [ ! -f .chezmoiroot ] || [ "$(cat .chezmoiroot)" != "omni-config" ]; then
    echo "ERROR: .chezmoiroot missing or incorrect"
    exit 1
fi

# Check template file locations
if find omni-config -name "dot_*.tmpl" | grep -v "^omni-config/dot_"; then
    echo "ERROR: Template files not at omni-config root"
    exit 1
fi

# Check for plain mv usage (should be git mv)
if git diff --cached --name-status | grep "^R"; then
    echo "WARNING: File renames detected - ensure git mv was used"
fi
```

**Template Validation:**
```bash
#!/bin/bash
# Validate template rendering on all nodes
for node in cooperator projector director; do
    chezmoi execute-template --init --promptString hostname=$node < omni-config/.chezmoi.toml.tmpl > /dev/null
    if [ $? -ne 0 ]; then
        echo "ERROR: Template rendering failed for $node"
        exit 1
    fi
done
```

**Structure Validation:**
```bash
#!/bin/bash
# Validate directory structure compliance
required_dirs="omni-config node-configs system-ansible deployment docs"
for dir in $required_dirs; do
    if [ ! -d "$dir" ]; then
        echo "ERROR: Required directory $dir missing"
        exit 1
    fi
done

# Check for prohibited locations
if [ -d "omni-config/ansible" ]; then
    echo "ERROR: Ansible configs in omni-config (should be system-ansible)"
    exit 1
fi
```

### Manual Enforcement

**Code Review Requirements:**
- All changes affecting structure require architectural review
- Template changes require testing on all node types
- Any .chezmoiroot changes require explicit justification
- New directories require documentation of purpose

**Documentation Requirements:**
- Every constraint violation must be documented with justification
- All architectural decisions must be recorded as ADRs
- Changes to constraints require updating this document
- Violation patterns trigger process improvements

### Escalation Procedures

**Constraint Violation Response:**
1. **Immediate**: Automated checks fail builds/deploys
2. **Review**: Manual review flags architectural concerns
3. **Discussion**: Team discussion for complex constraint changes
4. **Decision**: Formal ADR process for constraint modifications
5. **Implementation**: Updated automation and documentation

## Decision Tree for New Files

**Quick Reference:**
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

**Detailed Decision Process:**
1. **Template Check**: Contains `.tmpl` extension? → omni-config/ root
2. **Scope Check**: Affects all users on all nodes? → omni-config/
3. **Node Check**: Specific to one node role? → node-configs/
4. **Privilege Check**: Requires root access? → system-ansible/
5. **Purpose Check**: Deployment or orchestration? → deployment/
6. **Default**: Documentation goes to docs/

## Success Criteria

**Structural Integrity:**
- ✓ Clear separation between universal, node-specific, and system configurations
- ✓ Intuitive locations for new additions
- ✓ Consistent naming patterns throughout
- ✓ No ambiguity about file placement

**Technical Validation:**
- ✓ Zero breakage of existing functionality
- ✓ Git history preserved for all moved files
- ✓ Backward compatibility via symlinks where needed
- ✓ Chezmoi unaffected by repository reorganization

**Operational Excellence:**
- ✓ Easier maintenance due to logical organization
- ✓ Faster onboarding for new configurations
- ✓ Cleaner deployment workflows
- ✓ Reduced cognitive load for developers

## Monitoring and Maintenance

### Constraint Adherence Metrics
- **Structure violations**: Automated detection of file misplacement
- **Template integrity**: Regular validation of Chezmoi structure
- **Git hygiene**: Monitoring for history-breaking operations
- **Tool separation**: Auditing for inappropriate tool usage

### Regular Reviews
- **Monthly**: Automated constraint validation reports
- **Quarterly**: Manual review of constraint effectiveness
- **Annually**: Comprehensive review of constraint necessity
- **Ad-hoc**: Review triggered by significant violations

### Constraint Evolution
- **Addition**: New constraints require ADR documentation
- **Modification**: Changes require team consensus and testing
- **Removal**: Must demonstrate constraint is no longer needed
- **Emergency**: Temporary constraint suspension requires immediate follow-up

## Related Decisions
- [ADR-001: Hybrid Approach](001-hybrid-approach.md) - Context for these constraints
- [ADR-002: Chezmoi Adoption](002-chezmoi-adoption.md) - Chezmoi-specific constraints

## References
- [Repository Restructure Guide](../../guides/REPOSITORY-RESTRUCTURE.md)
- [Hybrid Strategy Documentation](../../architecture/HYBRID-STRATEGY.md)
- [Templates Reference](../../reference/TEMPLATES.md)
- [Variables Reference](../../reference/VARIABLES.md)

---

**Decision Date**: September 2025
**Status**: Accepted and Enforced
**Last Review**: September 2025
**Next Review**: December 2025

**Enforcement Note**: These constraints represent fixed decisions. Changes require explicit justification and formal ADR process.