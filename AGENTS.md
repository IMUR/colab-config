# AI Agent Runtime Information

## Critical Paths

- **Working Directory**: `/cluster-nas/colab/colab-config`
- **Chezmoi Source**: `omni-config/` (via `.chezmoiroot`)
- **System Ansible**: `system-ansible/` (renamed from `ansible/`)
- **Node Access**: SSH to `crtr`, `prtr`, `drtr`

## Tool Constraints

- **Git Operations**: Use `git mv` for all moves (preserve history)
- **Chezmoi**: Templates stay at `omni-config/` root
- **Testing**: Validate with `chezmoi status` before changes

## Current State

- ✅ Chezmoi deployed and working on all nodes
- ✅ System Node.js installed (no NVM)
- ⚠️ Repository restructure in progress
- 🔄 Claude local installation via migrate-installer

## Structure Navigation

See `trail.yaml` for machine-readable structure.
See `README.md` for complete documentation.

## Token Optimization

- Primary docs in README.md (not duplicated here)
- Use `trail.yaml` for programmatic navigation
- Check `docs/governance/STRICT-RULES.md` for constraints
