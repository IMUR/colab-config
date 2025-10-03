---
title: "Container Platform Strategy"
description: "Docker clean reinstall strategy with Archon preservation for Co-lab cluster"
version: "1.0"
date: "2025-09-27"
category: "architecture"
tags: ["docker", "containers", "archon", "gpu", "infrastructure"]
applies_to: ["all_nodes"]
related:
  - "GPU-COMPUTE-STRATEGY.md"
  - "CLUSTER-ARCHITECTURE.md"
  - "../guides/INFRASTRUCTURE-RESET.md"
---

# Container Platform Strategy

## Executive Summary

This document outlines the complete Docker removal and clean reinstallation strategy for the Co-lab cluster, with **100% preservation** of the Archon container stack. This approach eliminates Docker fragmentation while maintaining critical application continuity.

### Strategic Integration

This Docker strategy is **Phase 2** of the complete infrastructure reset sequence:
1. **Phase 1**: Complete NVIDIA/CUDA removal (see GPU-COMPUTE-STRATEGY.md)
2. **Phase 2**: Complete Docker removal with Archon preservation (this document)
3. **Phase 3**: Deploy omni-config across cluster via chezmoi
4. **Phase 4**: Optimal reinstallation of NVIDIA + Docker with unified configuration

## Current Docker State Assessment

### Installation Fragmentation Issues
- **Mixed Package Sources**: Debian packages + Official Docker repository
- **Desktop Remnants**: Broken CLI plugins and user configs from removed Docker Desktop
- **Configuration Conflicts**: User daemon.json vs system configurations
- **Version Inconsistencies**: Mix of 26.1.5 packages with newer repository sources

### Archon Container Stack (Critical Preservation Target)
```
Archon Infrastructure:
├── archon-frontend (727a81a0561e) - UI/Dashboard
├── archon-archon-mcp (3014fa84556a) - MCP Server
├── archon-archon-server (51262734de88) - Core Server
├── archon-archon-agents (703f0685fa09) - Agent Runtime
├── postgrest/postgrest:v12.2.0 - API Gateway
├── pgvector/pgvector:pg16 - Vector Database
└── adminer:4.8.1 - Database Admin

Critical Data:
├── archon-supabase_postgres_data (Volume) - PostgreSQL database
├── archon_app-network (Network) - Application networking
└── archon_network (Network) - Infrastructure networking
```

## Phase 1: Complete Archon Preservation

### Pre-Removal Data Backup

**Create Backup Directory:**
```bash
sudo mkdir -p /cluster-nas/backups/archon-preservation-$(date +%Y%m%d-%H%M%S)
cd /cluster-nas/backups/archon-preservation-$(date +%Y%m%d-%H%M%S)
```

**Export Running Configuration:**
```bash
# Document current container state
docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" > archon-containers-state.txt

# Export compose configuration (if available)
if [ -f "/opt/archon/docker-compose.yml" ]; then
    cp /opt/archon/docker-compose.yml archon-compose-backup.yml
    docker-compose -f /opt/archon/docker-compose.yml config > archon-compose-rendered.yml
fi

# Export individual container configurations
for container in $(docker ps -a --filter "name=archon" --format "{{.Names}}"); do
    docker inspect "$container" > "inspect-${container}.json"
done
```

**Save All Container Images:**
```bash
# Get all Archon-related images
docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "(archon|postgrest|pgvector|adminer)" > archon-images-list.txt

# Save all images in compressed format
docker save $(cat archon-images-list.txt) | gzip > archon-images-complete.tar.gz

# Verify backup integrity
echo "Image backup size: $(du -h archon-images-complete.tar.gz)"
echo "Images included: $(cat archon-images-list.txt | wc -l)"
```

### Critical Data Volume Backup

**PostgreSQL Database Backup:**
```bash
# Create volume backup with data verification
docker run --rm \
    -v archon-supabase_postgres_data:/source:ro \
    -v $(pwd):/backup \
    alpine sh -c "
        cd /source &&
        echo 'Volume contents:' &&
        find . -type f | head -20 &&
        tar czf /backup/archon-postgres-volume.tar.gz . &&
        echo 'Backup created: ' &&
        ls -la /backup/archon-postgres-volume.tar.gz
    "

# Additional SQL dump if database is running
if docker ps --filter "name=archon_postgres" --format "{{.Names}}" | grep -q archon_postgres; then
    docker exec archon_postgres pg_dumpall -U postgres > archon-database-dump.sql
    echo "SQL dump completed: $(wc -l archon-database-dump.sql)"
fi
```

