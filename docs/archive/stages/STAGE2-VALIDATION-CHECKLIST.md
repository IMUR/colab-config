# Stage 2: Omni-Config Validation Checklist

**Purpose**: Comprehensive validation of omni-config deployment across all cluster nodes
**Scope**: User-level configurations managed by chezmoi
**Nodes**: cooperator (crtr), projector (prtr), director (drtr)
**Last Updated**: 2025-01-19

## 🎯 Quick Validation Commands

### Standard Validation
```bash
# Run automated validation
bash /cluster-nas/colab/colab-config/scripts/validate-omniconfig.sh

# Validate all nodes from gateway
bash /cluster-nas/colab/colab-config/scripts/validate-omniconfig.sh all
```

### Change-Aware Validation (Recommended)
```bash
# Validate only what changed since last update
bash /cluster-nas/colab/colab-config/scripts/validate-omniconfig-changes.sh

# Run on all nodes with change tracking
for node in crtr prtr drtr; do
    ssh "$node" 'bash /cluster-nas/colab/colab-config/scripts/validate-omniconfig-changes.sh'
done

# Preview pending updates before applying
bash /cluster-nas/colab/colab-config/scripts/validate-omniconfig-changes.sh --preview
```

## ✅ Core Configuration Files

### Essential Dotfiles
- [ ] `~/.profile` exists and is managed by chezmoi
- [ ] `~/.bashrc` exists (templated from dot_bashrc.tmpl)
- [ ] `~/.zshrc` exists (templated from dot_zshrc.tmpl)
- [ ] `~/.config/starship.toml` exists
- [ ] Files have correct content (not empty/corrupted)

### Verification Commands
```bash
# Check file presence and management
chemzoi managed | grep -E "\.profile|\.bashrc|\.zshrc|starship\.toml"

# Verify files are not empty
[[ -s ~/.profile ]] && echo "✓ .profile has content"
[[ -s ~/.bashrc ]] && echo "✓ .bashrc has content"
[[ -s ~/.zshrc ]] && echo "✓ .zshrc has content"
```

### Test bashrc/zshrc loading without errors
```bash
# Test on each node
ssh crtr "bash -c 'source ~/.bashrc 2>&1 && echo SUCCESS || echo FAILED'"
ssh prtr "bash -c 'source ~/.bashrc 2>&1 && echo SUCCESS || echo FAILED'"
ssh drtr "bash -c 'source ~/.bashrc 2>&1 && echo SUCCESS || echo FAILED'"

# For zsh users (if applicable)
ssh crtr "zsh -c 'source ~/.zshrc 2>&1 && echo SUCCESS || echo FAILED'"
ssh prtr "zsh -c 'source ~/.zshrc 2>&1 && echo SUCCESS || echo FAILED'"
ssh drtr "zsh -c 'source ~/.zshrc 2>&1 && echo SUCCESS || echo FAILED'"
```

---

## 🔧 Tool Detection System

### Environment Variables (from .profile)
- [ ] `NODE_ROLE` set to hostname
- [ ] `ARCH` set to system architecture
- [ ] `HAS_EZA` detection works
- [ ] `HAS_BAT` detection works
- [ ] `HAS_FD` detection works
- [ ] `HAS_RG` (ripgrep) detection works
- [ ] `HAS_ZOXIDE` detection works
- [ ] `HAS_FZF` detection works
- [ ] `HAS_NNN` detection works
- [ ] `HAS_DELTA` detection works
- [ ] `HAS_DUST` detection works
- [ ] `HAS_STARSHIP` detection works
- [ ] `HAS_ATUIN` detection works
- [ ] `HAS_FASTFETCH` detection works

### Verification Commands
```bash
# Source profile and check all HAS_* variables
source ~/.profile
env | grep "^HAS_" | sort

# Verify detection matches reality
command -v eza >/dev/null && echo "✓ eza found, HAS_EZA=$HAS_EZA"
command -v bat >/dev/null || command -v batcat >/dev/null && echo "✓ bat found, HAS_BAT=$HAS_BAT"
```

