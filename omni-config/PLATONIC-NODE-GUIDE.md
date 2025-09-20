# Platonic-Node Reference Guide

**Purpose**: Build and maintain the theoretical ideal reference for omni-config deployment
**Scope**: Omni-config purview ONLY - user-level configurations that should be identical across all 3 cluster nodes
**Location**: `/cluster-nas/configs/platonic-node/`

## 🎯 Purpose and Scope Definition

### What Platonic-Node Represents
The platonic-node is a **reference implementation** that shows the exact state of a user's home directory after a successful omni-config deployment. It serves as:

- **Theoretical Ideal**: Perfect example of what every cluster node should achieve
- **Testing Sandbox**: Safe environment to test configuration changes before deployment
- **Validation Target**: Reference for checking deployment completeness
- **Documentation**: Living example of the omni-config specification

### Strict Scope Boundaries

**✅ INCLUDED (Omni-Config Purview):**
- Shell dotfiles (`.profile`, `.zshrc`, `.bashrc`)
- Modern CLI tool configurations and aliases
- Universal development tool configs (`.gitconfig`, `.tmux.conf`)
- Tool-specific configs (`.config/starship.toml`, `.config/fastfetch/`)
- Cross-architecture tool detection system
- Universal aliases and functions
- PATH management and environment variables

**❌ EXCLUDED (Outside Omni-Config Scope):**
- Service configurations (semaphore, caddy, pihole)
- Node-specific infrastructure (NFS server, GPU setup)
- System-level configurations (`/etc/`, systemd services)
- Security configurations (SSH keys, certificates)
- Network configurations (routing, firewall rules)
- Ansible-managed system settings

## 🏗️ Building the Platonic-Node

### Phase 1: Clear Outdated Content
```bash
# Remove outdated symlinks and minimal structure
rm -rf /cluster-nas/configs/platonic-node/*
rm -rf /cluster-nas/configs/platonic-node/.*
# Keep only the directory structure
mkdir -p /cluster-nas/configs/platonic-node
```

### Phase 2: Install Core Omni-Config Files
```bash
# Copy the primary omni-config files
cp /cluster-nas/configs/colab-remote-config/omni-config/dot_profile /cluster-nas/configs/platonic-node/.profile
cp /cluster-nas/configs/colab-remote-config/omni-config/dot_zshrc /cluster-nas/configs/platonic-node/.zshrc

# Create .bashrc as fallback shell configuration
# (Generated from omni-config principles but bash-compatible)

# Copy tool-specific configurations
mkdir -p /cluster-nas/configs/platonic-node/.config
cp -r /cluster-nas/configs/colab-remote-config/omni-config/dot_config/* /cluster-nas/configs/platonic-node/.config/
```

### Phase 3: Add Modern CLI Tool Configurations
```bash
# Create complete tool configuration suite

# Git configuration (universal settings)
cat > /cluster-nas/configs/platonic-node/.gitconfig << 'EOF'
# Generated from omni-config ideal
[core]
    editor = vim
    autocrlf = input
[color]
    ui = auto
[push]
    default = simple
[pull]
    rebase = false
[init]
    defaultBranch = main
EOF

# Tmux configuration (universal terminal multiplexing)
cat > /cluster-nas/configs/platonic-node/.tmux.conf << 'EOF'
# Generated from omni-config ideal
# Modern tmux configuration for cluster nodes
EOF

# Fastfetch configuration
mkdir -p /cluster-nas/configs/platonic-node/.config/fastfetch
cp /cluster-nas/configs/colab-remote-config/infrastructure/fastfetch/config.jsonc /cluster-nas/configs/platonic-node/.config/fastfetch/config.jsonc
```

### Phase 4: Add Infrastructure Tool Configs
```bash
# Copy infrastructure configurations that affect user experience
cp /cluster-nas/configs/colab-remote-config/infrastructure/starship/starship.toml /cluster-nas/configs/platonic-node/.config/starship.toml
```

### Phase 5: Create Tool Installation Reference
```bash
# Create directory showing where tools should be installed
mkdir -p /cluster-nas/configs/platonic-node/.local/bin
mkdir -p /cluster-nas/configs/platonic-node/.cargo/bin

# Create reference files showing expected tool locations
cat > /cluster-nas/configs/platonic-node/.local/bin/README.md << 'EOF'
# Tool Installation Targets

This directory shows where omni-config expects modern CLI tools to be installed:

## Expected Tools in ~/.local/bin:
- starship
- zoxide
- dust
- atuin
- chezmoi

## Package-Managed Tools (system PATH):
- eza
- bat (or batcat)
- fd (or fdfind)
- ripgrep
- fzf
- nnn
- git-delta
- fastfetch
EOF

cat > /cluster-nas/configs/platonic-node/.cargo/bin/README.md << 'EOF'
# Rust Tool Installation Targets

Some tools may be installed via cargo in ~/.cargo/bin/:
- (Alternative installation location for Rust-based tools)
EOF
```