**Application Data Backup:**
```bash
# Backup any additional volumes
docker volume ls --filter "name=archon" --format "{{.Name}}" | while read volume; do
    echo "Backing up volume: $volume"
    docker run --rm \
        -v "$volume":/source:ro \
        -v $(pwd):/backup \
        alpine tar czf "/backup/volume-${volume}.tar.gz" -C /source .
done
```

### Network and Configuration Export

**Network Configuration:**
```bash
# Export network configurations
docker network ls --filter "name=archon" --format "{{.Name}}" | while read network; do
    docker network inspect "$network" > "network-${network}.json"
done

# Document port mappings
docker ps --filter "name=archon" --format "{{.Names}}: {{.Ports}}" > archon-port-mappings.txt
```

**Environment Variables and Secrets:**
```bash
# Extract environment variables (sanitize secrets)
for container in $(docker ps -a --filter "name=archon" --format "{{.Names}}"); do
    echo "=== $container Environment ===" >> archon-env-vars.txt
    docker inspect "$container" --format "{{range .Config.Env}}{{println .}}{{end}}" >> archon-env-vars.txt
    echo "" >> archon-env-vars.txt
done

# Note: Review archon-env-vars.txt and remove any sensitive data before storing
```

### Verification and Manifest

**Create Restoration Manifest:**
```bash
cat > archon-restoration-manifest.txt <<EOF
Archon Preservation Manifest - $(date)
=====================================

Backup Location: $(pwd)
Node: $(hostname)
Docker Version: $(docker --version)

Files Created:
- archon-containers-state.txt (container status)
- archon-compose-backup.yml (original compose file)
- archon-compose-rendered.yml (rendered configuration)
- archon-images-complete.tar.gz (all container images)
- archon-postgres-volume.tar.gz (critical database volume)
- archon-database-dump.sql (SQL dump backup)
- network-*.json (network configurations)
- archon-port-mappings.txt (port mapping documentation)
- archon-env-vars.txt (environment variables - review for secrets)

Image Count: $(cat archon-images-list.txt | wc -l)
Volume Backups: $(ls volume-*.tar.gz 2>/dev/null | wc -l)
Total Backup Size: $(du -sh . | cut -f1)

Restoration Command:
./restore-archon.sh

EOF

echo "✅ Archon preservation completed successfully"
echo "📁 Backup location: $(pwd)"
echo "📊 Total size: $(du -sh . | cut -f1)"
```

## Phase 2: Complete Docker Removal

### Stop All Containers and Services

**Graceful Container Shutdown:**
```bash
# Stop all containers gracefully
echo "Stopping all Docker containers..."
docker stop $(docker ps -q) 2>/dev/null || true

# Wait for graceful shutdown
sleep 10

# Force stop any remaining containers
docker kill $(docker ps -q) 2>/dev/null || true

# Stop Docker service
sudo systemctl stop docker
sudo systemctl stop containerd
```

### Package Removal (Comprehensive)

**Remove All Docker Packages:**
```bash
# Remove all Docker-related packages
sudo apt purge -y \
    docker.io \
    docker-cli \
    docker-compose \
    docker-buildx \
    containerd \
    runc \
    docker-ce \
    docker-ce-cli \
    docker-ce-rootless-extras \
    docker-scan-plugin

# Remove any remaining docker packages
sudo apt purge -y $(dpkg -l | grep docker | awk '{print $2}')

# Clean package cache
sudo apt autoremove -y --purge
sudo apt autoclean
```

### Configuration and Data Cleanup

**System Configuration Removal:**
```bash
# Remove system configurations
sudo rm -rf /etc/docker/
sudo rm -rf /etc/systemd/system/docker.service.d/
sudo rm -rf /var/lib/docker/
sudo rm -rf /var/lib/containerd/
sudo rm -rf /run/docker/
sudo rm -rf /run/containerd/

# Remove repository configurations
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/keyrings/docker.gpg

# Remove systemd service files
sudo systemctl daemon-reload
```