### Verify NODE_ROLE and ARCH are set correctly
```bash
# Should show hostname and architecture for each node
ssh crtr 'bash -c "source ~/.profile; echo NODE_ROLE=\$NODE_ROLE, ARCH=\$ARCH"'
ssh prtr 'bash -c "source ~/.profile; echo NODE_ROLE=\$NODE_ROLE, ARCH=\$ARCH"'
ssh drtr 'bash -c "source ~/.profile; echo NODE_ROLE=\$NODE_ROLE, ARCH=\$ARCH"'
```

Expected results:
- crtr: NODE_ROLE=cooperator, ARCH=aarch64
- prtr: NODE_ROLE=projector, ARCH=x86_64
- drtr: NODE_ROLE=director, ARCH=x86_64

---

## 🚀 Modern CLI Tools

### File & Directory Tools
- [ ] `eza` or fallback `ls` aliases work
- [ ] `bat`/`batcat` or fallback `cat` works
- [ ] `fd`/`fdfind` or fallback `find` works
- [ ] `ripgrep` (`rg`) or fallback `grep` works
- [ ] `dust` or fallback `du` works

### Shell Enhancements
- [ ] `zoxide` (`z` command) initializes in zsh
- [ ] `fzf` key bindings work (Ctrl+R for history)
- [ ] `starship` prompt displays correctly
- [ ] `atuin` history sync (if configured)
- [ ] `fastfetch` system info display works

### Modern CLI Tools Availability

### Check which modern tools are installed
```bash
# Test on each node
for node in crtr prtr drtr; do
  echo "=== $node ==="
  ssh $node 'for cmd in eza bat batcat fd fdfind rg zoxide starship fastfetch; do
    command -v $cmd >/dev/null 2>&1 && echo "✅ $cmd" || echo "❌ $cmd"
  done'
done
```

---

## 📝 Aliases & Functions

### Navigation Aliases
- [ ] `..` → `cd ..`
- [ ] `...` → `cd ../..`
- [ ] `....` → `cd ../../..`

### Cluster-Specific Aliases
- [ ] `nas` → `cd /cluster-nas`
- [ ] `configs` → `cd /cluster-nas/configs`
- [ ] `colab` → `cd /cluster-nas/colab`
- [ ] `cluster` → `cd /cluster-nas` (zsh)
- [ ] `docs` → `cd /cluster-nas/documentation` (zsh)

### System Info
- [ ] `sysinfo` command works (zsh)

### Alias Definitions Test

### Test all configured aliases programmatically
```bash
# Test common aliases on all nodes
for node in crtr prtr drtr; do
  echo "=== $node aliases ==="
  ssh $node 'bash -c "source ~/.bashrc 2>/dev/null;
    # File listing aliases
    alias ll >/dev/null 2>&1 && echo \"✅ ll\" || echo \"❌ ll\"
    alias la >/dev/null 2>&1 && echo \"✅ la\" || echo \"❌ la\"
    alias l >/dev/null 2>&1 && echo \"✅ l\" || echo \"❌ l\"

    # Navigation aliases
    alias .. >/dev/null 2>&1 && echo \"✅ ..\" || echo \"❌ ..\"
    alias ... >/dev/null 2>&1 && echo \"✅ ...\" || echo \"❌ ...\"

    # Tool-specific aliases (if tools exist)
    command -v eza >/dev/null 2>&1 && alias ls >/dev/null 2>&1 && echo \"✅ ls->eza\" || echo \"⚠️  eza not installed\"
    command -v bat >/dev/null 2>&1 && alias cat >/dev/null 2>&1 && echo \"✅ cat->bat\" || echo \"⚠️  bat not installed\"

    # Service management alias
    alias services >/dev/null 2>&1 && echo \"✅ services\" || echo \"❌ services\"

    # Git aliases
    alias gs >/dev/null 2>&1 && echo \"✅ gs (git status)\" || echo \"❌ gs\"
    alias gd >/dev/null 2>&1 && echo \"✅ gd (git diff)\" || echo \"❌ gd\"
    alias gl >/dev/null 2>&1 && echo \"✅ gl (git log)\" || echo \"❌ gl\"
  "'
done
```

