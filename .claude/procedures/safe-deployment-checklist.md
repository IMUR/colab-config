# Safe Deployment Checklist

Use this checklist before making any changes to cluster configuration.

## Pre-Deployment Safety Checks ✅

### 1. Cluster Health Assessment
- [ ] All 3 nodes (crtr, prtr, drtr) are accessible via SSH
- [ ] NFS mount `/cluster-nas` is working on all nodes
- [ ] No failed systemd services on any node
- [ ] Adequate disk space (>20% free) on all nodes
- [ ] System load is normal (<2.0) on all nodes

**Commands:**
```bash
# Quick health check
ansible all -m ping
ansible all -m setup -a "filter=ansible_load*"
ansible-playbook ansible/playbooks/cluster-health.yml
```

### 2. Backup Verification
- [ ] Recent backup exists (within 24 hours)
- [ ] Backup integrity verified
- [ ] Backup restoration procedure tested recently
- [ ] Backup location has sufficient space

**Commands:**
```bash
# Create fresh backup
ansible-playbook ansible/playbooks/backup-verify.yml

# Check backup status
ssh crtr "ls -la /cluster-nas/backups/ | tail -5"
```

### 3. Change Impact Assessment
- [ ] Configuration changes reviewed and understood
- [ ] Potential service impacts identified
- [ ] Rollback plan prepared and documented
- [ ] Estimated downtime (if any) communicated
- [ ] Change window scheduled appropriately

### 4. Testing Preparation
- [ ] Test environment or single node identified (recommend: drtr)
- [ ] Test procedures documented
- [ ] Success criteria defined
- [ ] Failure recovery procedures ready

## Deployment Process ✅

### Phase 1: Single Node Testing
- [ ] Deploy to test node only (`--limit drtr`)
- [ ] Validate deployment success
- [ ] Test all affected functionality
- [ ] Confirm no service disruption
- [ ] Document any issues or unexpected behavior

**Commands:**
```bash
# Test deployment
ansible-playbook [playbook] --limit drtr --check --diff
ansible-playbook [playbook] --limit drtr

# Validate test
ssh drtr "[validation_commands]"
```

### Phase 2: Gradual Rollout
- [ ] Deploy to second node (prtr)
- [ ] Validate deployment
- [ ] Deploy to final node (crtr) - MOST CRITICAL
- [ ] Full cluster validation
- [ ] Monitor for issues over 30 minutes

**Commands:**
```bash
# Gradual deployment
ansible-playbook [playbook] --limit prtr
ansible-playbook [playbook] --limit crtr

# Full validation
ansible-playbook ansible/playbooks/cluster-health.yml
```

### Phase 3: Post-Deployment Validation
- [ ] All services functioning normally
- [ ] User access and functionality confirmed
- [ ] Performance metrics within normal ranges
- [ ] No error logs or warnings
- [ ] Documentation updated with changes

## Emergency Procedures 🚨

### If Deployment Fails
1. **STOP IMMEDIATELY** - Do not continue to other nodes
2. **Assess the failure** - Understand what went wrong
3. **Rollback affected node** - Restore to previous working state
4. **Verify rollback success** - Confirm system is working
5. **Document the failure** - Record what happened and why

### Rollback Commands
```bash
# Quick rollback to symlinks (if chezmoi deployment failed)
ssh [failed_node] "rm ~/.zshrc && ln -s /cluster-nas/configs/zsh/zshrc ~/.zshrc"

# Full backup restoration
cd /cluster-nas/backups/[latest_backup]
ansible-playbook restore.yml --limit [failed_node]

# Service restart
ansible [failed_node] -m systemd -a "name=[service] state=restarted" -b
```

### Emergency Access
- **SSH fails**: Use web terminal at https://ssh.ism.la
- **Web access fails**: Physical console access on cooperator
- **Total failure**: Power cycle cooperator and restore from backup

## Post-Deployment Tasks ✅

### Immediate (Within 1 hour)
- [ ] Monitor system logs for errors
- [ ] Verify all web services accessible
- [ ] Test user shell access and functionality
- [ ] Update change documentation
- [ ] Notify team of deployment completion

### Short-term (Within 24 hours)
- [ ] Monitor performance metrics
- [ ] Review backup verification
- [ ] Update procedure documentation
- [ ] Schedule follow-up health check

### Long-term (Within 1 week)
- [ ] Analyze deployment success metrics
- [ ] Update deployment procedures based on lessons learned
- [ ] Plan next phase of migration (if applicable)
- [ ] Archive deployment artifacts

## Common Validation Commands

### Shell Configuration
```bash
# Test shell loading
ssh [node] "source ~/.zshrc && echo 'Shell OK'"

# Check aliases and functions
ssh [node] "ls && which eza && echo 'Tools OK'"

# Verify modern CLI tools
ssh [node] "bat --version && fd --version && rg --version"
```

### Service Status
```bash
# Critical services
ansible all -m systemd -a "name=ssh"
ansible crtr -m systemd -a "name=nfs-server"
ansible crtr -m systemd -a "name=pihole-FTL"

# Web services
curl -I https://cfg.ism.la
curl -I https://mng.ism.la
```

### NFS and Storage
```bash
# NFS functionality
ansible all -m shell -a "ls /cluster-nas && touch /cluster-nas/test-$(hostname) && rm /cluster-nas/test-$(hostname)"

# Disk space
ansible all -m shell -a "df -h /"
```

## Risk Levels

### 🟢 LOW RISK
- Documentation updates
- Adding new configurations without changing existing
- Non-critical service additions

### 🟡 MEDIUM RISK
- Configuration changes to existing services
- New tool installations
- Performance optimizations

### 🔴 HIGH RISK
- Shell configuration changes (affects user access)
- Critical service modifications (NFS, SSH, DNS)
- UID/GID changes
- System-level modifications

## Approval Requirements

### LOW RISK
- Self-approved with proper testing
- Document changes in git commit

### MEDIUM RISK
- Test on single node first
- Document rollback plan
- Monitor for 24 hours

### HIGH RISK
- Create detailed change plan
- Test extensively on isolated node
- Have emergency access ready
- Plan for potential extended maintenance window

Remember: **When in doubt, don't deploy**. It's always better to be safe with production infrastructure.