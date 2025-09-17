# Minimal Ansible Playbooks

**Approach**: System-level operations only - user configurations managed by chezmoi

## Directory Structure

- **health/**: Monitoring and validation playbooks
- **deployment/**: System preparation and deployment support
- **tools/**: Essential tool installation (1st draft approach)

## Principles

- Minimal system-level operations only
- No dangerous system modifications
- User configuration management excluded (handled by chezmoi)
- Idempotent and safe operations

## Usage Context

These playbooks support the hybrid approach by providing essential system-level infrastructure while leaving user experience management to omni-config/chezmoi deployment.
