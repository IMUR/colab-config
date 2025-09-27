---
title: "Infrastructure Reset Guide"
description: "Complete end-to-end cluster infrastructure reset with application preservation"
version: "1.0"
date: "2025-09-27"
category: "guide"
tags: ["infrastructure", "reset", "nvidia", "docker", "archon", "deployment"]
applies_to: ["all_nodes"]
related:
  - "../architecture/GPU-COMPUTE-STRATEGY.md"
  - "../architecture/CONTAINER-PLATFORM-STRATEGY.md"
  - "SERVICE-MANAGEMENT.md"
---

# Infrastructure Reset Guide

## Executive Summary

This guide provides the **complete sequence** for resetting the Co-lab cluster infrastructure while preserving critical applications. The strategy follows a clean slate approach: **total removal → unified configuration deployment → optimal reinstallation**.

### Strategic Approach

**Philosophy**: Clean foundation enables optimal configuration
1. **Complete Removal**: NVIDIA + Docker total cleanup
2. **Configuration Unification**: Deploy omni-config across cluster
3. **Optimal Reinstallation**: Modern stack with unified templates

### Timeline and Risk

- **Total Downtime**: ~2-3 hours (Archon preserved, other services minimal impact)
- **Risk Level**: Low (comprehensive backup and rollback procedures)
- **Critical Applications**: 100% preservation of Archon container stack
- **Configuration**: Unified, template-driven management post-reset

## Sequence Overview

### Phase 1: Preparation and Preservation (30 minutes)
- Document current state
- Preserve Archon container stack completely
- Create rollback points
- Validate backup integrity

### Phase 2: Complete Removal (45 minutes)
- Total NVIDIA/CUDA removal
- Complete Docker removal with container stop
- System cleanup and verification
- Reboot to clean state

### Phase 3: Omni-Config Deployment (30 minutes)
- Deploy chezmoi configuration across cluster
- Execute limited ansible for system-wide needs
- Validate template rendering and environment

### Phase 4: Optimal Reinstallation (60 minutes)
- Fresh NVIDIA drivers + CUDA toolkit installation
- Clean Docker installation with GPU integration
- Template-driven configuration application
- Performance optimization

### Phase 5: Application Restoration (15 minutes)
- Restore Archon with GPU acceleration
- Validate all services and functionality
- Enable monitoring and health checks

## Phase 1: Preparation and Preservation

### State Documentation and Validation

**Document Current State:**
```bash
# Create comprehensive state backup
mkdir -p /cluster-nas/backups/infrastructure-reset-$(date +%Y%m%d-%H%M%S)
cd /cluster-nas/backups/infrastructure-reset-$(date +%Y%m%d-%H%M%S)

# System state documentation
echo "=== System State Before Reset ===" > system-state-before.txt
ssh prtr "
    echo 'Node: projector' >> system-state-before.txt
    echo 'Date: $(date)' >> system-state-before.txt
    echo '' >> system-state-before.txt
    echo '=== NVIDIA State ===' >> system-state-before.txt
    nvidia-smi >> system-state-before.txt 2>&1
    echo '' >> system-state-before.txt
    echo '=== Docker State ===' >> system-state-before.txt
    docker --version >> system-state-before.txt
    docker ps >> system-state-before.txt
    echo '' >> system-state-before.txt
    echo '=== Package State ===' >> system-state-before.txt
    dpkg -l | grep -E 'nvidia|cuda|docker' >> system-state-before.txt
"

# Validate cluster connectivity
echo "=== Cluster Connectivity Check ===" > cluster-connectivity.txt
for node in crtr prtr drtr; do
    echo "Testing $node..." | tee -a cluster-connectivity.txt
    ssh "$node" "echo 'SSH connection successful'; uptime" >> cluster-connectivity.txt 2>&1
done
```

**Verify Backup Infrastructure:**
```bash
# Ensure NFS is accessible from all nodes
for node in crtr prtr drtr; do
    ssh "$node" "df -h /cluster-nas && echo '✅ $node NFS access OK'"
done

# Test git repository access
cd /cluster-nas/colab/colab-config
git status && git pull origin main
echo "✅ Git repository accessible"
```

### Execute Archon Preservation (Critical)

