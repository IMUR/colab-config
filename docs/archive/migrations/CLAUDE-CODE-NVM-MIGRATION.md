# 🎯 Claude-Code NVM Migration Plan for CRTR

**📍 File Location**: `CLAUDE-CODE-NVM-MIGRATION.md`

---

## Executive Summary

**Problem**: Claude-code installed via NVM creates dependency and path resolution conflicts, particularly affecting search features and credential discovery on crtr.

**Solution**: Implement dual Node.js environment - system Node for tools, NVM for development.

**Current Status**: 🔴 Assessment Phase - Ready to begin implementation

## 📊 Phase 1: Environmental Assessment

### Current State Discovery

```bash
# Run these commands on crtr to assess current state

# 1. Check for system Node.js
ssh crtr "which node && node --version || echo 'No system Node found'"
ssh crtr "ls -la /usr/bin/node 2>/dev/null || echo '/usr/bin/node does not exist'"

# 2. Check NVM installation
ssh crtr "[ -d ~/.nvm ] && echo 'NVM installed at ~/.nvm' && source ~/.nvm/nvm.sh && nvm --version"
ssh crtr "source ~/.nvm/nvm.sh && nvm list"

# 3. Check claude-code installation
ssh crtr "which claude-code && claude-code --version || echo 'claude-code not found in PATH'"
ssh crtr "source ~/.nvm/nvm.sh && which claude-code && claude-code --version"

# 4. Check authentication/credentials
ssh crtr "ls -la ~/.claude* 2>/dev/null || echo 'No .claude files found'"
ssh crtr "ls -la ~/.config/claude* 2>/dev/null || echo 'No claude config found'"

# 5. Test current functionality
ssh crtr "source ~/.nvm/nvm.sh && claude-code search test 2>&1 | head -5"
```

### Expected Findings

- ❓ System Node.js: Likely missing or outdated
- ✅ NVM: Installed at `~/.nvm` (confirmed via omni-config)
- ❓ claude-code: Installed via NVM, path issues when NVM not sourced
- ❓ Search functionality: Likely broken due to path resolution

## 💾 Phase 2: State Preservation

### Backup Current Configuration

```bash
# Create timestamped backup directory
ssh crtr "
    BACKUP_DIR=~/.archive/claude-backup-$(date +%Y%m%d-%H%M%S)
    mkdir -p \$BACKUP_DIR
    
    # Backup claude configurations
    [ -d ~/.claude ] && cp -r ~/.claude \$BACKUP_DIR/
    [ -f ~/.claude.json ] && cp ~/.claude.json \$BACKUP_DIR/
    
    # Backup NVM state
    echo 'NVM_DIR=$NVM_DIR' > \$BACKUP_DIR/nvm-environment.txt
    source ~/.nvm/nvm.sh && nvm list > \$BACKUP_DIR/nvm-versions.txt
    which claude-code > \$BACKUP_DIR/claude-path.txt 2>&1
    
    # Document current functionality
    cat > \$BACKUP_DIR/functionality-status.md << 'EOF'
# Claude-Code Functionality Status
Date: $(date)
Node: crtr

## Working Features:
- [ ] Basic execution
- [ ] Search functionality  
- [ ] Agent detection
- [ ] Authentication

## Issues:
- Path resolution when NVM not sourced
- Search features fail
- Credential discovery issues
EOF

    echo 'Backup created at: '\$BACKUP_DIR
"
```

## 🔧 Phase 3: System Node Establishment

### Install System Node.js (Debian/Ubuntu)

```bash
# Check current system and install appropriate Node.js
ssh crtr "
    # Check if system Node exists and version
    if [ -f /usr/bin/node ]; then
        echo 'System Node exists:'
        /usr/bin/node --version
        
        # Check if version is adequate (≥18.x)
        NODE_VERSION=\$(/usr/bin/node --version | sed 's/v//' | cut -d. -f1)
        if [ \$NODE_VERSION -ge 18 ]; then
            echo '✅ System Node version is adequate'
        else
            echo '⚠️ System Node version is too old, upgrade needed'
        fi
    else
        echo '❌ No system Node found, installation needed'
    fi
    
    # Install/Update system Node.js
    sudo apt update
    sudo apt install -y nodejs npm
    
    # Verify installation
    /usr/bin/node --version
    /usr/bin/npm --version
"
```

### Alternative: NodeSource Repository (if needed for newer version)

```bash
# Only use if distribution package is too old
ssh crtr "
    # Setup NodeSource repository for Node.js 20.x LTS
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    # Verify
    /usr/bin/node --version
"
```

## 🔄 Phase 4: Claude-Code Migration

### Remove NVM-managed claude-code

```bash
ssh crtr "
    # Uninstall current claude-code gracefully
    source ~/.nvm/nvm.sh
    npm uninstall -g claude-code
    
    # Clean up any broken symlinks
    [ -L /usr/local/bin/claude-code ] && sudo rm /usr/local/bin/claude-code
    
    # Clear npm cache
    npm cache clean --force
"
```

### Install claude-code with System Node

```bash
ssh crtr "
    # Install claude-code globally using system npm [[memory:8185466]]
    sudo /usr/bin/npm install -g claude-code
    
    # Verify installation location and shebang
    which claude-code
    head -1 \$(which claude-code)
    
    # Test without NVM environment
    /usr/local/bin/claude-code --version
"
```

## ⚙️ Phase 5: Configuration Integration

### Update omni-config for Dual Environment

Create enhanced NVM loader that preserves system tools:

```bash
# ... existing code ...
cat > omni-config/.chezmoitemplate.nvm-loader-enhanced.sh << 'EOF'
# Enhanced NVM Loader - Preserves system tools
# This maintains dual Node.js environment:
# - System Node (/usr/bin/node) for tools like claude-code
# - NVM Node (~/.nvm) for development projects

# Save system tool paths before NVM modifies PATH
if command -v claude-code >/dev/null 2>&1; then
    export CLAUDE_CODE_PATH="$(which claude-code)"
fi

# Only load NVM if the directory exists and contains the script
if [ -n "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
    # Source the main NVM script to load shell functions
    . "$NVM_DIR/nvm.sh"
    
    # Load bash completion if available
    if [ -s "$NVM_DIR/bash_completion" ]; then
        . "$NVM_DIR/bash_completion"
    fi
    
    # Create aliases for system tools to ensure they're always accessible
    if [ -n "$CLAUDE_CODE_PATH" ]; then
        alias claude-code="$CLAUDE_CODE_PATH"
    fi
fi
EOF
```

### Update shell configurations

```bash
# Update dot_bashrc.tmpl
sed -i 's/{{ include ".chezmoitemplate.nvm-loader.sh" | trim }}/{{ include ".chezmoitemplate.nvm-loader-enhanced.sh" | trim }}/' omni-config/dot_bashrc.tmpl

# Update dot_zshrc.tmpl  
sed -i 's/{{ include ".chezmoitemplate.nvm-loader.sh" | trim }}/{{ include ".chezmoitemplate.nvm-loader-enhanced.sh" | trim }}/' omni-config/dot_zshrc.tmpl
```

## ✅ Phase 6: Validation & Testing

### Comprehensive Testing Suite

```bash
ssh crtr "
    echo '=== CLAUDE-CODE MIGRATION VALIDATION ==='
    
    # Test 1: System Node accessible
    echo -n 'System Node: '
    /usr/bin/node --version || echo 'FAILED'
    
    # Test 2: Claude-code without NVM
    echo -n 'Claude-code (no NVM): '
    claude-code --version || echo 'FAILED'
    
    # Test 3: Claude-code with NVM active
    echo -n 'Claude-code (with NVM): '
    source ~/.nvm/nvm.sh && claude-code --version || echo 'FAILED'
    
    # Test 4: Search functionality
    echo 'Search test:'
    claude-code search 'test query' 2>&1 | head -3
    
    # Test 5: Agent detection
    echo 'Agent detection:'
    claude-code agent list 2>&1 | head -3
    
    # Test 6: NVM development still works
    echo -n 'NVM Node: '
    source ~/.nvm/nvm.sh && node --version || echo 'FAILED'
"
```

## 🔧 Phase 7: Configuration Restoration

### Restore Working Configurations

```bash
ssh crtr "
    # Check for existing .claude directory
    if [ -d ~/.claude ]; then
        echo 'Found existing .claude configuration'
        
        # Migrate credentials if needed
        if [ -f ~/.claude/credentials.json ]; then
            echo 'Migrating credentials...'
            # claude-code may auto-detect, or may need manual config
        fi
    fi
    
    # Test authentication
    claude-code auth status || echo 'May need re-authentication'
"
```

## 🚨 Rollback Strategy

### If Issues Arise

```bash
ssh crtr "
    # Remove system claude-code
    sudo npm uninstall -g claude-code
    
    # Reinstall via NVM
    source ~/.nvm/nvm.sh
    npm install -g claude-code
    
    # Restore backed up configurations
    LATEST_BACKUP=\$(ls -td ~/.archive/claude-backup-* | head -1)
    [ -d \"\$LATEST_BACKUP\" ] && cp -r \$LATEST_BACKUP/.claude* ~/
    
    echo 'Rolled back to NVM-based installation'
"
```

## 📝 Success Criteria Checklist

- [ ] System Node.js installed at `/usr/bin/node` (version ≥18.x)
- [ ] claude-code installed globally via system npm
- [ ] claude-code accessible without sourcing NVM
- [ ] Search functionality fully operational
- [ ] Agent detection working properly
- [ ] Authentication configured correctly
- [ ] NVM still functional for development
- [ ] No PATH conflicts between environments

## 🎯 Expected Outcome

After successful implementation:

- **System Node** at `/usr/bin/node` - stable, predictable path
- **claude-code** at `/usr/local/bin/claude-code` - always accessible
- **NVM Node** at `~/.nvm` - available for development projects
- **Clean separation** - tools vs development environments
- **Full functionality** - search, agents, auth all working

## 📊 Implementation Timeline

1. **Phase 1**: Assessment (15 min)
2. **Phase 2**: Backup (10 min)
3. **Phase 3**: System Node setup (20 min)
4. **Phase 4**: Migration (15 min)
5. **Phase 5**: Configuration (20 min)
6. **Phase 6**: Testing (15 min)
7. **Phase 7**: Restoration (10 min)

**Total estimated time**: ~1.5-2 hours with validation

## 🔍 Troubleshooting Guide

### Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| `command not found: claude-code` | Not in PATH | Check `/usr/local/bin/` in PATH |
| Search still broken | Native modules issue | Rebuild: `npm rebuild` |
| Wrong Node version used | NVM overriding | Use absolute path: `/usr/local/bin/claude-code` |
| Authentication lost | Config path changed | Re-authenticate: `claude-code auth login` |
| Agents not detected | Path resolution | Check agent paths in config |

## 📋 Post-Migration Tasks

1. Update omni-config documentation with claude-code installation method
2. Add claude-code to system tool detection in `dot_profile.tmpl`
3. Document in `.archive/` the old NVM-based installation
4. Create validation script for future deployments
5. Test on prtr and drtr after crtr success

---

**Status**: Ready for implementation on crtr
**Risk Level**: Low (reversible, user-space changes only)
**Validation**: Comprehensive test suite included