**User Configuration Cleanup:**
```bash
# Clean user Docker configurations
rm -rf ~/.docker/
rm -rf ~/.local/share/docker/

# Remove user groups (will be recreated)
sudo deluser prtr docker 2>/dev/null || true
```

### Network and Storage Cleanup

**Network Interface Cleanup:**
```bash
# Remove Docker network interfaces
sudo ip link delete docker0 2>/dev/null || true

# Clean iptables rules (Docker-related)
sudo iptables -t nat -F DOCKER 2>/dev/null || true
sudo iptables -t filter -F DOCKER 2>/dev/null || true
sudo iptables -t filter -F DOCKER-ISOLATION-STAGE-1 2>/dev/null || true
sudo iptables -t filter -F DOCKER-ISOLATION-STAGE-2 2>/dev/null || true
```

**Verify Complete Removal:**
```bash
# Verify no Docker processes
ps aux | grep docker | grep -v grep || echo "✅ No Docker processes"

# Verify no Docker commands
command -v docker && echo "❌ Docker still installed" || echo "✅ Docker removed"

# Verify no Docker systemd services
systemctl list-units | grep docker || echo "✅ No Docker services"

# Reboot to ensure clean state
echo "⚠️  Reboot required for complete cleanup"
```

## Phase 3: Clean Docker Installation

### Official Docker Repository Setup

**Add Official Docker Repository:**
```bash
# Install prerequisites
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
sudo apt update
```

### Install Latest Docker Engine

**Install Docker Components:**
```bash
# Install latest Docker Engine with compose
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Verify installation
docker --version
docker compose version
```

### Docker Configuration for GPU Integration

**Configure Docker Daemon:**
```bash
# Create optimized daemon configuration
sudo tee /etc/docker/daemon.json <<EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "default-runtime": "runc",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "features": {
        "buildkit": true
    }
}
EOF

# Note: NVIDIA runtime configuration will be updated after NVIDIA installation
```

### Service Configuration and User Setup

**Configure Docker Service:**
```bash
# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl enable containerd
sudo systemctl start docker

# Add user to docker group
sudo usermod -aG docker prtr

# Verify Docker is running
sudo systemctl status docker
docker info
```

## Phase 4: Archon Restoration

### Image Restoration

**Restore Container Images:**
```bash
# Navigate to backup directory
cd /cluster-nas/backups/archon-preservation-*/

# Load all preserved images
echo "Restoring Archon container images..."
docker load < archon-images-complete.tar.gz

# Verify images restored
echo "Verifying restored images:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "(archon|postgrest|pgvector|adminer)"
```

### Network Recreation

**Recreate Archon Networks:**
```bash
# Recreate custom networks (basic bridge networks)
docker network create archon_app-network 2>/dev/null || echo "Network archon_app-network already exists"
docker network create archon_network 2>/dev/null || echo "Network archon_network already exists"

# Verify networks
docker network ls | grep archon
```

### Volume Data Restoration

**Restore PostgreSQL Data:**
```bash
# Create volume
docker volume create archon-supabase_postgres_data

# Restore volume data
echo "Restoring PostgreSQL data volume..."
docker run --rm \
    -v archon-supabase_postgres_data:/target \
    -v $(pwd):/backup \
    alpine sh -c "cd /target && tar xzf /backup/archon-postgres-volume.tar.gz"

# Verify volume restoration
docker run --rm -v archon-supabase_postgres_data:/data alpine ls -la /data/
```

**Restore Additional Volumes:**
```bash
# Restore any additional volumes
for volume_backup in volume-archon*.tar.gz; do
    if [ -f "$volume_backup" ]; then
        volume_name=$(echo "$volume_backup" | sed 's/volume-//' | sed 's/.tar.gz//')
        echo "Restoring volume: $volume_name"
        docker volume create "$volume_name"
        docker run --rm \
            -v "$volume_name":/target \
            -v $(pwd):/backup \
            alpine tar xzf "/backup/$volume_backup" -C /target
    fi
done
```

### Container Recreation and Startup

