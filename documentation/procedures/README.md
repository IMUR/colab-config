**📍 File Location**: `documentation/procedures/README.md`

---

# Deployment Procedures

This directory contains operational procedures for the Co-lab cluster.

## Available Procedures

- **[AI-AGENT-QUICKSTART.md](../../AI-AGENT-QUICKSTART.md)** - Complete assessment guide for AI agents operating from snitcher
  - Covers all configuration domains: user environments, system infrastructure, services
  - Principle-compliant: Context-driven, collaborative, flexible approach
  - Reference for comprehensive cluster configuration implementation

## Quick Reference

- **Assessment Focus**: Complete colab-config repository scope
- **Strategy**: Hybrid approach (minimal ansible + pure chezmoi with GitHub remote)
- **Deployment Method**: `chezmoi init --apply https://github.com/IMUR/colab-config.git`
- **Template System**: Node-specific rendering via .tmpl files and shared includes
- **Shell Management**: Unified bash and zsh environments with NVM integration
- **Risk Management**: User-level changes preserve SSH access
- **Recovery**: Multiple rollback options documented

For detailed architecture and strategy, see `documentation/architecture/COLAB-CLUSTER-ARCHITECTURE.md`.
