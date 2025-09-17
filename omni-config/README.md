# Omni-Config: Universal User Environment

**Purpose**: User-level configurations deployed identically across all cluster nodes (crtr, prtr, drtr)

**Role in Hybrid Strategy**: Pure chezmoi deployment domain - rich user experience with cross-node consistency

## 🏗️ What Omni-Config Provides

This directory contains the **user environment foundation** for the co-lab cluster:

### **Core Shell Environment**
- **`dot_profile`**: Universal profile with intelligent tool detection system
- **`dot_zshrc`**: Modern ZSH configuration with performance optimization
- **`dot_config/starship.toml`**: Professional shell prompt configuration

### **Tool Integration System**
- **Smart Detection**: Handles cross-architecture differences (ARM64 vs x86_64)
- **Graceful Degradation**: Works with or without modern tools installed
- **Package Compatibility**: Handles Debian naming (bat/batcat, fd/fdfind)
- **Performance Focus**: Optimized shell startup with timing feedback

## 📁 Actual Directory Contents

```
omni-config/
├── dot_profile              # Universal profile + HAS_* tool detection
├── dot_zshrc               # Modern ZSH with tool integrations
├── dot_config/             # Tool-specific configurations
│   └── starship.toml       # Professional prompt setup
├── tools/                  # Tool management
│   └── modern-cli/         # Modern CLI tool configurations
│       ├── starship.toml   # Alternative starship config
│       └── tool-install.yml # Ansible tool installation
├── documentation/          # Design documentation
│   └── architecture/
│       └── DESIGN_PRINCIPLES.md
├── INSTALL.md             # Deployment instructions
└── README.md              # This file
```

## 🔧 Configuration Capabilities

### **Tool Detection Engine** (dot_profile)
```bash
# Intelligent cross-platform detection with fallbacks
export HAS_EZA=$(_has eza && echo 1 || echo 0)
export HAS_BAT=$(_has bat || _has batcat && echo 1 || echo 0)  # Debian compatibility
export HAS_FD=$(_has fd || _has fdfind && echo 1 || echo 0)   # Package name handling

# Architecture awareness, development tools, performance optimization
```

### **Modern Shell Features** (dot_zshrc)
```bash
# Performance-optimized ZSH with startup timing
# Modern aliases with intelligent fallbacks
# Cross-architecture compatibility (ARM64/x86_64)
# Tool integrations: starship, fzf, zoxide, atuin
# Node-specific customization support (.zshrc.local, .zshrc.$NODE_ROLE)
```

### **Professional Prompt** (starship.toml)
```toml
# Cluster-aware prompt with /cluster-nas shortcuts
# Git integration, development environment indicators
# Performance-focused configuration
```

## 🎯 Chezmoi Integration Context

**Current State**: Ready for chezmoi deployment with templating completion needed

**Missing for Full Functionality**:
- `.chezmoi.toml.tmpl` - Node templating configuration
- Template variables in configuration files for node-specific adaptation

**Deployment Ready**: Core configurations work without templating, templating adds node-specific enhancements

## 🧭 Agent Integration Notes

**Context**: omni-config represents the user experience foundation within the hybrid strategy

**Capabilities Available to Agents**:
- **Cross-architecture shell environment** with intelligent tool detection
- **Performance-optimized configuration** with graceful degradation
- **Professional development environment** with modern tool integrations
- **Cluster-specific enhancements** (aliases, paths, shortcuts)

**Constraints for Agent Consideration**:
- Requires chezmoi for deployment (agents may need to install/configure)
- Designed for cluster nodes only (excludes snitcher mobile access)
- Depends on shared storage for template source distribution

**Integration with Cluster Strategy**:
- Complements minimal ansible system preparation
- Provides rich user experience layer
- Supports node-specific customization via templating (when completed)

## 🔗 Related Documentation

**Design Philosophy**: See `documentation/architecture/DESIGN_PRINCIPLES.md` for configuration hierarchy and tool integration strategy

**Deployment Context**: See main repository documentation for hybrid strategy and cluster-wide implementation approach

**Installation**: See `INSTALL.md` for chezmoi deployment procedures (requires templating completion)