---
meta:
  directory_type: "system_automation"
  management_tool: "ansible"
  automation_safe: false
  approval_required: true
agent_context:
  purpose: "Minimal system configuration"
  scope: "essential_system_tasks_only"
  safety_level: "critical"
---

# Ansible - System Automation

⚠️ **HIGH RISK AREA** - All operations require approval

## Purpose
Minimal Ansible automation for essential system configurations only.

## Allowed Scope
- SSH key distribution
- Basic package installation
- Essential system configuration
- User/group management (with approval)

## Directory Structure
```
ansible/
├── .safety-rules.yml         # MANDATORY READING
├── ansible.cfg              # Ansible configuration
├── inventory/
│   └── hosts.yml           # Cluster inventory
├── playbooks/
│   ├── ssh-keys.yml        # SSH key distribution
│   └── packages.yml        # Package management
├── group_vars/
│   └── all.yml             # Global variables
└── host_vars/
    ├── crtr.yml            # Gateway-specific
    ├── prtr.yml            # Compute-specific
    └── drtr.yml            # ML platform-specific
```

## ⚠️ MANDATORY WORKFLOW

### 1. ALWAYS Check Syntax First
```bash
ansible-playbook --syntax-check playbooks/example.yml
```

### 2. ALWAYS Dry Run
```bash
ansible-playbook --check --diff playbooks/example.yml
```

### 3. Get Approval
Document change request with:
- Impact analysis
- Rollback plan
- Testing results

### 4. Execute (With Monitoring)
```bash
ansible-playbook playbooks/example.yml
```

### 5. Verify
```bash
ansible all -m ping
scripts/validation/verify-services.sh
```

## Inventory Groups
- `colab`: All cluster nodes
- `gateway`: Gateway node (crtr)
- `compute`: Compute nodes (prtr)
- `ml_platform`: ML nodes (drtr)

## Safety Features
- Syntax checking enforced
- Dry-run mandatory
- Approval gates for system changes
- Automatic rollback on failure
- Health checks post-execution

## Example Playbooks

### Safe Pattern
```yaml
---
- name: Safe Package Installation
  hosts: colab
  become: yes
  any_errors_fatal: yes  # Safety first
  
  tasks:
    - name: Update package cache
      apt:
        update_cache: yes
      when: ansible_os_family == "Debian"
      
    - name: Install essential packages
      apt:
        name: "{{ item }}"
        state: present
      loop:
        - git
        - vim
        - tmux
      when: ansible_os_family == "Debian"
```

## Validation Commands
```bash
# Check inventory
ansible-inventory --graph

# Test connectivity
ansible all -m ping

# Validate playbook
ansible-playbook --syntax-check playbooks/NAME.yml

# Dry run
ansible-playbook --check --diff playbooks/NAME.yml
```

## ❌ NEVER DO
- Direct system file modification without backup
- Service restart without maintenance window
- Network reconfiguration without approval
- User permission changes without documentation
- Execute without --check first