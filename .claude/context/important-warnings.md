# Important Warnings and Constraints

Critical information Claude Code must be aware of when working with this repository.

## 🚨 CRITICAL WARNINGS

### 1. DO NOT BREAK CURRENT SYMLINK SYSTEM
- **Current State**: All 3 cluster nodes use symlinks to `/cluster-nas/configs/zsh/zshrc`
- **Status**: WORKING AND STABLE - used daily
- **Warning**: Any changes that break symlinks will immediately break shell access for all users
- **Test First**: Always test configuration changes on single node (drtr) before cluster-wide

### 2. UID/GID CONSTRAINTS - DO NOT CHANGE
- **cooperator (crtr)**: UID 1001 - REQUIRED for NFS ownership
- **projector (prtr)**: UID 1000 - Established with existing services
- **director (drtr)**: UID 1000 - Established with existing services
- **Cluster Group**: GID 2000 - Required for shared file access
- **File Permissions**: 777/666 - Required for NFS application compatibility
- **Warning**: Changing UIDs will break existing services and file ownership

### 3. NFS DEPENDENCY - CRITICAL SERVICE
- **Server**: cooperator (crtr) hosts NFS at `/cluster-nas`
- **Clients**: projector (prtr) and director (drtr) mount `/cluster-nas`
- **Current Configs**: Depend on NFS being available
- **Warning**: NFS failures immediately break current configuration system
- **Service**: `nfs-server` on crtr must remain stable

### 4. PRODUCTION ENVIRONMENT
- **Live System**: This manages active production infrastructure
- **User Impact**: Changes affect daily operations and user access
- **Service Dependencies**: Web services, DNS, automation depend on these configs
- **Warning**: Failed deployments can disrupt entire cluster operation

## ⚠️ SAFETY CONSTRAINTS

### 5. DEPLOYMENT RESTRICTIONS
- **Test First**: Always use `--limit drtr` for initial testing
- **Backup Required**: Never deploy without recent backup
- **Gradual Rollout**: Deploy one node at a time, validate each step
- **Rollback Ready**: Have tested rollback procedures available

### 6. FILE SYSTEM CONSTRAINTS
- **NFS Permissions**: Files must be world-writable (666/777) for application compatibility
- **Symlink Targets**: Must exist and be accessible when symlinks are dereferenced
- **Path Dependencies**: Many scripts and configs assume `/cluster-nas` is always available

### 7. SERVICE DEPENDENCIES
- **SSH Access**: Shell configuration changes can break SSH if misconfigured
- **Web Services**: Caddy, Pi-hole, Cockpit depend on system stability
- **Automation**: Ansible, Semaphore require working shell environments

## 📋 MANDATORY PRE-CHECKS

### Before Any Configuration Change
1. **Cluster Health**: All nodes accessible and healthy
2. **Recent Backup**: Backup created within 24 hours
3. **NFS Status**: `/cluster-nas` mounted and accessible on all nodes
4. **Service Status**: No failed services on any node
5. **Disk Space**: Adequate space for operations (>20% free)

### Before Shell Configuration Changes
1. **Current Test**: Verify current shell configs work on all nodes
2. **Syntax Check**: Validate new configurations before deployment
3. **Rollback Plan**: Document exact steps to restore previous config
4. **Emergency Access**: Ensure alternative access methods work

### Before Service Changes
1. **Service Dependencies**: Map all dependent services
2. **Impact Assessment**: Understand full scope of changes
3. **Maintenance Window**: Plan for potential service interruption
4. **Communication**: Notify users of potential impact

## 🔄 MIGRATION-SPECIFIC WARNINGS

### Current Migration Status
- **Symlinks**: Currently active and working
- **Chezmoi**: Prepared but not deployed
- **Mixed State**: Transition period requires extra caution
- **Fallback**: Symlinks must remain as safety net during transition

### Migration Constraints
- **Zero Downtime**: Migration must not disrupt daily operations
- **Reversible**: Every step must be reversible
- **Validated**: Each phase must be thoroughly tested
- **Gradual**: No "big bang" deployment allowed

## 💻 TECHNICAL CONSTRAINTS

### Ansible Limitations
- **SSH Dependencies**: Requires working shell environments
- **NFS Dependencies**: Many playbooks assume `/cluster-nas` access
- **User Permissions**: Must respect existing user/group structure
- **Service Restarts**: Some changes require service restarts with downtime

### Chezmoi Constraints
- **Initial Setup**: Requires working shell to bootstrap
- **Template Logic**: Must handle node differences correctly
- **Data Sources**: Must work with cluster-specific data
- **Rollback**: More complex than symlink rollback

### Hardware Constraints
- **cooperator**: ARM64 architecture (different from others)
- **Resource Usage**: Pi5 has limited resources compared to x86 nodes
- **Network Dependencies**: All nodes depend on cooperator for many services

## 🚨 EMERGENCY PROCEDURES

### If Shell Access Breaks
1. **Web Terminal**: https://ssh.ism.la
2. **Cockpit Console**: https://mng.ism.la
3. **Physical Access**: Direct console on cooperator
4. **Recovery**: `bash --norc` to bypass broken shell configs

### If NFS Fails
1. **Check NFS Server**: `systemctl status nfs-server` on crtr
2. **Restart NFS**: `systemctl restart nfs-server` on crtr
3. **Remount Clients**: `mount -a` on prtr/drtr
4. **Fallback**: Local copies of critical configs

### If Ansible Fails
1. **Manual SSH**: Direct SSH to individual nodes
2. **Local Commands**: Execute commands directly on nodes
3. **Service Commands**: `systemctl` for service management
4. **Backup Restore**: Manual restoration from `/cluster-nas/backups/`

## 📞 ESCALATION

### When to Escalate
- Multiple nodes become inaccessible
- Critical services (NFS, SSH, DNS) fail
- User access is significantly impacted
- Rollback procedures fail
- Data integrity concerns

### How to Escalate
1. **Document the issue** clearly
2. **Preserve evidence** (logs, error messages)
3. **Stop making changes** to prevent further impact
4. **Ensure emergency access** methods work
5. **Prepare for potential physical intervention**

Remember: **Infrastructure safety is paramount**. When in doubt, stop and seek guidance rather than risk production systems.