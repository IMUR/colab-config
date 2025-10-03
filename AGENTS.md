# AI Agent Operational Guide

## Boundaries
✅ **Safe**: Template mods, documentation, validation, chezmoi diff
⚠️  **Approval**: System changes, service restarts, ansible playbooks
❌ **Forbidden**: File deletion, system files, network config

## Key Paths
- User configs: `dotfiles/`
- System: `ansible/` (requires --check first)
- Validation: `scripts/validation/`
- Context: `.agent-context.json` in each directory

## Workflows
1. **Config Update**: Read context → Validate → Test → Apply
2. **System Change**: Check syntax → Dry run → Get approval → Execute
3. **Documentation**: Update → Validate links → Commit

## Validation Commands
```bash
chezmoi diff                              # Preview dotfile changes
ansible-playbook --syntax-check           # Validate ansible
scripts/validation/full-validation.sh     # Complete check
```

## Tool Rules
- **Chezmoi**: Always diff before apply
- **Ansible**: Always --check before real run
- **Git**: Use git mv for file moves

Read `.agent-context.json` in each directory for specific guidance.