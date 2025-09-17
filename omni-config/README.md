**📍 File Location**: `omni-config/README.md`

---

# Omni-Config: Universal User Environment

**Purpose**: User-level configurations deployed identically across all cluster nodes (crtr, prtr, drtr)

**Role in Hybrid Strategy**: Pure chezmoi deployment domain - rich user experience with cross-node consistency

## 🏗️ What Omni-Config Provides

This directory contains the **user environment foundation** for the co-lab cluster:

### **Core Shell Environment**
- **`dot_profile`**: Universal profile with intelligent tool detection system
- **`dot_zshrc.tmpl`**: Modern ZSH configuration with performance optimization (template)
- **`dot_bashrc.tmpl`**: Modern Bash configuration with unified tool integration (template)
- **`dot_config/starship.toml`**: Professional shell prompt configuration
- **`.chezmoitemplate.nvm-loader.sh`**: Shared NVM loading template for consistent Node.js environment

### **Tool Integration System**
- **Smart Detection**: Handles cross-architecture differences (ARM64 vs x86_64)
- **Graceful Degradation**: Works with or without modern tools installed
- **Package Compatibility**: Handles Debian naming (bat/batcat, fd/fdfind)
- **Performance Focus**: Optimized shell startup with timing feedback

## 📁 Actual Directory Contents

```
omni-config/
├── .chezmoi.toml.tmpl              # Node-specific template configuration
├── dot_profile                     # Universal profile + HAS_* tool detection
├── dot_zshrc.tmpl                  # Modern ZSH with tool integrations (template)
├── dot_bashrc.tmpl                 # Modern Bash with tool integrations (template)
├── .chezmoitemplate.nvm-loader.sh  # Shared NVM loading template
├── dot_config/                     # Tool-specific configurations
│   └── starship.toml              # Professional prompt setup
├── tools/                          # Tool management (archived)
├── documentation/                  # Design documentation
│   └── architecture/
│       └── DESIGN_PRINCIPLES.md
├── PLATONIC-NODE-GUIDE.md         # Reference implementation guide
└── README.md                      # This file
```

## 🔧 Configuration Capabilities

### **Tool Detection Engine** (dot_profile)
```bash
# Intelligent cross-platform detection with fallbacks for complete tool suite:
export HAS_EZA=$(_has eza && echo 1 || echo 0)
export HAS_BAT=$(_has bat || _has batcat && echo 1 || echo 0)  # Debian compatibility
export HAS_FD=$(_has fd || _has fdfind && echo 1 || echo 0)   # Package name handling
export HAS_RG=$(_has rg && echo 1 || echo 0)
export HAS_FZF=$(_has fzf && echo 1 || echo 0)
export HAS_ZOXIDE=$(_has zoxide && echo 1 || echo 0)
export HAS_STARSHIP=$(_has starship && echo 1 || echo 0)
export HAS_ATUIN=$(_has atuin && echo 1 || echo 0)
export HAS_DUST=$(_has dust && echo 1 || echo 0)
export HAS_FASTFETCH=$(_has fastfetch && echo 1 || echo 0)

# Complete tool suite: eza, bat, fd-find, ripgrep, fzf, nnn, git-delta, zoxide, dust, starship, atuin, fastfetch
# Development tools: git, tmux, cargo, npm, python3, uv
# System tools: curl, wget, vim, htop, tree, openssh-client, rsync
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

## 🎯 Chezmoi Deployment Architecture

**Current State**: ✅ **Fully operational** with dual-source architecture

### **Deployment Method**: Hybrid Local Working + GitHub Remote
```bash
# Working Directory (Edit Here):
/cluster-nas/colab/colab-config/omni-config/  # Local NFS working directory

# Source of Truth (Deploy From):
https://github.com/IMUR/colab-config.git      # GitHub remote repository

# Node Deployment:
chezmoi init --apply https://github.com/IMUR/colab-config.git
```

### **Change Workflow**:
```bash
# 1. Edit configurations in local working directory
cd /cluster-nas/colab/colab-config/omni-config/
# (edit dot_profile, dot_zshrc.tmpl, etc.)

# 2. Commit and push to GitHub remote
git add omni-config/
git commit -m "Update configurations"
git push origin main

