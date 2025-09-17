# Current Migration Status

Status of the symlinks → chezmoi migration for universal configurations.

## Current State: SYMLINKS ACTIVE ✅

### What's Working Now (DO NOT BREAK)
- **Shell Configs**: All 3 nodes use symlinks to `/cluster-nas/configs/zsh/zshrc`
- **Shared Storage**: NFS mounted at `/cluster-nas` on all nodes
- **Universal Access**: Changes to `/cluster-nas/configs/zsh/` affect all nodes immediately
- **Battle Tested**: This configuration is stable and in daily use

### Migration Target: Chezmoi-based Omni-Config
- **Repository**: This repository contains updated omni-config/
- **Deployment**: Via Ansible playbooks (not yet active)
- **Benefits**: Node-specific templating, offline capability, version control

## Migration Strategy: ZERO DOWNTIME

### Phase 1: Repository Setup ✅ COMPLETE
- [x] Created colab-config repository
- [x] Updated omni-config for 3-node architecture
- [x] Removed snitcher dependencies
- [x] Added comprehensive documentation

### Phase 2: Testing and Validation 📋 PENDING
- [ ] Deploy chezmoi to single node (drtr) for testing
- [ ] Validate mixed environment (symlinks + chezmoi)
- [ ] Test rollback procedures
- [ ] Verify no conflicts with daily operations

### Phase 3: Gradual Migration 📋 PLANNED
- [ ] Deploy to remaining nodes one by one
- [ ] Maintain symlinks as fallback during transition
- [ ] Validate each step before proceeding
- [ ] Keep emergency rollback available

### Phase 4: Cleanup 📋 FUTURE
- [ ] Remove symlinks after full validation
- [ ] Clean up old configuration directories
- [ ] Update documentation for new system
- [ ] Archive migration artifacts

## Safety Protocols

### Current Protection
- **Daily Backups**: All configs backed up to `/cluster-nas/backups/`
- **Symlinks Work**: No changes to current working system
- **NFS Dependency**: Current system requires NFS (acceptable for cluster nodes)

### Migration Safety
- **Backup First**: Always create backup before any changes
- **Test Single Node**: Use drtr (least critical) for testing
- **Rollback Ready**: Procedures to revert to symlinks immediately
- **No Service Disruption**: Migration should not affect running services

## Key Decisions Made

### Snitcher Separation ✅
- **Snitcher excluded** from omni-config (has its own repository)
- **3-node focus**: omni-config targets only crtr, prtr, drtr
- **Clear architecture**: 3+1 model with cluster + mobile access

### UID/GID Strategy ✅
- **Keep current UIDs**: crtr=1001, prtr/drtr=1000
- **No UID standardization**: Would break existing services
- **Group-based sharing**: cluster group (GID 2000) for shared access

### File Permissions ✅
- **World-writable approach**: 777/666 for NFS compatibility
- **Security trade-off**: Acceptable within trusted cluster network
- **Application compatibility**: Required for proper NFS operation

## Commands for Migration Work

### Check Current State
```bash
# Verify symlinks are working
for node in crtr prtr drtr; do
    ssh "$node" "ls -la ~/.zshrc && source ~/.zshrc && echo 'Shell OK'"
done

# Check chezmoi readiness
for node in crtr prtr drtr; do
    ssh "$node" "which chezmoi && chezmoi --version"
done
```

### Test Deployment (When Ready)
```bash
# Test on single node
ansible-playbook ansible/playbooks/deploy-omni-config.yml --limit drtr --check

# Deploy to test node
ansible-playbook ansible/playbooks/deploy-omni-config.yml --limit drtr

# Validate test
ssh drtr "source ~/.zshrc && echo 'Chezmoi config OK'"
```

### Emergency Rollback
```bash
# Restore symlinks on test node
ssh drtr "rm ~/.zshrc && ln -s /cluster-nas/configs/zsh/zshrc ~/.zshrc"

# Or restore from backup
ansible-playbook ansible/playbooks/restore-from-backup.yml --limit drtr
```

## Next Steps

1. **DO NOT BREAK** current symlink system
2. **Test carefully** on single node first
3. **Validate thoroughly** before proceeding
4. **Maintain rollback** capability at all times
5. **Document everything** as we proceed

The current symlink system is stable and working. Migration should be careful, gradual, and reversible.