**Follow Archon Preservation Strategy:**
```bash
# Execute complete Archon preservation (see CONTAINER-PLATFORM-STRATEGY.md)
ssh prtr "
    mkdir -p /cluster-nas/backups/archon-preservation-$(date +%Y%m%d-%H%M%S)
    cd /cluster-nas/backups/archon-preservation-$(date +%Y%m%d-%H%M%S)

    # Document current container state
    docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' > archon-containers-state.txt

    # Save all Archon-related images
    docker images --format '{{.Repository}}:{{.Tag}}' | grep -E '(archon|postgrest|pgvector|adminer)' > archon-images-list.txt
    docker save \$(cat archon-images-list.txt) | gzip > archon-images-complete.tar.gz

    # Backup PostgreSQL data volume
    docker run --rm \
        -v archon-supabase_postgres_data:/source:ro \
        -v \$(pwd):/backup \
        alpine sh -c 'cd /source && tar czf /backup/archon-postgres-volume.tar.gz .'

    # Create restoration manifest
    cat > archon-restoration-manifest.txt <<EOF
Archon Preservation Manifest - \$(date)
=====================================

Backup Location: \$(pwd)
Node: \$(hostname)
Docker Version: \$(docker --version)

Files Created:
- archon-containers-state.txt (container status)
- archon-images-complete.tar.gz (all container images)
- archon-postgres-volume.tar.gz (critical database volume)

Image Count: \$(cat archon-images-list.txt | wc -l)
Total Backup Size: \$(du -sh . | cut -f1)
EOF

    echo '✅ Archon preservation completed successfully'
"

# Verify Archon backup completed successfully
echo "Verifying Archon preservation..."
ARCHON_BACKUP_DIR=$(ssh prtr "ls -d /cluster-nas/backups/archon-preservation-* | tail -1")
ssh prtr "cd '$ARCHON_BACKUP_DIR' && ls -la && cat archon-restoration-manifest.txt"
```

### Configuration Repository Preparation

**Prepare omni-config for deployment:**
```bash
cd /cluster-nas/colab/colab-config

# Ensure latest configuration changes are committed
git add -A
git status

# If there are uncommitted changes, commit them
if ! git diff-index --quiet HEAD --; then
    git commit -m "Pre-reset configuration snapshot"
    git push origin main
fi

# Verify chezmoi templates are ready
echo "=== Chezmoi Template Validation ==="
find omni-config -name "*.tmpl" -exec echo "Template: {}" \;
cat omni-config/.chezmoi.toml.tmpl | grep -A5 -B5 "has_gpu\|has_docker"
```

## Phase 2: Complete Removal

### Stop All GPU/Docker Workloads

**⚠️ Critical: Execute Systemd Service Management**
```bash
# Execute comprehensive service management (see SERVICE-MANAGEMENT.md)
ssh prtr "
    echo '=== Stopping Application Services ==='
    # Stop Archon and Ollama systemd services (discovered via systemctl analysis)
    sudo systemctl stop archon.service ollama.service
    sudo systemctl disable archon.service ollama.service

    echo '=== Stopping Archon Containers ==='
    # Archon containers are already preserved, now stop them
    docker stop \$(docker ps -q) 2>/dev/null || true

    echo '=== Stopping GPU Services ==='
    sudo systemctl stop nvidia-persistenced.service
    sudo systemctl stop nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
    sudo systemctl disable nvidia-persistenced.service

    echo '=== Stopping Docker Services ==='
    sudo systemctl stop docker.service docker.socket containerd.service
    sudo systemctl disable docker.service docker.socket containerd.service

    echo '=== All services stopped ==='
"
```

### Execute Complete NVIDIA Removal

**Follow NVIDIA Removal Strategy:**
```bash
# Execute complete NVIDIA removal on GPU nodes
for node in prtr drtr; do
    echo "=== Removing NVIDIA from $node ==="
    ssh "$node" "
        # Stop NVIDIA services
        sudo systemctl stop nvidia-persistenced 2>/dev/null || true
        sudo systemctl disable nvidia-persistenced 2>/dev/null || true

        # Remove all NVIDIA packages
        sudo apt purge -y \$(dpkg -l | grep -E 'nvidia|cuda' | awk '{print \$2}')
        sudo apt autoremove -y --purge

        # Clean NVIDIA configurations
        sudo rm -rf /usr/local/cuda*
        sudo rm -rf /etc/nvidia/
        sudo rm -rf /var/lib/dkms/nvidia*
        sudo rm -rf /usr/share/nvidia/
        sudo rm -f /etc/modprobe.d/nvidia*.conf

        # Clean user configurations
        rm -rf ~/.nv/ ~/.nvidia/ 2>/dev/null || true

        echo '✅ NVIDIA removal completed on $node'
    "
done
```

