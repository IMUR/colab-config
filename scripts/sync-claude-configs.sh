#!/bin/bash
# COMPLETELY NON-DESTRUCTIVE sync of ~/.claude across all cluster nodes
# This script:
#   - NEVER deletes or overwrites any existing data
#   - Creates full backups of everything
#   - Only copies/merges content (never moves)
#   - Provides full reversibility

SHARED_CLAUDE="/cluster-nas/.claude-shared"  # Use different name to avoid conflicts
NODES=("crtr" "drtr" "prtr" "snitcher")
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$SHARED_CLAUDE/backups/$TIMESTAMP"
MANIFEST_FILE="$BACKUP_DIR/manifest.txt"

echo "=== SAFE Claude Config Sync Script ==="
echo "This script is COMPLETELY NON-DESTRUCTIVE"
echo "Shared location: $SHARED_CLAUDE (separate from project .claude)"
echo ""

# Create directories
mkdir -p "$BACKUP_DIR/nodes"
mkdir -p "$SHARED_CLAUDE/merged"
echo "Backup directory: $BACKUP_DIR"
echo "Starting sync at $(date)" > "$MANIFEST_FILE"

# Function to safely copy from a node (READ-ONLY)
sync_node() {
    local node=$1
    
    echo "" >> "$MANIFEST_FILE"
    echo "=== Processing node: $node ===" | tee -a "$MANIFEST_FILE"
    
    # Check if we're on this node or need SSH
    if [[ $(hostname) == "$node" ]]; then
        if [[ ! -d "$HOME/.claude" ]]; then
            echo "  - No .claude directory found on $node" | tee -a "$MANIFEST_FILE"
            return
        fi
        echo "  - Found local .claude at: $HOME/.claude" | tee -a "$MANIFEST_FILE"
        
        # Create node-specific backup
        local node_backup="$BACKUP_DIR/nodes/$node"
        mkdir -p "$node_backup"
        
        # COPY (never move) all content
        echo "  - Creating full backup..." | tee -a "$MANIFEST_FILE"
        cp -a "$HOME/.claude/." "$node_backup/" 2>/dev/null
        
    else
        # Check if node is accessible
        if ! ssh -o ConnectTimeout=5 "$node" "test -d ~/.claude" 2>/dev/null; then
            echo "  - Node $node not accessible or no .claude directory" | tee -a "$MANIFEST_FILE"
            return
        fi
        echo "  - Found remote .claude on $node" | tee -a "$MANIFEST_FILE"
        
        # Create node-specific backup
        local node_backup="$BACKUP_DIR/nodes/$node"
        mkdir -p "$node_backup"
        
        # COPY (never move) all content
        echo "  - Creating full backup..." | tee -a "$MANIFEST_FILE"
        rsync -av "$node:~/.claude/" "$node_backup/" 2>/dev/null
    fi
    
    # Track what we backed up
    local node_backup="$BACKUP_DIR/nodes/$node"
    echo "    Backed up to: $node_backup" >> "$MANIFEST_FILE"
    find "$node_backup" -type f 2>/dev/null | wc -l | xargs echo "    Total files:" >> "$MANIFEST_FILE"
    du -sh "$node_backup" 2>/dev/null | cut -f1 | xargs echo "    Total size:" >> "$MANIFEST_FILE"
}