### Check if common aliases work in interactive shell
```bash
# Connect and test interactively
ssh crtr
ll      # Should list files with details
la      # Should list all files
services # Should show active services
exit

ssh prtr
ll      # Should list files with details
la      # Should list all files
services # Should show active services
exit

ssh drtr
ll      # Should list files with details
la      # Should list all files
services # Should show active services
exit
```

---

## 5. Runtime Detection Tests

### Verify GPU detection (should fail on prtr/drtr until Stage 3)
```bash
ssh prtr 'if command -v nvidia-smi >/dev/null 2>&1; then echo "GPU tools detected"; else echo "No GPU tools (expected)"; fi'
ssh drtr 'if command -v nvidia-smi >/dev/null 2>&1; then echo "GPU tools detected"; else echo "No GPU tools (expected)"; fi'
```

### Verify Docker detection (should fail on prtr/drtr until Stage 3)
```bash
ssh prtr 'if command -v docker >/dev/null 2>&1; then echo "Docker detected"; else echo "No Docker (expected)"; fi'
ssh drtr 'if command -v docker >/dev/null 2>&1; then echo "Docker detected"; else echo "No Docker (expected)"; fi'
```

---

## 🔄 Chezmoi State & Change Tracking

### Configuration Management
- [ ] Chezmoi initialized with GitHub remote
- [ ] Latest changes applied from repository
- [ ] No uncommitted local changes
- [ ] Template variables set correctly
- [ ] Synchronization status with remote
- [ ] Change history tracked properly

### Change Tracking Commands
```bash
# Check what changed since last update
bash /cluster-nas/colab/colab-config/scripts/validate-omniconfig-changes.sh

# Preview what would be updated
bash /cluster-nas/colab/colab-config/scripts/validate-omniconfig-changes.sh --preview

# Check changes since specific commit
bash /cluster-nas/colab/colab-config/scripts/validate-omniconfig-changes.sh --since HEAD~5

# Full validation (ignore change tracking)
bash /cluster-nas/colab/colab-config/scripts/validate-omniconfig-changes.sh --full
```

### Chezmoi Update Tracking
```bash
# View recent configuration commits
chezmoi git -- log --oneline -10

# Check what files are managed
chezmoi managed | grep -E "profile|bashrc|zshrc"

# See what changed in last update
chezmoi git -- diff HEAD~1..HEAD --name-only

# Check synchronization status
chezmoi git -- status
chezmoi git -- fetch origin
chezmoi git -- diff HEAD..origin/main --stat
```

### Chezmoi Status Check

### Verify chezmoi is installed and up to date
```bash
# Check chezmoi status on each node
ssh crtr "chezmoi status | head -5"
ssh prtr "chezmoi status | head -5"
ssh drtr "~/.local/bin/chezmoi status | head -5"

# Verify no template errors
ssh crtr "chezmoi verify && echo '✅ Templates OK' || echo '❌ Template errors'"
ssh prtr "chezmoi verify && echo '✅ Templates OK' || echo '❌ Template errors'"
ssh drtr "~/.local/bin/chezmoi verify && echo '✅ Templates OK' || echo '❌ Template errors'"
```

---

## 🛤️ PATH Configuration

### User Paths (highest priority)
- [ ] `~/.local/bin` in PATH (if exists)
- [ ] `~/bin` in PATH (if exists)
- [ ] `~/.cargo/bin` in PATH (if exists)

### System Paths
- [ ] `/usr/local/bin` in PATH
- [ ] `/usr/bin` in PATH
- [ ] `/bin` in PATH
- [ ] `/snap/bin` in PATH (if exists)