### Execute Complete Docker Removal

**Follow Docker Removal Strategy:**
```bash
# Execute complete Docker removal on all nodes
for node in crtr prtr drtr; do
    echo "=== Removing Docker from $node ==="
    ssh "$node" "
        # Remove all Docker packages
        sudo apt purge -y docker.io docker-cli docker-compose docker-buildx containerd runc
        sudo apt purge -y \$(dpkg -l | grep docker | awk '{print \$2}')
        sudo apt autoremove -y --purge

        # Remove configurations
        sudo rm -rf /etc/docker/
        sudo rm -rf /var/lib/docker/
        sudo rm -rf /var/lib/containerd/
        sudo rm -rf /run/docker/
        sudo rm -f /etc/apt/sources.list.d/docker.list

        # Clean user configurations
        rm -rf ~/.docker/ 2>/dev/null || true
        sudo deluser \$USER docker 2>/dev/null || true

        # Clean network interfaces
        sudo ip link delete docker0 2>/dev/null || true

        echo '✅ Docker removal completed on $node'
    "
done
```

### System Cleanup and Reboot

**Final Cleanup:**
```bash
# Clean package cache and update system
for node in crtr prtr drtr; do
    ssh "$node" "
        sudo apt update
        sudo apt upgrade -y
        sudo apt autoremove -y
        sudo apt autoclean

        # Clean kernel modules
        sudo modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia 2>/dev/null || true

        echo '✅ System cleanup completed on $node'
    "
done

# Reboot all nodes for clean state
echo "=== Rebooting all nodes for clean state ==="
for node in crtr prtr drtr; do
    echo "Rebooting $node..."
    ssh "$node" "sudo reboot" &
done

# Wait for reboot completion
echo "Waiting for nodes to come back online..."
sleep 120

# Verify nodes are back online
for node in crtr prtr drtr; do
    while ! ssh "$node" "echo '$node is back online'" 2>/dev/null; do
        echo "Waiting for $node..."
        sleep 30
    done
done

echo "✅ All nodes rebooted and online"
```

## Phase 3: Omni-Config Deployment

### Verify Clean State

**Validate Removal Success:**
```bash
# Verify clean state on all nodes
for node in crtr prtr drtr; do
    echo "=== Verifying clean state on $node ==="
    ssh "$node" "
        echo 'Checking NVIDIA removal:'
        command -v nvidia-smi && echo '❌ NVIDIA still present' || echo '✅ NVIDIA removed'

        echo 'Checking Docker removal:'
        command -v docker && echo '❌ Docker still present' || echo '✅ Docker removed'

        echo 'Checking processes:'
        ps aux | grep -E 'nvidia|docker' | grep -v grep || echo '✅ No GPU/Docker processes'

        echo 'System clean state verified on $node'
    "
done
```

### Deploy Chezmoi Configuration

**Initialize Chezmoi on All Nodes:**
```bash
# Ensure chezmoi is available on all nodes
for node in crtr prtr drtr; do
    echo "=== Setting up chezmoi on $node ==="
    ssh "$node" "
        # Install chezmoi if not present
        if ! command -v chezmoi >/dev/null; then
            curl -sfL https://get.chezmoi.io | sh -s -- -b ~/.local/bin
            export PATH=\$HOME/.local/bin:\$PATH
        fi

        # Initialize chezmoi with latest configuration
        chezmoi init --apply https://github.com/IMUR/colab-config.git

        echo '✅ Chezmoi initialized on $node'
    "
done
```

### Validate Template Rendering

**Verify Node-Specific Configuration:**
```bash
# Validate template rendering on each node
for node in crtr prtr drtr; do
    echo "=== Validating templates on $node ==="
    ssh "$node" "
        echo 'Node data:'
        chezmoi data | grep -E 'hostname|node_role|has_gpu|has_docker'

        echo 'Environment variables:'
        source ~/.profile
        echo \"NODE_ROLE: \$NODE_ROLE\"
        echo \"HAS_GPU: \$HAS_GPU\"

        echo 'Shell configuration:'
        source ~/.zshrc >/dev/null 2>&1 && echo '✅ ZSH config loaded'
        source ~/.bashrc >/dev/null 2>&1 && echo '✅ Bash config loaded'

        echo '✅ Template validation completed on $node'
    "
done
```

