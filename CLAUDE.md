# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the colab-config repository: a hybrid infrastructure configuration management system for a 3-node Co-lab cluster. The repository implements a safety-first approach using the right tool for each job:

- **Chezmoi** for user environment configuration (dotfiles/)
- **Ansible** for minimal system-level automation (ansible/)
- **Docker Compose** for service management (services/)

### Cluster Architecture
- **cooperator (crtr)** - 192.168.254.10: Gateway, NFS, DNS (Raspberry Pi 5, ARM64)
- **projector (prtr)** - 192.168.254.20: Primary compute, Multi-GPU (x86_64, 4x GPU)
- **director (drtr)** - 192.168.254.30: ML platform, Single GPU (x86_64, 1x GPU)

## Essential Commands

### User Configuration (Chezmoi)
```bash
# ALWAYS preview changes first
chezmoi diff

# Apply user configuration changes
chezmoi apply

# Test template rendering
chezmoi execute-template < dotfiles/dot_bashrc.tmpl

# Validate Chezmoi configuration
chezmoi doctor
```

### System Automation (Ansible) - REQUIRES APPROVAL
```bash
# MANDATORY: Check syntax first
ansible-playbook --syntax-check ansible/playbooks/playbook.yml

# MANDATORY: Dry run before execution
ansible-playbook --check ansible/playbooks/playbook.yml

# Only after approval: Execute playbook
ansible-playbook ansible/playbooks/playbook.yml

# Validate inventory
ansible-inventory --list
```

### Service Management (Docker)
```bash
# Validate service configuration
docker compose config

# Deploy services
docker compose up -d SERVICE_NAME

# View service logs
docker compose logs SERVICE_NAME
```

### Validation Commands
```bash
# Complete validation suite
scripts/validation/full-validation.sh

# Shell script validation
shellcheck scripts/**/*.sh

# YAML validation
yamllint ansible/**/*.yml
```

## Architecture & Safety Framework

### Safety-First Design
The repository implements multiple safety layers:
1. **Syntax Validation**: All configurations validated before execution
2. **Dry Run Testing**: Preview changes with `--check` and `diff` commands
3. **Approval Gates**: System-level changes require human approval
4. **Rollback Plans**: All tools support safe reversion

### Directory-Specific Rules

**dotfiles/**: User configuration via Chezmoi
- Templates use `.tmpl` extension and `dot_` prefix
- Node-specific rendering via `{{ .chezmoi.hostname }}`
- Always run `chezmoi diff` before `chezmoi apply`
- Check `.agent-context.json` for specific guidance

**ansible/**: System automation - HIGH RISK
- Read `.safety-rules.yml` before any operations
- MANDATORY workflow: syntax-check → --check → get approval → execute
- System changes require human approval
- All playbooks must be idempotent

**services/**: Docker Compose service management
- Use `docker compose config` to validate before deployment
- Environment variables via `.env.template` examples only
- Never commit production secrets

**scripts/**: Automation and validation tooling
- All scripts must pass `shellcheck`
- Use `set -euo pipefail` for error handling
- Include help text and usage examples

### Context Files
Each directory contains `.agent-context.json` with AI-specific operational boundaries. Always read these files first when working in that directory.

## Key Workflows

### Template Modification (Safe)
1. Edit template in `dotfiles/`
2. Run `chezmoi diff` to preview changes
3. Test with `chezmoi execute-template`
4. Apply with `chezmoi apply`

### System Configuration (Requires Approval)
1. Read `ansible/.safety-rules.yml`
2. Check syntax: `ansible-playbook --syntax-check`
3. Dry run: `ansible-playbook --check`
4. Get human approval for system changes
5. Execute with monitoring

### Service Deployment
1. Validate: `docker compose config`
2. Deploy: `docker compose up -d`
3. Monitor: `docker compose logs`

## Critical Safety Rules

- **NEVER** delete files - archive instead to preserve history
- **NEVER** modify system files directly - use appropriate tools
- **ALWAYS** validate syntax before execution
- **ALWAYS** run dry-run/diff commands first
- **NEVER** store secrets in the repository
- Use `git mv` for file movements to preserve history

## Navigation & Discovery

- **structure.yaml**: Machine-readable repository navigation
- **AGENTS.md**: Concise operational boundaries for AI agents
- **START-HERE.md**: Quick navigation guide by role and task
- **.agent-context.json**: Directory-specific AI operational guidance

## Validation & Testing

The repository includes comprehensive validation:
- Syntax checking for all configuration formats
- Template rendering validation
- Ansible playbook dry-run testing
- Shell script validation with shellcheck
- Cross-reference consistency checking

All changes should pass validation before commit. Use `scripts/validation/full-validation.sh` for complete testing.

## Common Patterns

### Node-Specific Configuration
Templates automatically adapt based on hostname detection:
```bash
{{- if eq .chezmoi.hostname "cooperator" }}
# Gateway-specific configuration
{{- else if eq .chezmoi.hostname "projector" }}
# Multi-GPU compute configuration
{{- else if eq .chezmoi.hostname "director" }}
# ML platform configuration
{{- end }}
```

### Error Handling in Scripts
```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Include help text
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [options]"
    exit 0
fi
```

This repository prioritizes operational safety and consistency across the 3-node cluster while maintaining flexibility for node-specific optimizations.