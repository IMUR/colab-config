#!/bin/bash
# Configuration Discovery Script
# Based on colab-config-pragmatic-foundation.md Phase 1.1

echo "=== Colab-Config Discovery Audit ==="
echo "Date: $(date)"
echo ""

NODES="crtr prtr drtr"
mkdir -p audit/{dotfiles,system,services}

echo "## Dotfiles Audit"
for node in $NODES; do
    echo "### Node: $node"
    ssh $node 'ls -la ~ | grep "^\."' > audit/dotfiles/$node-dotfiles.txt
    echo "  Dotfiles: $(ssh $node 'ls -la ~ | grep "^\." | wc -l') files"
    
    # Check for .config directory
    ssh $node '[ -d ~/.config ] && find ~/.config -type f | head -20' > audit/dotfiles/$node-config-files.txt
    echo "  .config files: $(ssh $node '[ -d ~/.config ] && find ~/.config -type f | wc -l || echo 0') files"
done

echo ""
echo "## System Modifications"
for node in $NODES; do
    echo "### Node: $node"
    # Find recently modified files in /etc (rough indicator of customization)
    ssh $node 'find /etc -type f -newer /etc/hostname 2>/dev/null | head -10' > audit/system/$node-etc-modified.txt
    echo "  Modified /etc files: $(ssh $node 'find /etc -type f -newer /etc/hostname 2>/dev/null | wc -l') files"
done

echo ""
echo "## Services"
for node in $NODES; do
    echo "### Node: $node"
    ssh $node 'systemctl list-units --type=service --state=running | grep -v "@"' > audit/services/$node-services.txt
    echo "  Running services: $(ssh $node 'systemctl list-units --type=service --state=running | grep -v "@" | wc -l') services"
done

echo ""
echo "=== Audit Complete ==="
echo "Results in: audit/"
echo "Next: Review files and categorize universal vs node-specific"