### Limited Ansible Deployment (If Needed)

**Execute Minimal System Configuration:**
```bash
cd /cluster-nas/colab/colab-config

# Execute minimal ansible for system-wide configuration if needed
if [ -f "ansible/playbooks/cluster-health.yml" ]; then
    echo "=== Executing minimal ansible configuration ==="
    ansible-playbook ansible/playbooks/cluster-health.yml
fi

# Verify system-wide configuration
echo "=== Validating system configuration ==="
ansible all -m ping
ansible all -m setup -a "filter=ansible_distribution*"
```

## Phase 4: Optimal Reinstallation

### Install Fresh NVIDIA Stack

**Execute NVIDIA Installation on GPU Nodes:**
```bash
# Install NVIDIA on GPU-enabled nodes
for node in prtr drtr; do
    echo "=== Installing NVIDIA on $node ==="
    ssh "$node" "
        # Add official NVIDIA repository
        wget -q https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb
        sudo dpkg -i cuda-keyring_1.1-1_all.deb
        sudo apt update

        # Install latest driver + CUDA toolkit
        sudo apt install -y nvidia-driver-560 cuda-toolkit-12-6 nvidia-container-toolkit

        # Configure NVIDIA persistence
        sudo systemctl enable nvidia-persistenced
        sudo systemctl start nvidia-persistenced

        echo '✅ NVIDIA installation completed on $node'
    "
done
```

### Install Fresh Docker Stack

**Execute Docker Installation on All Nodes:**
```bash
# Install Docker on all nodes
for node in crtr prtr drtr; do
    echo "=== Installing Docker on $node ==="
    ssh "$node" "
        # Add official Docker repository
        sudo apt update
        sudo apt install -y ca-certificates curl gnupg lsb-release
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \$(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # Configure Docker daemon
        sudo tee /etc/docker/daemon.json <<EOF
{
    \"log-driver\": \"json-file\",
    \"log-opts\": {
        \"max-size\": \"100m\",
        \"max-file\": \"3\"
    },
    \"storage-driver\": \"overlay2\",
    \"default-runtime\": \"runc\",
    \"runtimes\": {
        \"nvidia\": {
            \"path\": \"nvidia-container-runtime\",
            \"runtimeArgs\": []
        }
    }
}
EOF

        # Start Docker service
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo usermod -aG docker \$USER

        echo '✅ Docker installation completed on $node'
    "
done
```

### Configure GPU-Docker Integration

**Enable GPU Support in Docker:**
```bash
# Configure GPU support on GPU nodes
for node in prtr drtr; do
    echo "=== Configuring GPU support on $node ==="
    ssh "$node" "
        # Update Docker daemon for GPU support
        sudo jq '.\"default-runtime\" = \"nvidia\"' /etc/docker/daemon.json > /tmp/daemon.json
        sudo mv /tmp/daemon.json /etc/docker/daemon.json

        # Restart Docker to apply GPU configuration
        sudo systemctl restart docker

        # Test GPU access in Docker
        docker run --rm --gpus all nvidia/cuda:12.6-base-ubuntu20.04 nvidia-smi

        echo '✅ GPU-Docker integration completed on $node'
    "
done
```

### Apply Template-Driven Configuration

**Update Chezmoi with New Capabilities:**
```bash
# Update chezmoi configuration with newly installed capabilities
for node in crtr prtr drtr; do
    echo "=== Updating configuration on $node ==="
    ssh "$node" "
        # Pull latest configuration changes
        chezmoi update

        # Reload shell environment
        source ~/.profile
        source ~/.bashrc

        # Test new aliases and environment
        echo 'Testing GPU aliases:'
        type gpus 2>/dev/null && echo '✅ GPU aliases loaded' || echo '❌ GPU aliases missing'

        echo 'Testing Docker aliases:'
        type dps 2>/dev/null && echo '✅ Docker aliases loaded' || echo '❌ Docker aliases missing'

        echo 'Testing environment:'
        echo \"CUDA_HOME: \$CUDA_HOME\"
        echo \"HAS_GPU: \$HAS_GPU\"

        echo '✅ Configuration updated on $node'
    "
done
```

