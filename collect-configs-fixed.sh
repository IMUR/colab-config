#!/bin/bash
# Fixed Configuration Discovery Script
echo "=== Colab-Config Discovery Audit (Fixed) ==="
echo "Date: $(date)"
echo ""

mkdir -p audit/{dotfiles,system,services}

# Current node (crtr) - direct access
echo "## Dotfiles Audit"
echo "### Node: crtr (local)"
ls -la ~ | grep "^\." > audit/dotfiles/crtr-dotfiles.txt
echo "  Dotfiles: $(ls -la ~ | grep "^\." | wc -l) files"
[ -d ~/.config ] && find ~/.config -type f | head -20 > audit/dotfiles/crtr-config-files.txt
echo "  .config files: $([ -d ~/.config ] && find ~/.config -type f | wc -l || echo 0) files"

# Remote nodes
for node in prtr drtr; do
    echo "### Node: $node"
    ssh $node 'ls -la ~ | grep "^\."' > audit/dotfiles/$node-dotfiles.txt
    echo "  Dotfiles: $(ssh $node 'ls -la ~ | grep "^\." | wc -l') files"
    
    ssh $node '[ -d ~/.config ] && find ~/.config -type f | head -20' > audit/dotfiles/$node-config-files.txt
    echo "  .config files: $(ssh $node '[ -d ~/.config ] && find ~/.config -type f | wc -l || echo 0') files"
done

echo ""
echo "## System Modifications"
echo "### Node: crtr (local)"
find /etc -type f -newer /etc/hostname 2>/dev/null | head -10 > audit/system/crtr-etc-modified.txt
echo "  Modified /etc files: $(find /etc -type f -newer /etc/hostname 2>/dev/null | wc -l) files"

for node in prtr drtr; do
    echo "### Node: $node"
    ssh $node 'find /etc -type f -newer /etc/hostname 2>/dev/null | head -10' > audit/system/$node-etc-modified.txt
    echo "  Modified /etc files: $(ssh $node 'find /etc -type f -newer /etc/hostname 2>/dev/null | wc -l') files"
done

echo ""
echo "## Services"
echo "### Node: crtr (local)"
systemctl list-units --type=service --state=running | grep -v "@" > audit/services/crtr-services.txt
echo "  Running services: $(systemctl list-units --type=service --state=running | grep -v "@" | wc -l) services"

for node in prtr drtr; do
    echo "### Node: $node"
    ssh $node 'systemctl list-units --type=service --state=running | grep -v "@"' > audit/services/$node-services.txt
    echo "  Running services: $(ssh $node 'systemctl list-units --type=service --state=running | grep -v "@" | wc -l') services"
done

echo ""
echo "=== Audit Complete ==="
echo "Results in: audit/"
