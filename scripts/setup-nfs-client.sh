#!/bin/bash
# Setup NFS client mount for /cluster-nas
# Run this on projector, director, and snitcher nodes

set -e

NFS_SERVER="192.168.254.10"
NFS_PATH="/cluster-nas"
MOUNT_POINT="/cluster-nas"

echo "Setting up NFS mount for $MOUNT_POINT from $NFS_SERVER"

# Install NFS utilities if not present
if ! command -v mount.nfs &> /dev/null; then
    echo "Installing NFS client utilities..."
    sudo apt-get update
    sudo apt-get install -y nfs-common
fi

# Create mount point
echo "Creating mount point..."
sudo mkdir -p $MOUNT_POINT

# Test mount first
echo "Testing NFS mount..."
if sudo mount -t nfs $NFS_SERVER:$NFS_PATH $MOUNT_POINT; then
    echo "Mount successful!"
    
    # Add to fstab for persistence
    echo "Adding to /etc/fstab for persistence..."
    FSTAB_ENTRY="$NFS_SERVER:$NFS_PATH $MOUNT_POINT nfs rw,sync,hard,intr,_netdev 0 0"
    
    if ! grep -q "$NFS_SERVER:$NFS_PATH" /etc/fstab; then
        echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
        echo "Added to /etc/fstab"
    else
        echo "Entry already exists in /etc/fstab"
    fi
    
    # Verify mount
    df -h $MOUNT_POINT
    
    # Test write
    TEST_FILE="$MOUNT_POINT/.nfs_test_$(hostname)"
    if touch $TEST_FILE 2>/dev/null; then
        echo "Write test successful!"
        rm $TEST_FILE
    else
        echo "Warning: Cannot write to mount. Check permissions."
    fi
else
    echo "Mount failed! Please check:"
    echo "1. NFS server is running on $NFS_SERVER"
    echo "2. Firewall allows NFS traffic"
    echo "3. Export is configured correctly"
    exit 1
fi

echo "NFS setup complete!"