## Phase 5: Application Restoration

### Restore Archon Container Stack

**Execute Archon Restoration:**
```bash
# Restore Archon on prtr
echo "=== Restoring Archon container stack ==="
ARCHON_BACKUP_DIR=$(ssh prtr "ls -d /cluster-nas/backups/archon-preservation-* | tail -1")

ssh prtr "
    cd '$ARCHON_BACKUP_DIR'

    # Load preserved images
    docker load < archon-images-complete.tar.gz

    # Recreate networks
    docker network create archon_app-network 2>/dev/null || true
    docker network create archon_network 2>/dev/null || true

    # Restore volumes
    docker volume create archon-supabase_postgres_data
    docker run --rm -v archon-supabase_postgres_data:/target -v \$(pwd):/backup alpine sh -c 'cd /target && tar xzf /backup/archon-postgres-volume.tar.gz'

    # Restore containers from compose file if available
    if [ -f 'archon-compose-backup.yml' ]; then
        cp archon-compose-backup.yml /opt/archon/docker-compose.yml
        cd /opt/archon
        docker compose up -d
    else
        # Manual container recreation
        docker run -d --name archon_postgres --restart unless-stopped --network archon_network -p 54322:5432 -v archon-supabase_postgres_data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres pgvector/pgvector:pg16
        sleep 30
        docker run -d --name archon_postgrest --restart unless-stopped --network archon_network -p 54321:3000 -e PGRST_DB_URI=postgres://postgres:postgres@archon_postgres:5432/postgres postgrest/postgrest:v12.2.0
        docker run -d --name archon_adminer --restart unless-stopped --network archon_network -p 54323:8080 adminer:4.8.1
        docker run -d --name Archon-MCP --restart unless-stopped --network archon_app-network -p 8051:8051 archon-archon-mcp
        docker run -d --name Archon-Server --restart unless-stopped --network archon_app-network -p 8181:8181 archon-archon-server
        docker run -d --name Archon-Agents --restart unless-stopped --network archon_app-network -p 8052:8052 archon-archon-agents
    fi

    echo '✅ Archon restoration initiated'
"
```

### Validate All Services

**Comprehensive Service Validation:**
```bash
# Test all restored and new services
echo "=== Final Validation ==="

# GPU functionality
for node in prtr drtr; do
    echo "Testing GPU on $node:"
    ssh "$node" "
        nvidia-smi | head -5
        docker run --rm --gpus all nvidia/cuda:12.6-base-ubuntu20.04 nvidia-smi | head -5
        echo '✅ GPU functionality verified on $node'
    "
done

# Docker functionality
for node in crtr prtr drtr; do
    echo "Testing Docker on $node:"
    ssh "$node" "
        docker --version
        docker ps
        echo '✅ Docker functionality verified on $node'
    "
done

# Systemd service validation
ssh prtr "
    echo '=== Systemd Service Validation ==='
    # Check application services
    systemctl is-active archon.service && echo '✅ Archon systemd service active' || echo '⚠️ Archon systemd service inactive'
    systemctl is-active ollama.service && echo '✅ Ollama service active' || echo '⚠️ Ollama service inactive'

    # Check infrastructure services
    systemctl is-active nvidia-persistenced.service && echo '✅ NVIDIA persistence active'
    systemctl is-active docker.service && echo '✅ Docker service active'
    systemctl is-active containerd.service && echo '✅ Containerd active'
"

# Archon dual-stack validation (containers + systemd service)
ssh prtr "
    echo 'Testing Archon dual-stack (containers + systemd):'
    docker ps --filter 'name=archon' --format 'Container: {{.Names}} {{.Status}}'
    curl -f http://localhost:8051/health 2>/dev/null && echo '✅ MCP healthy' || echo '❌ MCP not responding'
    curl -f http://localhost:8181/health 2>/dev/null && echo '✅ Server healthy' || echo '❌ Server not responding'
    curl -f http://localhost:8052/health 2>/dev/null && echo '✅ Agents healthy' || echo '❌ Agents not responding'
"

# Cluster connectivity
echo "Testing cluster connectivity:"
for node in crtr prtr drtr; do
    ssh "$node" "echo '$node: online and configured'"
done

echo "✅ Complete infrastructure reset sequence completed successfully!"
```

