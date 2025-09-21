# Colab-Config: Strict Rules & Design Decisions

**📍 File Location**: `docs/governance/STRICT-RULES.md`

---

## Non-Negotiable Constraints

### Chezmoi Configuration

- **`.chezmoiroot = omni-config`** - Set in stone, enables repository flexibility
- **Template files (`dot_*.tmpl`) MUST remain at `omni-config/` root** - Moving them breaks Chezmoi
- **`.chezmoi.toml.tmpl` stays at `omni-config/` root** - Required for node-specific templating
- **`.chezmoitemplate.*` files stay at `omni-config/` root** - Shared template includes

### Directory Structure (Final)

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

## Hard Rules

### Git Operations

- **ALWAYS use `git mv`** - Never use plain `mv` for tracked files
- **Commit atomically** - One logical change per commit
- **Preserve history** - No force pushes, no history rewrites

### Migration Rules

- **Create before moving** - New directories first, then migrate
- **Symlinks for compatibility** - Old paths must work during transition
- **Test after each phase** - Never proceed without validation

### File Organization

| File Type | Location | Rule |
|-----------|----------|------|
| Chezmoi templates | `omni-config/` root | NEVER move to subdirectories |
| Validation scripts | `omni-config/validation/` | Only omni-config specific |
| Node service configs | `node-configs/{node}/` | Never in omni-config |
| System playbooks | `system-ansible/` | Never in omni-config/ansible |
| Deployment scripts | `deployment/scripts/` | Never scattered in multiple locations |

## Documentation Standards

### Required Files

```yaml
README.md:        # Primary documentation (humans + AI)
AGENTS.md:        # AI runtime specifics ONLY (20-30 lines max)
STRUCTURE.yaml:   # Machine-readable organization
```

### Documentation Rules

- **README is truth** - All project information lives here
- **No duplication** - If humans need it, it's in README only
- **AGENTS.md is tiny** - Only runtime restrictions and tool paths

## Node Architecture

### Fixed Node Roles

| Node | Hostname | Role | Special Hardware |
|------|----------|------|------------------|
| crtr | cooperator | Gateway, NFS, DNS | None |
| prtr | projector | Compute, Development | 4x GPU (2x GTX 970, 2x GTX 1080) |
| drtr | director | ML Platform | 1x GPU (RTX 2080) |

### Node Configuration Precedence

1. **Universal** (`omni-config/`) - Applies to all nodes
2. **Node-specific** (`node-configs/{node}-config/`) - Overrides universal
3. **Local** (uncommitted changes) - Testing only

## Tool Installation Strategy

### Dual Node.js Environment (Decided)

- **System Node** (`/usr/bin/node`) - For global tools (claude-code, etc.)
- **NVM Node** (`~/.nvm/`) - For development projects only
- **Never mix** - Tools use system, projects use NVM

### Installation Rules

| Tool | Method | Location |
|------|--------|----------|
| chezmoi | System package or binary | `/usr/local/bin/` |
| claude-code | System npm | `/usr/local/bin/` |
| ansible | System package | `/usr/bin/` |
| Development deps | NVM | `~/.nvm/versions/` |

## Validation Requirements

### Before Any Change

```bash
# These MUST pass:
chezmoi status          # No pending changes
git status              # Clean working directory
ansible all -m ping     # All nodes responsive
```

### After Restructure

```bash
# These MUST work:
chezmoi apply --dry-run           # Templates still process
system-ansible/playbooks/*.yml    # Playbooks still findable
deployment/scripts/*.sh           # Scripts still executable
```

## Compatibility Symlinks

### Temporary (Remove after full migration)

```bash
ansible -> system-ansible
scripts -> deployment/scripts
```

### Permanent (Part of design)

```bash
# None - clean structure preferred
```

## Forbidden Actions

### Never Do These

- ❌ Move Chezmoi template files to subdirectories
- ❌ Break `.chezmoiroot` configuration
- ❌ Use plain `mv` instead of `git mv`
- ❌ Mix system and user Ansible playbooks
- ❌ Install development tools with system npm
- ❌ Duplicate README content in AGENTS.md
- ❌ Force push or rewrite git history
- ❌ Proceed without validation

## Success Metrics

### Restructure is complete when

1. ✓ All Chezmoi deployments still work
2. ✓ Git history preserved for all files
3. ✓ Clear separation: universal vs node-specific vs system
4. ✓ No ambiguity about where new files belong
5. ✓ Documentation accurate and minimal
6. ✓ All validation tests pass

## Quick Decision Tree

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

---
**This document represents fixed decisions. Changes require explicit justification.**
