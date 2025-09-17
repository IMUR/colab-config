# Archive Directory

This directory contains files that have been archived during the hybrid approach implementation.

## Archive Categories

- **obsolete-files/**: Scripts and configurations that are no longer needed
- **configuration-overlaps/**: Conflicting configurations that were resolved  
- **broken-ansible/**: Dangerous/broken ansible playbooks that were removed
- **reference-configs/**: Alternative configurations kept for reference

## Archive Policy

Files are moved here instead of deletion to preserve development history and enable future reference if needed.

**Date Archived**: 2025-09-17 
**Reason**: Hybrid approach implementation and safety cleanup

## Recent Archives (2025-09-17)

### ZSH System Configuration Conflicts
**Location**: `configuration-overlaps/zsh-system-files/`
**Files Archived**:
- `zshenv` - ZSH environment variables (loaded first for ALL shells)
- `zprofile` - ZSH profile for login shells only  
- `zlogout` - ZSH logout cleanup tasks

**Reason for Archival**: These symlinked files created critical conflicts with chezmoi-managed configurations:

1. **Dual PATH Management**: Both `.zshenv` (symlinked) and `.profile` (chezmoi) managed PATH differently
2. **NVM Loading Conflicts**: `.zshenv` loaded NVM immediately with hardcoded version, while `.profile.tmpl` deferred to `.zshrc`
3. **Node Detection Inconsistency**: `.zshenv` used runtime hostname detection vs `.profile.tmpl` template-time baking
4. **prtr Alignment Issues**: The dual configuration system caused shell initialization failures specifically on projector node

**Resolution**: Implemented pure chezmoi approach with `dot_profile.tmpl` providing:
- Single source of truth for PATH configuration
- Template-time node-specific environment variables
- Consistent NVM loading strategy across all nodes
- Elimination of runtime vs template-time conflicts

**Impact**: Resolves prtr NVM/Starship availability issues and ensures consistent shell environment across all cluster nodes.

**✅ RESOLUTION CONFIRMED (2025-09-17 14:30)**:
- **prtr NVM**: ✅ `command -v nvm` now returns `nvm` (previously failed)
- **prtr Starship**: ✅ Available at `/home/prtr/.local/bin/starship` 
- **Template Variables**: ✅ All nodes show correct NODE_TYPE, NODE_ROLE, HAS_GPU values
- **PATH Consistency**: ✅ `~/.local/bin` properly included across all nodes
- **Pure Chezmoi**: ✅ No more dual configuration conflicts

**Final Architecture**: Single source of truth via `dot_profile.tmpl` with template-time node-specific values, eliminating runtime detection conflicts that caused prtr alignment issues.
