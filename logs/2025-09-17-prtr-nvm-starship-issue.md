# Issue Report: NVM and Starship Functionality on projector (prtr)

**Date**: 2025-09-17
**Reporter**: Claude Code Agent
**Severity**: Medium - User experience impact, functionality partially broken
**Scope**: projector node (prtr) only

## Problem Summary

The `nvm` command is not available in SSH sessions on the projector node (prtr), despite:
- NVM being properly installed at `~/.nvm/`
- Node.js binaries existing at `~/.nvm/versions/node/v22.18.0/`
- Starship binary existing at `~/.local/bin/starship`
- Chezmoi template system deployed and processing correctly

## Technical Analysis

### Current State on projector (prtr)

**NVM Installation Status**:
```bash
✅ NVM directory exists: ~/.nvm/ (confirmed)
✅ Node.js installed: v22.18.0 (confirmed)
✅ NVM script exists: ~/.nvm/nvm.sh (confirmed)
❌ NVM shell functions not loaded in SSH sessions
```

**PATH Analysis**:
```bash
# SSH session PATH (problematic):
/usr/local/bin:/usr/bin:/bin:/usr/games

# After sourcing ~/.profile (working):
/home/prtr/.nvm/versions/node/v22.18.0/bin:/home/prtr/.cargo/bin:/home/prtr/bin:/home/prtr/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/games

# After sourcing ~/.zshrc (working):
/home/prtr/.local/bin:/home/prtr/.nvm/versions/node/v22.18.0/bin:/home/prtr/.cargo/bin:/home/prtr/bin:/home/prtr/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/games
```

**Starship Availability**:
```bash
✅ Binary exists: /home/prtr/.local/bin/starship
✅ Version: starship 1.23.0 (confirmed working when PATH is correct)
✅ Config file: ~/.config/starship.toml (deployed by chezmoi)
❌ Not available in SSH sessions due to PATH issue
```

### Root Cause Analysis

**Primary Issue**: **Shell initialization order in SSH sessions**

1. **SSH Sessions Don't Auto-Source Shell Configs**: Non-interactive SSH commands use minimal PATH
2. **NVM Functions Not Loaded**: NVM shell functions (`nvm use`, `nvm install`) only available after sourcing shell RC files
3. **Template Processing Working**: The `{{ include }}` errors are resolved, templates are rendering correctly
4. **Configuration Consistency**: All nodes have identical chezmoi-managed configurations

**Specific SSH Behavior**:
- **Interactive SSH**: When you `ssh prtr` and get a shell, it eventually loads `.zshrc` and NVM works
- **Non-interactive SSH**: When running `ssh prtr "command"`, minimal environment is used
- **Profile Loading**: `.profile` contains PATH setup but SSH doesn't always source it

### Comparison with Working Nodes

**cooperator (crtr)** - ✅ **Working**:
- NVM functions available in SSH sessions
- Starship prompt working
- PATH includes `~/.local/bin`

**director (drtr)** - ✅ **Working**:
- NVM functions available in interactive sessions
- Starship prompt working
- PATH properly configured

**projector (prtr)** - ❌ **Problematic**:
- NVM functions not available in SSH sessions
- Starship not found in basic SSH PATH
- Requires manual shell sourcing for full functionality

### Environment Differences

**Shell Configuration Loading Order**:
```bash
# What happens during SSH login:
1. SSH connects with minimal PATH: /usr/local/bin:/usr/bin:/bin:/usr/games
2. Login shell should source ~/.profile (contains PATH additions)
3. Interactive shell sources ~/.zshrc (contains NVM function loading)
4. NVM functions should then be available

# Issue: Step 2 or 3 not happening consistently on prtr
```

**File Comparison Across Nodes**:
```bash
# All nodes should have identical files due to chezmoi:
✅ ~/.profile - identical (managed by chezmoi)
✅ ~/.zshrc - identical (from dot_zshrc.tmpl)
✅ ~/.bashrc - identical (from dot_bashrc.tmpl)

# But behavior differs - suggests shell initialization differences
```

## Diagnostic Information

### Chezmoi Status on prtr

**Template Processing**:
```bash
✅ Chezmoi managing: .bashrc, .zshrc, .profile, .config/starship.toml
✅ Template rendering: Node role = "compute", hostname = "projector"
✅ No template syntax errors in current deployment
```

**Managed Files Check**:
```bash
$ ssh prtr "chezmoi managed | grep -E '(bashrc|zshrc|profile)'"
.bashrc
.profile
.zshrc
```

### NVM Loading Analysis

**Template Include System**:
```bash
# Current template structure:
omni-config/
├── .chezmoitemplate.nvm-loader.sh  # Shared NVM loading logic
├── dot_zshrc.tmpl                  # Includes NVM loader
├── dot_bashrc.tmpl                 # Includes NVM loader
└── dot_profile                     # Sets NVM_DIR environment variable
```

**Expected Template Processing**:
```bash
# In dot_zshrc.tmpl:
if [[ $HAS_NVM == 1 ]]; then
{{ include ".chezmoitemplate.nvm-loader.sh" | trim }}
fi

# Should render to:
if [[ $HAS_NVM == 1 ]]; then
# [content of nvm-loader.sh template]
fi
```

### Shell Environment Variables

**HAS_NVM Detection**:
```bash
# From ~/.profile:
export HAS_NVM=$([[ -d "$HOME/.nvm" ]] && echo 1 || echo 0)

# Should be: HAS_NVM=1 (since ~/.nvm exists)
# Need to verify this is working correctly on prtr
```

## Potential Solutions

### Option 1: Verify Template Processing
```bash
# Check if template includes are actually rendering content:
ssh prtr "grep -A10 'HAS_NVM' ~/.zshrc"
ssh prtr "grep -A10 'HAS_NVM' ~/.bashrc"

# Verify HAS_NVM variable is set:
ssh prtr "source ~/.profile && echo HAS_NVM=\$HAS_NVM"
```

### Option 2: Check Shell Login Configuration
```bash
# Verify profile is being loaded during SSH login:
ssh prtr "echo 'Profile sourced' >> ~/.profile && ssh prtr 'grep Profile ~/.profile'"

# Check if login shell vs interactive shell difference:
ssh prtr "echo \$0"  # Check what shell type SSH is using
```

### Option 3: Force Shell Configuration Loading
```bash
# Ensure profile is loaded for SSH sessions by updating shell files:
# Add explicit profile sourcing to ensure environment is set
```

## Next Steps

1. **Verify template rendering** - Confirm `{{ include }}` is actually processed
2. **Check HAS_NVM variable** - Ensure NVM detection is working
3. **Test shell initialization order** - Understand why prtr behaves differently
4. **Compare working vs broken sessions** - Find the specific difference in initialization

## Expected Outcome

After resolution, `ssh prtr "command -v nvm"` should return `/home/prtr/.nvm/nvm.sh` functions, and `ssh prtr "command -v starship"` should return `/home/prtr/.local/bin/starship`.

---

**Status**: Under Investigation
**Assigned**: Claude Code Agent
**Priority**: Medium (affects user experience on compute node)