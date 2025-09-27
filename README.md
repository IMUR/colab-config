---
meta:
  repository_type: "infrastructure_configuration"
  management_approach: "hybrid_tooling"
  primary_tools: ["chezmoi", "ansible"]
  automation_safe: true
  last_updated: "2025-01-27"
agent_context:
  purpose: "Co-lab cluster configuration management"
  scope: "user_environment_and_minimal_system"
  safe_operations: ["template", "validate", "document"]
  restricted_operations: ["system_modify", "service_restart"]
---

# Colab-Config: Infrastructure Configuration Management

## Quick Start

- **New Users**: Start with [START-HERE.md](START-HERE.md)
- **AI Agents**: Read [AGENTS.md](AGENTS.md) + [structure.yaml](structure.yaml)
- **Developers**: Continue below for complete documentation

## Repository Purpose

This repository manages configuration for the Co-lab cluster, a three-node infrastructure:

| Node | Hostname | Alias | Role | IP |
|------|----------|-------|------|-----|
| cooperator | cooperator.local | crtr | Gateway/Services | 192.168.254.10 |
| projector | projector.local | prtr | Compute (Multi-GPU) | 192.168.254.20 |
| director | director.local | drtr | ML Platform | 192.168.254.30 |

## Architecture

### Hybrid Management Approach

- **User Environment**: Chezmoi for dotfiles and user configurations
- **System Infrastructure**: Minimal Ansible for essential system configs
- **Service Management**: Docker Compose for containerized services
- **Safety First**: Multiple validation layers and approval gates

## Directory Structure

```
colab-config/
├── .chezmoiroot           # Points to "dotfiles" for repository flexibility
├── dotfiles/              # Chezmoi-managed user configurations
├── ansible/               # Minimal system-level automation
├── services/              # Service configurations and compose files
├── scripts/               # Automation and validation scripts
├── docs/                  # Comprehensive documentation
└── .meta/                 # Repository meta-management files
```

## Core Components

### User Configuration (dotfiles/)
Managed by Chezmoi for consistent user environments across nodes:
- Shell configurations (bash, zsh)
- Development tools (vim, tmux, git)
- Node-specific customizations via templates

### System Automation (ansible/)
Minimal Ansible playbooks for essential system tasks:
- SSH key distribution
- Basic system packages
- Network configuration (when necessary)

### Services (services/)
Docker-based service deployments:
- Semaphore (Ansible UI)
- Monitoring stack
- Development tools

## Common Operations

### Initial Setup
```bash
# Clone repository
git clone https://github.com/IMUR/colab-config.git
cd colab-config

# Initialize Chezmoi
chezmoi init --source=dotfiles

# Apply user configurations
chezmoi apply

# Validate system readiness
scripts/validation/full-validation.sh
```

### Configuration Updates
```bash
# Update templates
cd dotfiles
vim dot_bashrc.tmpl

# Preview changes
chezmoi diff

# Apply changes
chezmoi apply
```

### System Changes (Requires Approval)
```bash
# Check syntax first
ansible-playbook ansible/playbooks/system-packages.yml --syntax-check

# Dry run
ansible-playbook ansible/playbooks/system-packages.yml --check

# Apply with approval
ansible-playbook ansible/playbooks/system-packages.yml
```

## Validation & Safety

All changes pass through validation gates:
1. **Syntax Validation**: Automatic checks for all configuration formats
2. **Dry Run Testing**: Preview changes before application
3. **Approval Gates**: Human review for system-level changes
4. **Rollback Plans**: Always maintain ability to revert

## Documentation Structure

- **README.md**: Complete project documentation (this file)
- **AGENTS.md**: AI agent operational guidelines (concise)
- **START-HERE.md**: Quick navigation and orientation
- **structure.yaml**: Machine-readable repository organization
- **.agent-context.json**: Directory-specific AI guidance

## Contributing

1. Read [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)
2. Follow safety guidelines in [docs/SAFETY.md](docs/SAFETY.md)
3. Test changes locally first
4. Submit pull requests with validation results

## Support

- **Issues**: [GitHub Issues](https://github.com/IMUR/colab-config/issues)
- **Documentation**: [docs/](docs/)
- **Examples**: [docs/examples/](docs/examples/)

---

*Repository maintained by the Co-lab infrastructure team*