## 🔧 Maintenance Procedures

### When to Update Platonic-Node

**Trigger Events:**
1. **Omni-config changes**: When any file in `omni-config/` is modified
2. **Tool additions**: When new CLI tools are added to the unified list
3. **Configuration improvements**: When shell configurations are enhanced
4. **Architecture updates**: When templating or detection logic changes

### How to Keep Synchronized

**Manual Sync Process:**
```bash
# 1. Review changes in omni-config/
cd /cluster-nas/configs/colab-remote-config/omni-config/
git diff HEAD~1 HEAD

# 2. Apply relevant changes to platonic-node
# Copy updated dot_* files
# Update tool configurations
# Add new tool configs if tools were added

# 3. Test platonic-node completeness
# Verify all omni-config components are represented
# Check that no service/system configs leaked in
```

**Automated Validation:**
```bash
# Script to verify platonic-node represents complete omni-config
#!/bin/bash
echo "=== Platonic-Node Validation ==="

# Check core files exist
CORE_FILES=(".profile" ".zshrc" ".bashrc" ".gitconfig" ".tmux.conf")
for file in "${CORE_FILES[@]}"; do
    [[ -f "/cluster-nas/configs/platonic-node/$file" ]] && echo "✅ $file" || echo "❌ $file missing"
done

# Check tool configs exist
TOOL_CONFIGS=(".config/starship.toml" ".config/fastfetch/config.jsonc")
for config in "${TOOL_CONFIGS[@]}"; do
    [[ -f "/cluster-nas/configs/platonic-node/$config" ]] && echo "✅ $config" || echo "❌ $config missing"
done

# Verify no system/service configs leaked in
FORBIDDEN_PATHS=(".ssh/id_*" ".config/systemd" "etc/" "services/")
for path in "${FORBIDDEN_PATHS[@]}"; do
    [[ -e "/cluster-nas/configs/platonic-node/$path" ]] && echo "⚠️ SCOPE VIOLATION: $path found" || echo "✅ $path correctly excluded"
done
```

## 🎯 Usage Instructions

### For Testing Configuration Changes
```bash
# 1. Make changes to platonic-node first
cd /cluster-nas/configs/platonic-node/
# Edit configurations

# 2. Test the configuration
# Source the shell configs to verify they work
# Test tool aliases and functions

# 3. Apply to omni-config if successful
# Update the corresponding dot_* files in omni-config/
# Deploy via chezmoi to cluster nodes
```

### For Validating Deployment Success
```bash
# Compare actual node state to platonic ideal
for node in crtr prtr drtr; do
    echo "=== Comparing $node to platonic ideal ==="

    # Compare shell configs
    diff /cluster-nas/configs/platonic-node/.zshrc <(ssh $node "cat ~/.zshrc")

    # Check tool availability
    ssh $node "command -v eza && command -v bat && command -v fd" || echo "Tools missing on $node"
done
```

### For Development Workflow
```bash
# 1. Update platonic-node when omni-config changes
# 2. Test changes in platonic-node environment
# 3. Validate against omni-config scope boundaries
# 4. Deploy tested changes via chezmoi
# 5. Compare deployment results to platonic ideal
```

## 📋 Content Guidelines

### File Organization
```
platonic-node/
├── .profile              # From omni-config/dot_profile
├── .zshrc                # From omni-config/dot_zshrc
├── .bashrc               # Generated bash equivalent
├── .gitconfig            # Universal git configuration
├── .tmux.conf            # Universal tmux configuration
├── .config/              # Tool-specific configurations
│   ├── starship.toml     # From omni-config/dot_config/
│   └── fastfetch/        # From infrastructure/ (user-facing)
├── .local/               # Tool installation targets
│   └── bin/              # Expected tool locations
├── .cargo/               # Alternative tool locations
│   └── bin/              # Rust tool installation targets
└── README.md             # This guide
```

### Quality Assurance
- **Scope Check**: Every file must be omni-config domain only
- **Cross-Node Validation**: Every config must be appropriate for all 3 nodes
- **Tool Completeness**: All modern CLI tools from the unified list must be represented
- **No Secrets**: No SSH keys, tokens, or sensitive data
- **No System Configs**: No /etc/, systemd, or root-level configurations

## 🔄 Integration with Omni-Config Workflow

### Development Cycle
1. **Plan changes** in omni-config/
2. **Test in platonic-node** first
3. **Validate scope compliance** (omni-config only)
4. **Update omni-config/** with tested changes
5. **Deploy via chezmoi** to cluster nodes
6. **Compare results** to platonic ideal

### Validation Cycle
1. **After omni-config updates**: Sync platonic-node
2. **After cluster deployment**: Compare nodes to platonic ideal
3. **Before major changes**: Use platonic-node as baseline

The platonic-node serves as the **authoritative reference** for what the omni-config deployment should achieve in each cluster node's user environment - nothing more, nothing less.