### Enable Monitoring

**Set Up Post-Reset Monitoring:**
```bash
# Deploy monitoring and health checks
ssh prtr "
    # Enable Archon health monitoring
    sudo systemctl enable archon-health-check.timer
    sudo systemctl start archon-health-check.timer

    # Test health check
    /usr/local/bin/archon-health-check.sh
"

# Set up cluster-wide monitoring
for node in crtr prtr drtr; do
    ssh "$node" "
        # Create simple health script
        echo '#!/bin/bash' | sudo tee /usr/local/bin/node-health-check.sh
        echo 'echo \"Node: \$(hostname)\"' | sudo tee -a /usr/local/bin/node-health-check.sh
        echo 'echo \"Uptime: \$(uptime)\"' | sudo tee -a /usr/local/bin/node-health-check.sh
        echo 'echo \"Disk: \$(df -h / | tail -1)\"' | sudo tee -a /usr/local/bin/node-health-check.sh
        echo 'echo \"Memory: \$(free -h | grep ^Mem)\"' | sudo tee -a /usr/local/bin/node-health-check.sh
        sudo chmod +x /usr/local/bin/node-health-check.sh

        echo '✅ Health monitoring enabled on $node'
    "
done
```

## Post-Reset Validation Checklist

### Infrastructure Validation

**✅ System State:**
- [ ] All nodes online and accessible
- [ ] Clean package installations (no conflicts)
- [ ] System services running properly
- [ ] Network connectivity functional

**✅ NVIDIA/CUDA (GPU Nodes):**
- [ ] nvidia-smi functional
- [ ] CUDA toolkit installed and accessible
- [ ] GPU memory and utilization visible
- [ ] Docker GPU integration working

**✅ Docker (All Nodes):**
- [ ] Docker service running
- [ ] Container operations functional
- [ ] Network creation working
- [ ] Volume operations working

**✅ Configuration Management:**
- [ ] Chezmoi templates rendering correctly
- [ ] Node-specific environment variables set
- [ ] Shell aliases and functions loaded
- [ ] Tool detection working properly

### Application Validation

**✅ Archon Container Stack:**
- [ ] All Archon containers running
- [ ] Database connectivity restored
- [ ] API endpoints responding
- [ ] Data integrity verified
- [ ] Performance within normal ranges

**✅ Cluster Services:**
- [ ] NFS shares accessible
- [ ] DNS resolution working
- [ ] SSH access functional
- [ ] Git repository accessible

## Rollback Procedures

### Emergency Rollback

If any phase fails critically:

**Immediate Rollback:**
```bash
# Stop current installation
sudo systemctl stop docker nvidia-persistenced 2>/dev/null || true

# Restore from backup
cd /cluster-nas/backups/infrastructure-reset-*/
sudo dpkg -i previous-packages/*.deb  # If package backups available

# Restore Archon immediately
cd archon-preservation-*/
docker load < archon-images-complete.tar.gz
# Continue with restoration procedure...
```

### Partial Rollback

If specific components fail:

**NVIDIA Rollback:**
```bash
# Revert to previous NVIDIA installation
sudo apt install nvidia-driver-470  # Previous working version
sudo reboot
```

**Docker Rollback:**
```bash
# Revert to Debian Docker packages
sudo apt remove docker-ce docker-ce-cli
sudo apt install docker.io docker-compose
sudo systemctl restart docker
```

## Conclusion

This complete infrastructure reset sequence provides:

- **Comprehensive Cleanup**: Total removal of fragmented installations
- **Unified Configuration**: Template-driven, node-specific management
- **Application Preservation**: 100% Archon container stack continuity
- **Optimal Performance**: Modern NVIDIA + Docker stack with GPU integration
- **Risk Management**: Extensive backup and rollback procedures
- **Monitoring Integration**: Health checks and performance validation

The sequence transforms the Co-lab cluster into a clean, unified, optimally configured infrastructure platform while maintaining critical application continuity throughout the process.

**Execution Time**: ~3 hours total
**Downtime**: ~2 hours (application services preserved)
**Risk Level**: Low (comprehensive backup and validation)
**Result**: Production-ready, unified cluster infrastructure

This approach provides the foundation for years of reliable, high-performance cluster operations with modern tooling and unified configuration management.