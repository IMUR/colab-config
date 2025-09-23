#!/bin/bash
# Real Configuration Discovery (excluding cache)
echo "=== Real Configuration Audit (Cache Filtered) ==="
echo "Date: $(date)"
echo ""

mkdir -p audit/real-configs

# Directories to EXCLUDE (cache/runtime data)
EXCLUDE_PATTERNS=(
    "*/BraveSoftware/*"
    "*/Cursor/User/workspaceStorage/*"
    "*/Cursor/CachedExtensions/*" 
    "*/Cursor/logs/*"
    "*/google-chrome/*"
    "*/firefox/*"
    "*/.cache/*"
    "*/Cache/*"
    "*/CachedData/*"
    "*/logs/*"
)

echo "## Real Config Files (excluding cache/runtime):"

# Current node (crtr)
echo "### Node: crtr (local)"
find ~/.config -type f 2>/dev/null | \
    grep -v -E "(BraveSoftware|Cursor/User/workspaceStorage|Cursor/CachedExtensions|Cursor/logs|google-chrome|firefox|\.cache|Cache|CachedData|logs)" \
    > audit/real-configs/crtr-real-configs.txt
echo "  Real configs: $(cat audit/real-configs/crtr-real-configs.txt | wc -l) files"

# Remote nodes  
for node in prtr drtr; do
    echo "### Node: $node"
    ssh $node 'find ~/.config -type f 2>/dev/null' | \
        grep -v -E "(BraveSoftware|Cursor/User/workspaceStorage|Cursor/CachedExtensions|Cursor/logs|google-chrome|firefox|\.cache|Cache|CachedData|logs)" \
        > audit/real-configs/$node-real-configs.txt
    echo "  Real configs: $(cat audit/real-configs/$node-real-configs.txt | wc -l) files"
done

echo ""
echo "## Sample real configs on prtr:"
head -10 audit/real-configs/prtr-real-configs.txt

echo ""
echo "=== Real Config Audit Complete ==="