### Development Paths
- [ ] NVM_DIR set to `~/.nvm` (if exists)
- [ ] CUDA paths set (if GPU node)

### PATH Configuration Test

### Check PATH includes necessary directories
```bash
# Should show local bin directories in PATH
ssh crtr 'echo $PATH | tr ":" "\n" | grep -E "(\.local/bin|\.cargo/bin)" | head -3'
ssh prtr 'echo $PATH | tr ":" "\n" | grep -E "(\.local/bin|\.cargo/bin)" | head -3'
ssh drtr 'echo $PATH | tr ":" "\n" | grep -E "(\.local/bin|\.cargo/bin)" | head -3'
```

---

## 8. Shell Prompt Test

### Check if custom prompt is working
```bash
# Connect interactively and check prompt
ssh crtr
# Should see custom prompt with heart (♥) symbol
exit

ssh prtr
# Should see custom prompt with heart (♥) symbol
exit

ssh drtr
# Should see custom prompt with heart (♥) symbol
exit
```

---

## 9. Development Tools Check

### Verify development tools availability
```bash
for node in crtr prtr drtr; do
  echo "=== $node ==="
  ssh $node 'for cmd in git python3 cargo node npm; do
    command -v $cmd >/dev/null 2>&1 && echo "✅ $cmd" || echo "❌ $cmd"
  done'
done
```

---

## 10. NFS Mount Verification

### Check cluster-nas is accessible
```bash
ssh crtr "ls /cluster-nas/colab >/dev/null 2>&1 && echo '✅ NFS accessible' || echo '❌ NFS issue'"
ssh prtr "ls /cluster-nas/colab >/dev/null 2>&1 && echo '✅ NFS accessible' || echo '❌ NFS issue'"
ssh drtr "ls /cluster-nas/colab >/dev/null 2>&1 && echo '✅ NFS accessible' || echo '❌ NFS issue'"
```

---

## Quick All-In-One Test

### Run this for a complete quick validation:
```bash
echo "=== Stage 2 Validation Starting ===" && \
for node in crtr prtr drtr; do
  echo -e "\n--- Testing $node ---"
  ssh $node "bash -c '
    # Test shell loading
    source ~/.bashrc 2>/dev/null && echo \"✅ bashrc loads\" || echo \"❌ bashrc fails\"
    source ~/.profile 2>/dev/null && echo \"✅ profile loads\" || echo \"❌ profile fails\"

    # Test environment
    [[ -n \$NODE_ROLE ]] && echo \"✅ NODE_ROLE set: \$NODE_ROLE\" || echo \"❌ NODE_ROLE missing\"
    [[ -n \$ARCH ]] && echo \"✅ ARCH set: \$ARCH\" || echo \"❌ ARCH missing\"

    # Test modern CLI tools
    command -v eza >/dev/null 2>&1 && echo \"✅ eza available\" || echo \"❌ eza missing\"
    command -v rg >/dev/null 2>&1 && echo \"✅ ripgrep available\" || echo \"❌ ripgrep missing\"
    command -v fzf >/dev/null 2>&1 && echo \"✅ fzf available\" || echo \"❌ fzf missing\"
    command -v zoxide >/dev/null 2>&1 && echo \"✅ zoxide available\" || echo \"❌ zoxide missing\"
    command -v starship >/dev/null 2>&1 && echo \"✅ starship available\" || echo \"❌ starship missing\"

    # Test aliases are defined
    source ~/.bashrc 2>/dev/null
    alias ll >/dev/null 2>&1 && echo \"✅ ll alias defined\" || echo \"❌ ll alias missing\"
    alias la >/dev/null 2>&1 && echo \"✅ la alias defined\" || echo \"❌ la alias missing\"
    alias services >/dev/null 2>&1 && echo \"✅ services alias defined\" || echo \"❌ services alias missing\"

    # Test development tools
    command -v git >/dev/null 2>&1 && echo \"✅ git available\" || echo \"❌ git missing\"
    command -v python3 >/dev/null 2>&1 && echo \"✅ python3 available\" || echo \"❌ python3 missing\"

    # Test NFS
    ls /cluster-nas >/dev/null 2>&1 && echo \"✅ NFS mounted\" || echo \"❌ NFS not mounted\"
  '"
done && \
echo -e "\n=== Stage 2 Validation Complete ==="
```

