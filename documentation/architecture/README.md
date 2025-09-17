**📍 File Location**: `documentation/architecture/README.md`

---

# Architecture Documentation

This directory contains detailed architectural documentation for the Co-lab cluster.

## Documents

- **[COLAB-CLUSTER-ARCHITECTURE.md](COLAB-CLUSTER-ARCHITECTURE.md)** - Complete cluster architecture, node specifications, and hybrid configuration strategy
- **[Migration Strategy](COLAB-CLUSTER-ARCHITECTURE.md#modern-hybrid-configuration-strategy)** - Detailed implementation plan for hybrid approach

## Quick Reference

- **Nodes**: cooperator (crtr), projector (prtr), director (drtr)
- **Network**: 192.168.254.0/24 internal
- **Configuration**: Hybrid (Minimal Ansible + Pure Chezmoi)
- **Deployment Method**: GitHub remote (`chezmoi init --apply https://github.com/IMUR/colab-config.git`)
- **Template System**: .tmpl files with node-specific rendering (cooperator/projector/director)
- **Shell Management**: Unified bash and zsh with shared NVM loading
- **Deployment Time**: ~15 minutes
- **Risk Level**: Low (user-level changes only)

For implementation details, see the complete architecture document.
