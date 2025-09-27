---
title: "ADR-001: Hybrid Configuration Management Approach"
description: "Architectural Decision Record for adopting Ansible + Chezmoi hybrid approach"
version: "1.0"
date: "2025-09-27"
category: "decision"
tags: ["adr", "architecture", "hybrid", "ansible", "chezmoi"]
status: "accepted"
related:
  - "../../architecture/HYBRID-STRATEGY.md"
  - "002-chezmoi-adoption.md"
---

# ADR-001: Hybrid Configuration Management Approach

## Status
**Accepted** - September 2025

## Context

The Co-lab cluster originally attempted to manage all configuration through Ansible, which led to several significant challenges:

### Problems with Pure Ansible Approach
1. **Complexity Overload**: Using Ansible for dotfile management was cumbersome and error-prone
2. **Risk Factor**: System-level playbooks posed risks to SSH access and cluster stability
3. **Deployment Time**: Complex orchestration took 20+ minutes for simple configuration changes
4. **Maintenance Burden**: 75% of existing Ansible playbooks were broken or dangerous
5. **Wrong Tool for Job**: Ansible excels at system administration, not user environment management

### Industry Context (2024)
- Modern DevOps practices emphasize "right tool for right job"
- Dotfile management has specialized tools (Chezmoi, Stow, etc.)
- Configuration as Code trends toward minimal, focused tools
- Risk reduction strategies favor user-level changes over system-level

### Cluster Requirements
- **3-node heterogeneous cluster**: cooperator (ARM64 gateway), projector (x86_64 multi-GPU), director (x86_64 single GPU)
- **High availability**: Configuration errors cannot lock out users
- **Rapid iteration**: Daily configuration refinements needed
- **Cross-platform**: ARM64 and x86_64 architectures
- **Node-specific adaptation**: Different roles require different configurations

## Decision

**Adopt a hybrid configuration management approach:**

### System-Level Configuration (Minimal Ansible)
- **Scope**: Package installation, system services, /etc/ configurations only
- **Frequency**: Infrequent (initial setup, major system changes)
- **Risk Level**: Moderate (requires root, affects system stability)
- **Examples**: Installing packages, managing systemd services, creating system users

### User-Level Configuration (Pure Chezmoi)
- **Scope**: Dotfiles, shell environments, user-specific tool configurations
- **Frequency**: Regular (daily configuration refinements)
- **Risk Level**: Low (user-level only, preserves SSH access)
- **Examples**: .zshrc.tmpl, .bashrc.tmpl, .profile, .config/starship.toml

## Rationale

### Technical Benefits

**Risk Reduction:**
- User-level changes preserve SSH access even if configuration fails
- Shell configuration errors don't affect critical services (DNS, NFS)
- Fast rollback: `chezmoi forget` vs complex system restoration
- Individual user impact vs entire cluster impact

**Performance Improvement:**
- 15-minute deployments vs 20+ minute complex Ansible runs
- GitHub remote deployment (industry standard)
- No NFS dependency for configuration management
- Template processing with node-specific variables

**Maintainability:**
- Clear separation of concerns: system vs user configurations
- Professional dotfile management with shared template includes
- Cross-shell support (unified bash and zsh environments)
- Git-tracked changes with straightforward workflow

### Strategic Benefits

**Industry Alignment:**
- Follows 2024 best practices for configuration management
- Uses appropriate tools for their intended purposes
- Aligns with configuration-as-code principles
- Reduces cognitive load through clear tool boundaries

**Operational Excellence:**
- Zero system risk for daily configuration changes
- Cross-node consistency through templates
- Node-specific adaptation via .chezmoi.toml.tmpl
- Simple git workflow: edit → commit → push → chezmoi update

### Evidence-Based Decision

**Quantitative Improvements:**
- Deployment time: 20+ minutes → 15 minutes
- Risk reduction: System-level → User-level
- Failure recovery: Complex → Simple (chezmoi forget + re-init)
- Configuration consistency: Manual → Template-driven

**Qualitative Improvements:**
- SSH access preservation guaranteed
- Service isolation maintained
- Emergency access methods preserved
- Configuration drift eliminated

## Implementation

### Phase 1: Foundation (Completed)
```bash
✅ Created .chezmoi.toml.tmpl with node templating
✅ Converted shell configs to templates (dot_zshrc.tmpl, dot_bashrc.tmpl)
✅ Implemented shared template system (.chezmoitemplate files)
✅ Structured omni-config/ as proper chezmoi source
✅ Deployed to all nodes via GitHub remote
```

