---
title: "ADR-002: Chezmoi Adoption for User Configuration Management"
description: "Architectural Decision Record for adopting Chezmoi as user configuration tool"
version: "1.0"
date: "2025-09-27"
category: "decision"
tags: ["adr", "chezmoi", "dotfiles", "templates", "user-config"]
status: "accepted"
related:
  - "001-hybrid-approach.md"
  - "../../architecture/HYBRID-STRATEGY.md"
  - "../../reference/TEMPLATES.md"
---

# ADR-002: Chezmoi Adoption for User Configuration Management

## Status
**Accepted** - September 2025

## Context

Following the decision to adopt a hybrid configuration management approach (ADR-001), the cluster needed a robust solution for user-level configuration management. The specific requirements were:

### User Configuration Challenges
1. **Node Heterogeneity**: ARM64 gateway + x86_64 compute nodes with different capabilities
2. **Role-Based Configuration**: Gateway, compute, and ML platform roles need different configurations
3. **Cross-Shell Support**: Both bash and zsh environments needed
4. **Tool Detection**: Dynamic adaptation to available tools
5. **Template Complexity**: Need for sophisticated conditional logic and shared includes
6. **Git Integration**: Version control and remote deployment required

### Evaluation Criteria
- **Template sophistication**: Support for complex conditional logic
- **Cross-platform support**: ARM64 and x86_64 compatibility
- **Git integration**: Native support for remote repositories
- **Node-specific adaptation**: Ability to render different configs per node
- **Shared templates**: Support for template includes and modularity
- **Tool ecosystem**: Active development and community support

## Decision

**Adopt Chezmoi as the user configuration management tool** with the following implementation strategy:

### Core Implementation
- **Source repository**: GitHub remote (https://github.com/IMUR/colab-config.git)
- **Source directory**: `omni-config/` with `.chezmoiroot` configuration
- **Template system**: Go templates with node-specific data variables
- **Deployment method**: `chezmoi init --apply` with GitHub remote

### Template Architecture
- **Node detection**: `.chezmoi.toml.tmpl` with hostname-based role assignment
- **Shared includes**: `.chezmoitemplate.*` files for common functionality
- **Cross-shell support**: Unified bash and zsh template management
- **Tool detection**: Runtime detection with graceful fallbacks

## Rationale

### Technical Superiority

**Template Engine:**
- Go's `text/template` provides sophisticated conditional logic
- Support for functions, pipes, and complex data structures
- Built-in template validation and error reporting
- Extensible with custom functions

**Node-Specific Rendering:**
```toml
# .chezmoi.toml.tmpl enables sophisticated node detection
{{ if eq .chezmoi.hostname "cooperator" -}}
node_role = "gateway"
has_gpu = false
has_nfs_server = true
{{- else if eq .chezmoi.hostname "projector" -}}
node_role = "compute"
has_gpu = true
gpu_count = 4
{{- end }}
```

**Shared Template System:**
```bash
# .chezmoitemplate.nvm-loader.sh - shared across shells
{{/* Common NVM loading logic */}}
if [ -d "$NVM_DIR" ]; then
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi
```

### Operational Excellence

**Git-Native Workflow:**
- Native GitHub remote support
- Atomic updates via `chezmoi update`
- Version control for all configuration changes
- Branch support for testing changes

**Safety and Rollback:**
- User-level only (preserves SSH access)
- Easy rollback: `chezmoi forget --force`
- No system-level changes required
- Isolated failures (per-user impact only)

**Performance:**
- Fast template rendering
- Efficient differential updates
- No network dependencies after initial setup
- Caching of rendered templates

### Ecosystem Benefits

**Active Development:**
- Regular releases and feature additions
- Strong community support
- Comprehensive documentation
- Cross-platform compatibility

**Tool Integration:**
- Editor plugins for template editing
- CI/CD integration capabilities
- Validation tools and linting
- Backup and migration utilities

## Implementation Details

### Phase 1: Foundation Setup

**Repository Structure:**
```
colab-config/
├── .chezmoiroot                    # Points to "omni-config"
├── omni-config/                    # Chezmoi source directory
│   ├── .chezmoi.toml.tmpl         # Node detection and variables
│   ├── .chezmoitemplate.nvm-loader.sh  # Shared NVM loading
│   ├── dot_bashrc.tmpl            # Bash configuration
│   ├── dot_zshrc.tmpl             # Zsh configuration
│   ├── dot_profile.tmpl           # Universal environment
│   └── dot_config/
│       └── starship.toml.tmpl     # Prompt configuration
```

**Node Detection Logic:**
```toml
[data]
    {{ if eq .chezmoi.hostname "cooperator" -}}
    # Gateway node configuration
    {{- else if eq .chezmoi.hostname "projector" -}}
    # Compute node configuration
    {{- else if eq .chezmoi.hostname "director" -}}
    # ML platform configuration
    {{- end }}
```

### Phase 2: Cross-Shell Unification

**Template Sharing:**
```bash
# In both dot_bashrc.tmpl and dot_zshrc.tmpl
{{- template ".chezmoitemplate.nvm-loader.sh" . }}
{{- template ".chezmoitemplate.common-aliases.sh" . }}
```

**Tool Detection:**
```bash
# Runtime tool detection in templates
{{- if (lookPath "eza") }}
alias ls='eza'
{{- else }}
alias ls='ls --color=auto'
{{- end }}
```

### Phase 3: Advanced Features

**GPU Configuration:**
```bash
{{- if .has_gpu }}
# GPU-specific environment
export CUDA_HOME="{{ .cuda_home }}"
alias gpus='nvidia-smi'
{{- if eq .gpu_count 4 }}
alias gpu-topology='nvidia-smi topo -m'
{{- end }}
{{- end }}
```

**Service Management:**
```bash
{{- if .has_archon_service }}
alias archon-status='systemctl status archon.service'
alias archon-logs='sudo journalctl -u archon.service -f'
{{- end }}
```

## Comparison with Alternatives

### vs. GNU Stow
**Chezmoi Advantages:**
- ✅ Sophisticated templating vs static symlinks
- ✅ Node-specific adaptation vs one-size-fits-all
- ✅ Git remote support vs local-only
- ✅ Cross-platform compatibility vs Unix-only

**Stow Advantages:**
- ✅ Simpler mental model
- ✅ No template learning curve
- ✅ Faster for static configurations

**Decision Rationale:** Template sophistication outweighs simplicity for cluster use case

### vs. Ansible (User Configs)
**Chezmoi Advantages:**
- ✅ Purpose-built for dotfiles vs general automation
- ✅ Template-first design vs task-based
- ✅ Git-native workflow vs playbook execution
- ✅ User-level safety vs system-level risk

**Ansible Advantages:**
- ✅ Team familiarity
- ✅ Same tool for system configs
- ✅ Established playbooks

**Decision Rationale:** Right tool for right job - Ansible for systems, Chezmoi for users

### vs. Nix/Home Manager
**Chezmoi Advantages:**
- ✅ Lower learning curve vs functional programming
- ✅ Works with existing package managers
- ✅ Doesn't require Nix ecosystem adoption
- ✅ Template system more accessible

**Nix Advantages:**
- ✅ Reproducible environments
- ✅ Declarative package management
- ✅ Rollback to any previous state

**Decision Rationale:** Pragmatic approach vs revolutionary change

### vs. Dotbot
**Chezmoi Advantages:**
- ✅ Sophisticated templating vs basic substitution
- ✅ Built-in Git support vs external integration
- ✅ Cross-platform vs primarily Unix
- ✅ Active development vs minimal maintenance

**Dotbot Advantages:**
- ✅ YAML configuration vs templates
- ✅ Plugin architecture
- ✅ Simpler for basic use cases

**Decision Rationale:** Template sophistication required for node heterogeneity

## Implementation Evidence

### Successful Deployment Metrics
```bash
✅ Template rendering: 100% success rate across all nodes
✅ Deployment time: 15 minutes (down from 20+ with Ansible)
✅ Error rate: 0% SSH lockouts since implementation
✅ Coverage: 100% of user environment configurations
✅ Cross-shell support: Unified bash and zsh environments
```

### Template Sophistication Examples

**Node-Specific GPU Configuration:**
```bash
# Multi-GPU optimization (projector only)
{{- if eq .gpu_architecture "multi_gpu" }}
export CUDA_DEVICE_ORDER="PCI_BUS_ID"
export NCCL_DEBUG=INFO
alias gpu-topology='nvidia-smi topo -m'
{{- end }}
```

**Conditional Tool Integration:**
```bash
# Starship prompt with fallback
{{- if (lookPath "starship") }}
eval "$(starship init bash)"
{{- else }}
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
{{- end }}
```

**Shared Template Includes:**
```bash
# .chezmoitemplate.nvm-loader.sh - eliminates duplication
# Used in both bash and zsh configurations
if [ -d "$NVM_DIR" ]; then
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi
```

## Consequences

### Positive Consequences

**Operational Benefits:**
- **Fast iterations**: Configuration changes deploy in 15 minutes
- **Zero system risk**: User-level changes preserve cluster access
- **Cross-node consistency**: Templates ensure identical user experience
- **Node adaptation**: Configs automatically adapt to node capabilities
- **Git workflow**: Standard development practices apply

**Technical Benefits:**
- **Template sophistication**: Complex logic for heterogeneous cluster
- **Shared code**: Template includes eliminate duplication
- **Tool detection**: Graceful degradation for missing tools
- **Cross-shell support**: Unified bash and zsh environments
- **Performance**: Fast shell startup with optimizations

**Maintenance Benefits:**
- **Version control**: All changes tracked in Git
- **Documentation**: Templates are self-documenting
- **Rollback**: Easy reversion with `chezmoi forget`
- **Testing**: Template validation before deployment
- **Collaboration**: Git-based workflow enables team collaboration

### Negative Consequences

**Learning Curve:**
- **Template syntax**: Go templates require initial learning
- **Debugging**: Template errors can be complex to diagnose
- **Chezmoi concepts**: Understanding source vs target files
- **Git workflow**: Command-line Git knowledge required

**Complexity:**
- **Template logic**: Complex conditionals in templates
- **Data management**: Variables and template data structure
- **Cross-file dependencies**: Shared includes create interdependencies
- **Tool-specific knowledge**: Chezmoi-specific commands and concepts

### Mitigation Strategies

**Training and Documentation:**
- Comprehensive template reference documentation created
- Examples and patterns for common configuration tasks
- Troubleshooting guide for template debugging
- Clear guidelines for when to modify templates vs variables

**Process Improvements:**
- Template validation before deployment
- Staged rollout of template changes
- Backup procedures for configuration changes
- Clear rollback procedures documented and tested

## Monitoring and Success Criteria

### Quantitative Metrics
- ✅ **Template rendering success**: 100% across all nodes
- ✅ **Deployment time**: 15 minutes (25% improvement)
- ✅ **Error rate**: 0% SSH lockouts (100% improvement)
- ✅ **Coverage**: 100% user environment configurations managed
- ✅ **Consistency**: Identical environments across nodes

### Qualitative Metrics
- ✅ **User experience**: Modern shell with consistent tooling
- ✅ **Maintainer experience**: Simple Git workflow
- ✅ **Reliability**: No configuration drift between nodes
- ✅ **Flexibility**: Easy addition of new tools and configurations
- ✅ **Safety**: Preserved emergency access methods

### Future Enhancements

**Template System Evolution:**
- Enhanced GPU configuration templates
- Service-specific template modules
- Monitoring and alerting template integration
- Backup and recovery template automation

**Tooling Integration:**
- CI/CD pipeline for template validation
- Automated testing of template rendering
- Template linting and best practices enforcement
- Integration with infrastructure-as-code tools

## Related Decisions
- [ADR-001: Hybrid Approach](001-hybrid-approach.md) - Strategic context for Chezmoi adoption
- [ADR-003: Configuration Constraints](003-configuration-constraints.md) - Design constraints affecting Chezmoi implementation

## References
- [Chezmoi Official Documentation](https://www.chezmoi.io/)
- [Go Template Documentation](https://pkg.go.dev/text/template)
- [Template Reference Documentation](../../reference/TEMPLATES.md)
- [Variables Reference Documentation](../../reference/VARIABLES.md)
- [Hybrid Strategy Documentation](../../architecture/HYBRID-STRATEGY.md)

---

**Decision Date**: September 2025
**Status**: Accepted and Implemented
**Last Review**: September 2025
**Next Review**: December 2025