---
meta:
  directory_type: "user_configurations"
  management_tool: "chezmoi"
  automation_safe: true
agent_context:
  purpose: "Node-aware user environment management"
  scope: "home_directory_only"
  safe_operations: ["template", "diff", "verify"]
---

# Dotfiles - User Configuration Management

## Purpose
Chezmoi-managed user configurations with node-aware templating for the Co-lab cluster.

## Structure
```
dotfiles/
├── .chezmoi.toml.tmpl    # Node configuration detection
├── dot_bashrc.tmpl       # Bash configuration
├── dot_gitconfig.tmpl    # Git settings
├── dot_vimrc.tmpl        # Vim configuration
└── dot_tmux.conf.tmpl    # Tmux settings
```

## Node Detection
Configurations automatically adapt based on hostname:
- `crtr` (cooperator): Gateway-specific settings
- `prtr` (projector): GPU/compute optimizations  
- `drtr` (director): ML platform configurations

## Common Operations

### Preview Changes
```bash
chezmoi diff
```

### Apply Configuration
```bash
# Always diff first!
chezmoi diff
chezmoi apply
```

### Test Templates
```bash
chezmoi execute-template < dot_bashrc.tmpl
```

### Add New Dotfile
```bash
# Create template
vim dot_config_app.tmpl

# Add node-specific logic
{{ if eq .chezmoi.hostname "crtr" }}
# Gateway-specific config
{{ end }}
```

## Template Variables

Available in all templates via `.chezmoi.toml.tmpl`:
- `{{ .chezmoi.hostname }}` - Current node name
- `{{ .email }}` - User email
- `{{ .name }}` - User full name
- Custom node variables per host

## Safety Rules
- ✅ Safe to modify templates
- ✅ Safe to run chezmoi diff
- ⚠️  Review diff before apply
- ❌ Never store secrets in templates