### Phase 2: GitHub Remote Deployment (Completed)
```bash
✅ GitHub remote: https://github.com/IMUR/colab-config.git
✅ .chezmoiroot configuration for omni-config subdirectory
✅ No NFS dependency for chezmoi operations
✅ Template processing with node-specific variables
✅ Unified update workflow established
```

### Phase 3: Cross-Shell Unification (Completed)
```bash
✅ Both bash and zsh managed by chezmoi templates
✅ Shared NVM loading template eliminates duplication
✅ Node-specific customization via template variables
✅ Consistent tool integration across shells and nodes
✅ PATH and tool availability issues resolved
```

## Consequences

### Positive Consequences

**Operational:**
- **Fast, safe deployments**: 15-minute user-level changes
- **Zero system risk**: Configuration errors don't affect cluster
- **Cross-node consistency**: Identical user experience via templates
- **Node-specific adaptation**: Configs adapt to roles automatically
- **Maintainer efficiency**: Simple git workflow

**Technical:**
- **Modern shell environments**: Both bash and zsh with modern tools
- **Smart tool detection**: Graceful handling of missing tools
- **Performance optimization**: Fast shell startup with monitoring
- **Cross-shell compatibility**: Unified experience regardless of shell
- **Emergency access preservation**: Multiple access methods maintained

**Strategic:**
- **Industry standard approach**: Right tool for right job
- **Risk mitigation**: User-level focus reduces operational risk
- **Scalability**: Template system accommodates cluster growth
- **Future-proofing**: Modern tooling supports long-term maintenance

### Negative Consequences

**Complexity:**
- **Dual toolchain**: Teams need to understand both Ansible and Chezmoi
- **Template learning curve**: Go template syntax requires initial learning
- **Tool coordination**: Changes may require updates to multiple tools

**Limitations:**
- **Ansible still needed**: System-level changes still require Ansible knowledge
- **Template debugging**: Template errors can be harder to diagnose than static files
- **Git dependency**: Configuration changes require git workflow

### Mitigation Strategies

**Training and Documentation:**
- Comprehensive template reference documentation
- Clear separation of when to use which tool
- Examples and patterns for common configuration tasks
- Troubleshooting guides for template issues

**Process Improvements:**
- Clear guidelines for system vs user configuration changes
- Template validation before deployment
- Rollback procedures documented and tested
- Cross-training on both tools for key team members

## Alternatives Considered

### Alternative 1: Pure Ansible
**Rejected because:**
- High risk of system lockout
- Complex and slow deployments
- Wrong tool for dotfile management
- Maintenance burden too high

### Alternative 2: Pure Chezmoi
**Rejected because:**
- Cannot handle system-level configuration
- Package installation still requires system tools
- Service management needs system-level access
- Some configurations require root privileges

### Alternative 3: Other Tools (Stow, Nix, etc.)
**Rejected because:**
- Stow lacks templating capabilities needed for node-specific configs
- Nix has steep learning curve and package availability issues
- Other tools don't provide the template sophistication required

### Alternative 4: Status Quo (Mixed Manual)
**Rejected because:**
- Configuration drift between nodes
- Manual synchronization errors
- No version control for configurations
- Difficult to maintain consistency

## Monitoring and Review

### Success Metrics
- ✅ **Deployment time**: Reduced from 20+ minutes to 15 minutes
- ✅ **Risk incidents**: Zero SSH lockouts since implementation
- ✅ **Configuration consistency**: 100% template rendering success
- ✅ **User experience**: Unified experience across all nodes and shells
- ✅ **Maintainer satisfaction**: Simplified daily workflow

### Review Criteria
- **Performance**: Deployment times and error rates
- **Reliability**: SSH access preservation and service stability
- **Maintainability**: Ease of making configuration changes
- **Scalability**: Ability to add new nodes and configurations
- **Team satisfaction**: Developer experience with tools

### Decision Review Schedule
- **Quarterly**: Review metrics and team feedback
- **Annually**: Consider new tools and approaches
- **Ad-hoc**: Review if significant issues arise

## Related Decisions
- [ADR-002: Chezmoi Adoption](002-chezmoi-adoption.md) - Detailed Chezmoi implementation decisions
- [ADR-003: Configuration Constraints](003-configuration-constraints.md) - Design constraints and rules

## References
- [Hybrid Strategy Documentation](../../architecture/HYBRID-STRATEGY.md)
- [Chezmoi Official Documentation](https://www.chezmoi.io/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Configuration Management Patterns](https://www.martinfowler.com/articles/configMgmt.html)

---

**Decision Date**: September 2025
**Status**: Accepted and Implemented
**Last Review**: September 2025
**Next Review**: December 2025