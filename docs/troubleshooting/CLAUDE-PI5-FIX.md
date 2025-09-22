# Claude Code on Raspberry Pi 5 - Troubleshooting Guide

**Date**: 2025-09-21  
**Node**: crtr (cooperator)  
**Issue**: Agent discovery and search functionality on ARM64

## Problem Summary

Claude Code v1.0.120 on Raspberry Pi 5 (ARM64) has issues with:

- Agent discovery mechanisms
- Search functionality ("vendor" disabled)
- Terminal interaction in SSH contexts

## Current State

- **Architecture**: `arm64` (correctly detected)
- **Node.js**: System installation (v20.19.2)
- **Claude**: Local installation at `~/.claude/local/`
- **Version**: 1.0.120

## Solutions

### 1. Fix Agent Discovery

```bash
# Copy project agents to user directory
cp .claude/agents/*.md ~/.claude/agents/

# Ensure correct permissions
chmod 600 ~/.claude/agents/*.md

# Test agent discovery
claude agent list
```

### 2. Fix Search Functionality

The "vendor" search issue on ARM64 requires using alternative search:

```bash
# Use ripgrep for code search
rg "search_term" .

# Use fzf for fuzzy finding
find . -type f | fzf

# Use grep as fallback
grep -r "search_term" .
```

### 3. Terminal Workarounds

For commands that need TTY:

```bash
# Use script command to create pseudo-TTY
script -q -c "claude doctor" /dev/null

# Or use SSH with TTY allocation
ssh -t localhost "claude doctor"
```

### 4. Alternative: Downgrade to Compatible Version

If issues persist, consider v0.2.114 which had better ARM64 support:

```bash
# Backup current installation
mv ~/.claude/local ~/.claude/local.backup

# Install older version
npm install -g @anthropic-ai/claude-code@0.2.114

# Run migrate-installer again
claude migrate-installer
```

## Configuration Optimization

### Remove NFS Conflicts

```bash
# Use local config only
export CLAUDE_CONFIG_DIR="$HOME/.claude"

# Add to ~/.profile
echo 'export CLAUDE_CONFIG_DIR="$HOME/.claude"' >> ~/.profile
```

### Agent Directory Setup

```bash
# Create proper structure
mkdir -p ~/.claude/agents
mkdir -p ~/.claude/projects

# Set permissions
chmod 700 ~/.claude
chmod 700 ~/.claude/agents
```

## Verification

```bash
# Check installation
which claude
claude --version

# List agents (may need workaround)
ls -la ~/.claude/agents/

# Test basic functionality
claude help
```

## Known Limitations on ARM64

1. **Search**: Vendor search disabled, use external tools
2. **Doctor**: Requires TTY workarounds
3. **Agents**: May need manual placement in `~/.claude/agents/`
4. **Performance**: Slower than x86_64 for some operations

## Alternative Workflow

Since search is limited, leverage the cluster's tools:

```bash
# Use these instead of Claude's search
alias search='rg'
alias fuzzy='fzf'
alias explore='nnn'
```

## References

- [ARM64 Architecture Issue](https://github.com/anthropics/claude-code/issues/3569)
- [Agent Discovery Problem](https://github.com/anthropics/claude-code/issues/4773)
- [Vendor Search Disabled](https://github.com/anthropics/claude-code/issues/3980)