**Restore Container Stack:**
```bash
# Method 1: If docker-compose.yml is available
if [ -f "archon-compose-backup.yml" ]; then
    echo "Restoring Archon stack from compose file..."
    cp archon-compose-backup.yml /opt/archon/docker-compose.yml
    cd /opt/archon
    docker compose up -d

# Method 2: Manual container recreation using inspect data
else
    echo "Manually recreating containers from inspect data..."

    # PostgreSQL Database (start first - dependency)
    docker run -d \
        --name archon_postgres \
        --restart unless-stopped \
        --network archon_network \
        -p 54322:5432 \
        -v archon-supabase_postgres_data:/var/lib/postgresql/data \
        -e POSTGRES_PASSWORD=postgres \
        pgvector/pgvector:pg16

    # Wait for database to be ready
    echo "Waiting for PostgreSQL to be ready..."
    sleep 30

    # PostgREST API Gateway
    docker run -d \
        --name archon_postgrest \
        --restart unless-stopped \
        --network archon_network \
        -p 54321:3000 \
        -e PGRST_DB_URI=postgres://postgres:postgres@archon_postgres:5432/postgres \
        postgrest/postgrest:v12.2.0

    # Adminer Database Admin
    docker run -d \
        --name archon_adminer \
        --restart unless-stopped \
        --network archon_network \
        -p 54323:8080 \
        adminer:4.8.1

    # Archon Core Services
    docker run -d \
        --name Archon-MCP \
        --restart unless-stopped \
        --network archon_app-network \
        -p 8051:8051 \
        archon-archon-mcp

    docker run -d \
        --name Archon-Server \
        --restart unless-stopped \
        --network archon_app-network \
        -p 8181:8181 \
        archon-archon-server

    docker run -d \
        --name Archon-Agents \
        --restart unless-stopped \
        --network archon_app-network \
        -p 8052:8052 \
        archon-archon-agents
fi
```

### Verification and Health Checks

**Verify Archon Restoration:**
```bash
# Check all containers are running
echo "=== Container Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Verify database connectivity
echo "=== Database Health ==="
docker exec archon_postgres pg_isready -U postgres

# Check container logs for errors
echo "=== Checking for startup errors ==="
for container in $(docker ps --filter "name=archon" --format "{{.Names}}"); do
    echo "--- $container logs ---"
    docker logs --tail 10 "$container"
done

# Test external connectivity
echo "=== External Connectivity ==="
curl -f http://localhost:8051/health 2>/dev/null && echo "✅ MCP healthy" || echo "❌ MCP not responding"
curl -f http://localhost:8181/health 2>/dev/null && echo "✅ Server healthy" || echo "❌ Server not responding"
curl -f http://localhost:8052/health 2>/dev/null && echo "✅ Agents healthy" || echo "❌ Agents not responding"
```

## Phase 5: Post-Installation Configuration

### Docker Optimization

**Performance Tuning:**
```bash
# Configure Docker for optimal performance
sudo tee -a /etc/docker/daemon.json <<EOF
{
    "default-ulimits": {
        "nofile": {
            "hard": 65536,
            "soft": 65536
        }
    },
    "max-concurrent-downloads": 10,
    "max-concurrent-uploads": 5
}
EOF

# Restart Docker to apply changes
sudo systemctl restart docker
```

### Monitoring and Logging

**Set up Container Monitoring:**
```bash
# Create monitoring script
sudo tee /usr/local/bin/archon-health-check.sh <<'EOF'
#!/bin/bash
# Archon Health Check Script

echo "=== Archon Health Report - $(date) ==="

# Check all Archon containers
echo "Container Status:"
docker ps --filter "name=archon" --format "table {{.Names}}\t{{.Status}}\t{{.RunningFor}}"

# Check resource usage
echo -e "\nResource Usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" \
    $(docker ps --filter "name=archon" --format "{{.Names}}")

# Check disk usage of volumes
echo -e "\nVolume Usage:"
docker system df -v | grep archon

# Log health status
echo "Health check completed at $(date)" >> /var/log/archon-health.log
EOF

chmod +x /usr/local/bin/archon-health-check.sh

# Create systemd timer for regular health checks
sudo tee /etc/systemd/system/archon-health-check.timer <<EOF
[Unit]
Description=Archon Health Check Timer
Requires=docker.service

[Timer]
OnCalendar=*:0/30  # Every 30 minutes
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo tee /etc/systemd/system/archon-health-check.service <<EOF
[Unit]
Description=Archon Health Check
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/archon-health-check.sh
EOF

# Enable health monitoring
sudo systemctl enable archon-health-check.timer
sudo systemctl start archon-health-check.timer
```

