# Co-lab Omni Config

**THE** single source of truth for all cluster configurations. Uses chezmoi for templating and deployment.

## 🎯 Purpose

This is the **single source of truth** for configurations that:
- Are installed on ALL 3 cluster nodes (crtr, prtr, drtr)
- Should be **identical** across all cluster nodes
- Form the **foundational layer** of the cluster environment

**Note**: Snitcher has moved to independent mobile access configuration

## 📁 Directory Structure

```
unified-foundation/
├── shell/                  # Shell environment configurations
│   ├── dotfiles/          # .profile, .zshrc, .bashrc templates
│   ├── env/               # Environment variable definitions
│   └── scripts/           # Shell utility scripts
├── tools/                 # Tool configurations
│   ├── modern-cli/        # eza, bat, fd, rg, zoxide, fzf, etc.
│   ├── development/       # git, cargo, npm, ansible configs
│   └── system/            # tmux, vim, ssh client configs
├── system/                # System-level configurations
│   ├── paths/             # PATH and binary management
│   ├── permissions/       # File ownership and permissions
│   └── services/          # Systemd and service configs
└── documentation/         # Deployment and architecture docs
    ├── deployment/        # How to deploy these configs
    └── architecture/      # Design decisions and principles
```

## 🚀 Deployment Strategy

1. **Git Version Control**: All configs are tracked in git
2. **Ansible Deployment**: Automated rollout to all nodes
3. **Idempotent Operations**: Safe to run multiple times
4. **Backup & Rollback**: Automatic backup before changes

## 🎯 Target State

Based on MODERN_SHELL_ROLLOUT.md analysis:

### ✅ Currently Unified
- Shell environment (zsh, .profile, .zshrc)
- Modern CLI tools (eza, batcat, fdfind, rg, fzf, nnn, delta)
- Basic system configurations

### 🔧 Needs Unification
- Tool detection (bat vs batcat, fd vs fdfind)
- Missing tools on some nodes (zoxide, dust, starship, atuin)
- NVM integration
- Development tool configurations

### 📦 Tool Installation Status
```
Tool         crtr  prtr  drtr
──────────────────────────
eza          ✅    ✅    ✅
batcat       ✅    ✅    ✅
fdfind       ✅    ✅    ✅
rg           ✅    ✅    ✅
fzf          ✅    ✅    ✅
nnn          ✅    ✅    ✅
delta        ✅    ✅    ✅
zoxide       ✅    ❌    ❌
dust         ✅    ❌    ❌
starship     ✅    ❌    ❌
atuin        ✅    ❌    ❌
```

## 🎯 Goals

1. **100% Tool Consistency** across all nodes
2. **Unified Configuration Management** via git + ansible
3. **Bulletproof Deployment** with rollback capability
4. **Documentation** of all decisions and procedures
5. **Future-Proof Architecture** for easy additions

This foundation ensures every node in the cluster has an identical, modern, productive environment.