# 3. Update all nodes from GitHub remote
for node in crtr prtr drtr; do
    ssh "$node" "chezmoi update"  # Pull from GitHub, render templates, apply
done
```

**Implemented Features**:
- ✅ `.chezmoi.toml.tmpl` - Node templating data (cooperator/projector/director)
- ✅ Template system - .tmpl files with shared includes (.chezmoitemplate files)
- ✅ GitHub remote deployment - Decoupled from local NFS for operations
- ✅ Unified shell management - Both bash and zsh with consistent NVM loading
- ✅ Node-specific customization - Templates render different configs per node role
- ⚠️ **Template consistency needed** - dot_profile should be dot_profile.tmpl for node-specific elements

## 🧭 Agent Integration Notes

**Context**: omni-config represents the user experience foundation within the hybrid strategy

**Capabilities Available to Agents**:
- **Cross-architecture shell environment** with intelligent tool detection
- **Performance-optimized configuration** with graceful degradation
- **Professional development environment** with modern tool integrations
- **Cluster-specific enhancements** (aliases, paths, shortcuts)

**Deployment Architecture Clarification**:
- **Working Directory**: `/cluster-nas/colab/colab-config/omni-config/` (edit configurations here)
- **Source of Truth**: GitHub remote `https://github.com/IMUR/colab-config.git` (nodes deploy from here)
- **Template Processing**: Chezmoi renders .tmpl files with node-specific data during deployment
- **No NFS Dependency**: After initialization, nodes operate independently

**Current Template Inconsistency**:
- ⚠️ **dot_profile** should be **dot_profile.tmpl** for node-specific templating
- ⚠️ **Node-specific case statements** in profile would be cleaner as template conditionals
- ⚠️ **Template consistency** needed across all shell configuration files

**Integration with Cluster Strategy**:
- Complements minimal ansible system preparation
- Provides rich user experience layer
- ✅ **Node-specific customization fully implemented** via templating system

## 🛠️ Official Omni-Config Tool Suite

### **Modern CLI Tools (Core)**
```
eza           # Modern ls replacement with icons and git integration
bat           # cat with syntax highlighting and paging
fd-find       # Modern find replacement (fast and user-friendly)
ripgrep       # Extremely fast text search
fzf           # Fuzzy finder for everything
nnn           # Powerful terminal file manager
git-delta     # Beautiful git diffs with syntax highlighting
zoxide        # Smart cd replacement with frecency
dust          # Visual disk usage analyzer
starship      # Cross-shell prompt with rich customization
atuin         # Smart shell history with sync capabilities
fastfetch     # System information display tool
```

### **Development Environment**
```
zsh           # Modern shell with advanced features
tmux          # Terminal multiplexer for session management
git           # Version control system
ansible       # Configuration management and automation
cargo         # Rust package manager and build tool
npm           # Node.js package manager
python3       # Python programming language
uv            # Fast Python package installer and resolver
```

### **System Utilities**
```
curl          # Data transfer tool
wget          # Web file downloader
vim           # Text editor
htop          # Interactive process viewer
tree          # Directory structure display
openssh-client # SSH client for remote access
rsync         # File synchronization tool
```

### **AI/Development Tools**
```
claude-code   # Claude AI coding assistant CLI
gemini-cli    # Gemini AI command-line interface
```

### **Tool Detection Variables**
The omni-config uses intelligent detection for cross-platform compatibility:
```bash
HAS_EZA, HAS_BAT, HAS_FD, HAS_RG, HAS_FZF, HAS_NNN, HAS_DELTA,
HAS_ZOXIDE, HAS_DUST, HAS_STARSHIP, HAS_ATUIN, HAS_FASTFETCH
```

### **Package Compatibility**
Handles Debian/Ubuntu naming variations:
- `bat` vs `batcat`
- `fd` vs `fdfind`
- Architecture-specific binaries for `dust`, `starship`

## 🔗 Related Documentation

**Design Philosophy**: See `documentation/architecture/DESIGN_PRINCIPLES.md` for configuration hierarchy and tool integration strategy

**Deployment Context**: See main repository documentation for hybrid strategy and cluster-wide implementation approach

**Installation**: See `INSTALL.md` for chezmoi deployment procedures (requires templating completion)