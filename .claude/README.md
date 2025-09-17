# Claude Code Context Directory

This directory provides comprehensive context for Claude Code when working with the Co-lab cluster infrastructure configuration.

## Directory Contents

### `context/` - Background Information
- **cluster-nodes.md** - Node specifications, IPs, roles, and quick commands
- **current-migration-status.md** - Status of symlinks → chezmoi migration
- **important-warnings.md** - Critical constraints and safety warnings

### `templates/` - Code Templates
- **ansible-playbook-template.yml** - Standard playbook structure with safety checks

### `procedures/` - Operational Procedures
- **safe-deployment-checklist.md** - Comprehensive deployment safety checklist

## Quick Reference

### Essential Context Files to Read First
1. **CLAUDE.md** (repository root) - Primary context and overview
2. **important-warnings.md** - Critical safety constraints
3. **cluster-nodes.md** - Node specifications and access methods
4. **current-migration-status.md** - Current state of migration

### For Ansible Development
- Use **ansible-playbook-template.yml** as starting point
- Follow **safe-deployment-checklist.md** for all deployments
- Review **important-warnings.md** for constraints

### For Configuration Changes
- Check **current-migration-status.md** for symlink dependencies
- Use **cluster-nodes.md** for testing commands
- Follow safety procedures from **safe-deployment-checklist.md**

## Safety Reminders

⚠️ **Current system uses symlinks - do not break them**
⚠️ **Always test on single node (drtr) first**
⚠️ **Create backup before any changes**
⚠️ **Have rollback plan ready**

## Repository Structure Context

This repository manages:
- **3-node cluster**: cooperator, projector, director
- **Production infrastructure**: Live system in daily use
- **Hybrid approach**: Ansible + Chezmoi configuration management
- **Migration in progress**: Symlinks → Chezmoi (carefully planned)

For complete context, always read the main **CLAUDE.md** file first.