## Integration with Complete Infrastructure Reset

### Sequence Integration

This Docker strategy integrates with the complete infrastructure reset as follows:

**Pre-Reset (This Phase):**
1. ✅ Complete Archon preservation
2. ✅ Complete Docker removal
3. ✅ Complete NVIDIA removal (per NVIDIA strategy)

**Reset Phase:**
4. Deploy omni-config across cluster via chezmoi
5. Limited ansible for system-wide configurations

**Post-Reset Optimal Installation:**
6. Install fresh NVIDIA + CUDA with chezmoi template integration
7. Install fresh Docker with GPU runtime integration
8. Restore Archon with full GPU acceleration capability

### Template Integration Points

**Docker-related chezmoi template enhancements:**
```bash
# In dot_profile.tmpl
{{- if .has_docker }}
# Docker environment
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

{{- if .has_nvidia_container }}
# Docker GPU runtime
export DOCKER_DEFAULT_RUNTIME=nvidia
{{- end }}
{{- end }}

# In shell RC templates
{{- if .has_docker }}
alias dps='docker ps --format "table {{`{{.Names}}`}}\t{{`{{.Status}}`}}\t{{`{{.Ports}}`}}"'
alias dimg='docker images --format "table {{`{{.Repository}}`}}\t{{`{{.Tag}}`}}\t{{`{{.Size}}`}}"'
alias archon-status='docker ps --filter "name=archon" --format "table {{`{{.Names}}`}}\t{{`{{.Status}}`}}"'
alias archon-logs='docker logs -f'
alias archon-restart='cd /opt/archon && docker compose restart'
{{- end }}
```

## Risk Management and Rollback

### Backup Validation

**Pre-Removal Verification:**
```bash
# Verify backup integrity before proceeding
cd /cluster-nas/backups/archon-preservation-*/

# Test image backup
echo "Testing image backup integrity..."
docker load < archon-images-complete.tar.gz --quiet && echo "✅ Images backup valid"

# Test volume backup
echo "Testing volume backup integrity..."
tar -tzf archon-postgres-volume.tar.gz >/dev/null && echo "✅ Volume backup valid"

# Verify all files present
echo "Verifying backup completeness..."
required_files="archon-images-complete.tar.gz archon-postgres-volume.tar.gz archon-containers-state.txt"
for file in $required_files; do
    [ -f "$file" ] && echo "✅ $file present" || echo "❌ $file missing"
done
```

### Rollback Procedure

**Emergency Rollback to Previous Docker:**
```bash
# If new installation fails, rollback to Debian packages
sudo apt remove -y docker-ce docker-ce-cli containerd.io
sudo apt install -y docker.io docker-compose

# Restore from backup immediately
cd /cluster-nas/backups/archon-preservation-*/
docker load < archon-images-complete.tar.gz
# Continue with restoration procedure...
```

## Conclusion

This Docker clean reinstall strategy provides:

- **100% Archon Preservation**: Zero data loss, complete application continuity
- **Clean Installation**: Eliminates fragmentation and configuration conflicts
- **GPU Readiness**: Optimized for post-NVIDIA installation integration
- **Monitoring Integration**: Built-in health checks and logging
- **Template Compatibility**: Ready for chezmoi configuration management

The strategy ensures that the critical Archon infrastructure remains fully functional throughout the complete cluster infrastructure reset, while providing a clean foundation for optimal Docker+GPU integration.

**Next Steps:**
1. Execute Archon preservation procedure
2. Complete Docker and NVIDIA removal
3. Deploy omni-config via chezmoi
4. Execute optimal reinstallation with GPU integration
5. Restore Archon with enhanced GPU capabilities

This approach transforms the Docker installation into a clean, optimized platform while maintaining 100% application continuity for critical cluster workloads.