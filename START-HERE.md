# 🚀 Colab-Config Quick Start Guide

## What is This?

Configuration management for a 3-node Co-lab cluster using:
- **Chezmoi** for user dotfiles
- **Ansible** for minimal system config
- **Docker** for services

## Where to Go?

### By Role

#### 👤 New User
1. Read this file
2. Check [docs/SETUP.md](docs/SETUP.md)
3. Run `scripts/setup/new-user-setup.sh`

#### 🤖 AI Agent
1. Read [AGENTS.md](AGENTS.md) for boundaries
2. Check `.agent-context.json` files
3. Use `structure.yaml` for navigation

#### 🔧 Developer
1. [README.md](README.md) for full docs
2. [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines
3. Examples in [docs/examples/](docs/examples/)

### By Task

#### Configure User Environment
```bash
cd dotfiles/
chezmoi diff
chezmoi apply
```

#### Modify System Settings
```bash
cd ansible/
# ALWAYS check first!
ansible-playbook playbooks/NAME.yml --check
```

#### Deploy Services
```bash
cd services/
docker compose up -d SERVICE_NAME
```

## Quick Commands

```bash
# Validate everything
scripts/validation/full-validation.sh

# Check specific component
scripts/validation/check-dotfiles.sh
scripts/validation/check-ansible.sh

# Get help
scripts/help.sh
```

## Safety Rules

1. ⚠️  NEVER delete files - archive instead
2. ⚠️  ALWAYS validate before applying
3. ⚠️  ALWAYS use --check with ansible
4. ⚠️  ALWAYS diff before chezmoi apply

## Need Help?

- 📚 [docs/FAQ.md](docs/FAQ.md)
- 🐛 [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- 💬 [GitHub Issues](https://github.com/IMUR/colab-config/issues)