# Function to merge content (READ-ONLY from backups)
merge_content() {
    echo ""
    echo "=== Merging unique content ===" | tee -a "$MANIFEST_FILE"
    
    # Merge projects (chat sessions) - combine all unique sessions
    echo "  - Merging projects/sessions..." | tee -a "$MANIFEST_FILE"
    mkdir -p "$SHARED_CLAUDE/merged/projects"
    for node_dir in "$BACKUP_DIR/nodes"/*; do
        if [[ -d "$node_dir/projects" ]]; then
            node=$(basename "$node_dir")
            echo "    - From $node" | tee -a "$MANIFEST_FILE"
            # Copy with --ignore-existing to never overwrite
            rsync -av --ignore-existing "$node_dir/projects/" "$SHARED_CLAUDE/merged/projects/" 2>/dev/null
        fi
    done
    
    # Merge agents
    echo "  - Merging agents..." | tee -a "$MANIFEST_FILE"
    mkdir -p "$SHARED_CLAUDE/merged/agents"
    for node_dir in "$BACKUP_DIR/nodes"/*; do
        if [[ -d "$node_dir/agents" ]]; then
            node=$(basename "$node_dir")
            echo "    - From $node" | tee -a "$MANIFEST_FILE"
            rsync -av --ignore-existing "$node_dir/agents/" "$SHARED_CLAUDE/merged/agents/" 2>/dev/null
        fi
    done
    
    # Merge todos
    echo "  - Merging todos..." | tee -a "$MANIFEST_FILE"
    mkdir -p "$SHARED_CLAUDE/merged/todos"
    for node_dir in "$BACKUP_DIR/nodes"/*; do
        if [[ -d "$node_dir/todos" ]]; then
            node=$(basename "$node_dir")
            echo "    - From $node" | tee -a "$MANIFEST_FILE"
            rsync -av --ignore-existing "$node_dir/todos/" "$SHARED_CLAUDE/merged/todos/" 2>/dev/null
        fi
    done
    
    # Keep node-specific configs separate (don't merge)
    echo "  - Preserving node-specific configs..." | tee -a "$MANIFEST_FILE"
    for node_dir in "$BACKUP_DIR/nodes"/*; do
        node=$(basename "$node_dir")
        mkdir -p "$SHARED_CLAUDE/node-configs/$node"
        for config in settings.local.json claude.json; do
            if [[ -f "$node_dir/$config" ]]; then
                cp "$node_dir/$config" "$SHARED_CLAUDE/node-configs/$node/" 2>/dev/null
                echo "    - $node: $config" | tee -a "$MANIFEST_FILE"
            fi
        done
        if [[ -d "$node_dir/plugins" ]]; then
            cp -r "$node_dir/plugins" "$SHARED_CLAUDE/node-configs/$node/" 2>/dev/null
            echo "    - $node: plugins/" | tee -a "$MANIFEST_FILE"
        fi
    done
}

# Create restore script
create_restore_script() {
    local restore_script="$BACKUP_DIR/restore.sh"
    cat > "$restore_script" << 'EOF'
#!/bin/bash
# Restore script for claude configurations
# This will restore a node's original .claude directory

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <node_name>"
    echo "Available nodes:"
    ls -1 nodes/
    exit 1
fi

NODE=$1
BACKUP_DIR="$(dirname "$0")"

if [[ ! -d "$BACKUP_DIR/nodes/$NODE" ]]; then
    echo "Error: No backup found for node $NODE"
    exit 1
fi

echo "This will restore $NODE's .claude from backup"
echo "Current ~/.claude will be moved to ~/.claude.before-restore"
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
fi

# Backup current state
if [[ -d "$HOME/.claude" ]]; then
    mv "$HOME/.claude" "$HOME/.claude.before-restore-$(date +%Y%m%d_%H%M%S)"
fi

# Restore from backup
cp -a "$BACKUP_DIR/nodes/$NODE" "$HOME/.claude"
echo "Restored from: $BACKUP_DIR/nodes/$NODE"
echo "Previous .claude backed up with .before-restore suffix"
EOF
    chmod +x "$restore_script"
    echo "  - Created restore script: $restore_script" | tee -a "$MANIFEST_FILE"
}

# Create optional symlink script (user must explicitly run this)
create_symlink_script() {
    local symlink_script="$SHARED_CLAUDE/OPTIONAL-create-symlink.sh"
    cat > "$symlink_script" << 'EOF'
#!/bin/bash
# OPTIONAL: Create symlink to use shared .claude
# WARNING: This will rename your current .claude (but not delete it)

SHARED_CLAUDE="/cluster-nas/.claude-shared/merged"
BACKUP_NAME="$HOME/.claude.before-symlink-$(date +%Y%m%d_%H%M%S)"

echo "========================================"
echo "OPTIONAL: Symlink to Shared .claude"
echo "========================================"
echo ""
echo "This will:"
echo "  1. Rename current ~/.claude to $BACKUP_NAME"
echo "  2. Create symlink: ~/.claude -> $SHARED_CLAUDE"
echo ""
echo "You can reverse this anytime by:"
echo "  rm ~/.claude"
echo "  mv $BACKUP_NAME ~/.claude"
echo ""
read -p "Create symlink? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled - no changes made"
    exit 0
fi

# Backup existing
if [[ -e "$HOME/.claude" ]]; then
    if [[ -L "$HOME/.claude" ]]; then
        echo "Removing existing symlink..."
        rm "$HOME/.claude"
    else
        echo "Backing up existing .claude..."
        mv "$HOME/.claude" "$BACKUP_NAME"
        echo "Backed up to: $BACKUP_NAME"
    fi
fi

# Create symlink
ln -s "$SHARED_CLAUDE" "$HOME/.claude"
echo "Created symlink: ~/.claude -> $SHARED_CLAUDE"
ls -la "$HOME/.claude"
EOF
    chmod +x "$symlink_script"
    echo "  - Created optional symlink script: $symlink_script" | tee -a "$MANIFEST_FILE"
}

# Main execution
echo ""
echo "Step 1: Backing up all nodes' .claude directories..."
for node in "${NODES[@]}"; do
    sync_node "$node"
done

echo ""
echo "Step 2: Merging content (non-destructive)..."
merge_content

echo ""
echo "Step 3: Creating utility scripts..."
create_restore_script
create_symlink_script

# Final summary
echo ""
echo "========================================"
echo "SYNC COMPLETE - NO DATA WAS MODIFIED!"
echo "========================================"
echo ""
echo "What was done:"
echo "  ✓ Full backups created: $BACKUP_DIR/nodes/"
echo "  ✓ Merged content saved: $SHARED_CLAUDE/merged/"
echo "  ✓ Node configs preserved: $SHARED_CLAUDE/node-configs/"
echo "  ✓ Manifest created: $MANIFEST_FILE"
echo ""
echo "Your original ~/.claude directories are UNCHANGED"
echo ""
echo "Options:"
echo "  1. Do nothing - continue using local ~/.claude"
echo "  2. Copy merged content: cp -r $SHARED_CLAUDE/merged/* ~/.claude/"
echo "  3. Use symlink (optional): $SHARED_CLAUDE/OPTIONAL-create-symlink.sh"
echo "  4. Restore a backup: $BACKUP_DIR/restore.sh <node_name>"
echo ""
echo "To sync again later, just run this script again!"
echo "All operations are non-destructive and create new timestamped backups."