---

## 📊 Validation Summary

### Quick Health Check
```bash
# Count passed checks
source ~/.profile
CHECKS_PASSED=0
CHECKS_TOTAL=0

# File checks
for file in ~/.profile ~/.bashrc ~/.zshrc ~/.config/starship.toml; do
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    [[ -f "$file" ]] && CHECKS_PASSED=$((CHECKS_PASSED + 1))
done

# Tool detection checks
for var in HAS_EZA HAS_BAT HAS_FD HAS_RG HAS_FZF HAS_STARSHIP; do
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    eval "[[ \$$var == 1 ]] || [[ \$$var == 0 ]]" && CHECKS_PASSED=$((CHECKS_PASSED + 1))
done

echo "Validation: $CHECKS_PASSED/$CHECKS_TOTAL checks passed"
```

### Node Comparison
```bash
# Run from gateway to compare all nodes
for node in crtr prtr drtr; do
    echo "=== $node ==="
    ssh "$node" 'source ~/.profile && env | grep "^HAS_" | wc -l'
done
```

## ✨ Success Criteria

✅ **Stage 2 is successful if:**
1. All shell configurations load without errors
2. Environment variables (NODE_ROLE, ARCH) are set correctly
3. No template parsing errors from chezmoi
4. Basic aliases work (ll, la, etc.)
5. NFS mounts are accessible on all nodes
6. No GPU/Docker tools on prtr/drtr (expected - removed in Stage 1)

❌ **Issues to investigate:**
- Shell configuration errors
- Missing environment variables
- Chezmoi template errors
- NFS mount failures
- Unexpected presence of Docker/NVIDIA tools on prtr/drtr

---

## 🔍 Troubleshooting

### Common Issues & Fixes

1. **Files not managed by chezmoi**
   ```bash
   chezmoi add ~/.profile ~/.bashrc ~/.zshrc
   chezmoi apply
   ```

2. **Tool detection incorrect**
   ```bash
   # Reinstall detection in .profile
   source ~/.profile
   # Check actual tool availability
   which eza bat fd rg fzf starship
   ```

3. **Aliases not working**
   ```bash
   # Check if sourced properly
   bash -c 'source ~/.bashrc && alias'
   # Verify in current shell
   source ~/.bashrc && type ls
   ```

4. **Chezmoi out of sync**
   ```bash
   chezmoi update  # Pull latest from GitHub
   chezmoi diff    # Check differences
   chezmoi apply   # Apply changes
   ```

## 📋 Manual Validation Steps

For thorough manual validation:

1. **Open new terminal session** on each node
2. **Check prompt appearance** - should show starship theme
3. **Test basic commands**:
   - `ls` - should show colors/icons with eza
   - `cat README.md` - should show syntax highlighting with bat
   - `cd nas` - should navigate to /cluster-nas
   - `z cluster` - should work if zoxide installed
4. **Verify history**:
   - Up arrow shows command history
   - Ctrl+R opens history search (fzf if available)
5. **Test completion**:
   - Type `cd /` and press Tab - should show options
   - Type `git ` and press Tab - should show subcommands

## Notes for Validation

- Run tests in order for systematic validation
- The "Quick All-In-One Test" provides rapid validation
- Interactive tests (prompts, aliases) require actual SSH connection
- Missing bat/fd tools are not critical - nice to have but not required
- GPU/Docker absence on prtr/drtr is EXPECTED (will be installed in Stage 3)

