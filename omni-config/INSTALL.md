# Installing Co-lab Omni Config

## Quick Deploy (All Nodes)

```bash
# From cooperator (has ansible):
for node in crtr prtr drtr snitcher; do
  ssh $node "chezmoi init --apply --source /cluster-nas/configs/colab-omni-config"
done
```

## Individual Node

```bash
# Install chezmoi if needed
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- -b $HOME/.local/bin

# Initialize from omni-config
chezmoi init --apply --source /cluster-nas/configs/colab-omni-config

# Future updates
chezmoi update
```

## What It Does

1. Templates configurations based on node hostname/architecture
2. Installs: `.profile`, `.zshrc`, `.config/starship.toml`
3. Detects tools and configures appropriately
4. Sets up cluster-specific paths and aliases

## Management

```bash
chezmoi diff      # See pending changes
chezmoi apply     # Apply changes
chezmoi update    # Pull latest from source
```