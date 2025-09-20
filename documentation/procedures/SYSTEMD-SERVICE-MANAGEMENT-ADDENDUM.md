# Systemd Service Management Addendum for Infrastructure Reset

**Document Version**: 1.0
**Date**: September 2025
**Scope**: Detailed systemd service management for infrastructure reset sequence
**Integration**: Critical addendum to COMPLETE-INFRASTRUCTURE-RESET-SEQUENCE.md

---

## Executive Summary

This addendum provides precise systemd service management procedures based on comprehensive analysis of the prtr node's 318 systemd units. It identifies critical service dependencies, preservation requirements, and specific stop/start sequences for the infrastructure reset.

### Key Discoveries

**Critical Application Services:**
- `archon.service` - Archon running as systemd service (in addition to containers)
- `ollama.service` - Ollama running as systemd service
- Complex service interdependencies requiring careful management

**Infrastructure Dependencies:**
- NVIDIA services with suspend/resume integration
- Docker socket and service dependencies
- NFS client integration for cluster storage

---

## Service Categorization and Management Strategy

### Category 1: Critical Preservation Services (Never Stop)

**Core Infrastructure (Must Remain Active):**
```
ssh.service                     # Remote access - NEVER STOP
NetworkManager.service          # Network connectivity
nfs-client.target              # Cluster NFS access
rpcbind.service                # NFS dependencies
systemd-logind.service         # Login management
systemd-journald.service       # Logging
dbus.service                   # System messaging
```

**Management Strategy:**
- **Never disable or stop** these services
- Verify running state before and after reset
- Include in health checks

### Category 2: Application Services (Preserve Data, Manage Service)

**Archon Infrastructure:**
```
archon.service                  # Archon systemd service
+ Archon Docker containers      # Container stack
+ archon-supabase_postgres_data # Data volumes
+ archon_app-network           # Container networks
```

**Ollama Service:**
```
ollama.service                  # Ollama systemd service
```

**Management Strategy:**
- **Stop services** before Docker removal
- **Backup service configurations**
- **Preserve data directories**
- **Restore services** after reinstallation

### Category 3: Reset Target Services (Remove/Reinstall)

**NVIDIA Services:**
```
nvidia-persistenced.service     # enabled/enabled
nvidia-hibernate.service       # enabled/enabled
nvidia-resume.service          # enabled/enabled
nvidia-suspend.service         # enabled/enabled
```

**Docker Services:**
```
docker.service                 # enabled/enabled
docker.socket                  # enabled/enabled
containerd.service             # enabled/enabled
```

**Management Strategy:**
- **Stop and disable** before package removal
- **Remove systemd units** during cleanup
- **Reinstall and enable** with new packages

### Category 4: System Services (Leave Untouched)

**Core System Services:**
```
systemd-* services             # Core system management
NetworkManager-*               # Network management
apparmor.service               # Security
cron.service                   # Task scheduling
keyboard-setup.service         # System setup
console-setup.service          # Console configuration
```

**Management Strategy:**
- **No changes required**
- Monitor during reset for stability

---

## Detailed Service Management Procedures

### Phase 1: Pre-Reset Service Documentation

**Document Current Service State:**
```bash
# Create comprehensive service state backup
mkdir -p /cluster-nas/backups/systemd-state-$(date +%Y%m%d-%H%M%S)
cd /cluster-nas/backups/systemd-state-$(date +%Y%m%d-%H%M%S)

# Export complete service state
systemctl list-unit-files > systemd-unit-files-before.txt
systemctl list-units --all > systemd-units-before.txt
systemctl status archon.service ollama.service > application-services-before.txt

# Export service configurations for restoration
systemctl show archon.service > archon-service-config.txt
systemctl show ollama.service > ollama-service-config.txt

# Check service dependencies
systemctl list-dependencies archon.service > archon-dependencies.txt
systemctl list-dependencies ollama.service > ollama-dependencies.txt
```

**Backup Application Service Configurations:**
```bash
# Backup systemd service files
sudo cp /etc/systemd/system/archon.service archon.service.backup 2>/dev/null || \
sudo cp /lib/systemd/system/archon.service archon.service.backup 2>/dev/null || \
echo "archon.service not found in standard locations"

sudo cp /etc/systemd/system/ollama.service ollama.service.backup 2>/dev/null || \
sudo cp /lib/systemd/system/ollama.service ollama.service.backup 2>/dev/null || \
echo "ollama.service not found in standard locations"

# Backup any override files
sudo cp -r /etc/systemd/system/archon.service.d/ archon-service-overrides/ 2>/dev/null || true
sudo cp -r /etc/systemd/system/ollama.service.d/ ollama-service-overrides/ 2>/dev/null || true
```

### Phase 2: Application Service Preservation

**Stop Application Services (Before Docker Removal):**
```bash
echo "=== Stopping Application Services ==="

# Stop Archon systemd service (containers will be handled separately)
sudo systemctl stop archon.service
sudo systemctl disable archon.service

# Stop Ollama service
sudo systemctl stop ollama.service
sudo systemctl disable ollama.service

# Verify services stopped
systemctl is-active archon.service || echo "✅ Archon service stopped"
systemctl is-active ollama.service || echo "✅ Ollama service stopped"

# Check for any application-specific data directories
echo "=== Checking Application Data Directories ==="
ls -la /opt/archon/ 2>/dev/null || echo "No /opt/archon directory"
ls -la /opt/ollama/ 2>/dev/null || echo "No /opt/ollama directory"
ls -la /var/lib/ollama/ 2>/dev/null || echo "No /var/lib/ollama directory"
```

**Backup Application Data:**
```bash
# Backup Archon data (if not in containers)
if [ -d "/opt/archon" ]; then
    echo "Backing up Archon data directory..."
    sudo tar czf archon-data-backup.tar.gz -C /opt archon/
fi

# Backup Ollama data
if [ -d "/var/lib/ollama" ]; then
    echo "Backing up Ollama data directory..."
    sudo tar czf ollama-data-backup.tar.gz -C /var/lib ollama/
fi

# Backup any additional application directories
for app_dir in /opt/ollama /home/prtr/.ollama /usr/local/ollama; do
    if [ -d "$app_dir" ]; then
        echo "Backing up $app_dir..."
        sudo tar czf "$(basename "$app_dir")-backup.tar.gz" -C "$(dirname "$app_dir")" "$(basename "$app_dir")/"
    fi
done
```

### Phase 3: Reset Target Service Management

**Stop NVIDIA Services:**
```bash
echo "=== Stopping NVIDIA Services ==="

# Stop NVIDIA services in correct order
sudo systemctl stop nvidia-persistenced.service
sudo systemctl stop nvidia-hibernate.service
sudo systemctl stop nvidia-resume.service
sudo systemctl stop nvidia-suspend.service

# Disable NVIDIA services
sudo systemctl disable nvidia-persistenced.service
sudo systemctl disable nvidia-hibernate.service
sudo systemctl disable nvidia-resume.service
sudo systemctl disable nvidia-suspend.service

# Verify NVIDIA services stopped
for service in nvidia-persistenced nvidia-hibernate nvidia-resume nvidia-suspend; do
    systemctl is-active $service.service || echo "✅ $service stopped"
done
```

**Stop Docker Services:**
```bash
echo "=== Stopping Docker Services ==="

# Stop Docker services in correct order
sudo systemctl stop docker.service
sudo systemctl stop docker.socket
sudo systemctl stop containerd.service

# Disable Docker services
sudo systemctl disable docker.service
sudo systemctl disable docker.socket
sudo systemctl disable containerd.service

# Verify Docker services stopped
for service in docker containerd; do
    systemctl is-active $service.service || echo "✅ $service stopped"
done

systemctl is-active docker.socket || echo "✅ docker.socket stopped"
```

### Phase 4: Service Cleanup During Package Removal

**Remove Systemd Units:**
```bash
echo "=== Cleaning Systemd Units ==="

# After package removal, clean any remaining units
sudo systemctl daemon-reload

# Remove any orphaned units
sudo find /etc/systemd/system -name "*nvidia*" -delete 2>/dev/null || true
sudo find /etc/systemd/system -name "*docker*" -delete 2>/dev/null || true
sudo find /lib/systemd/system -name "*nvidia*" -delete 2>/dev/null || true
sudo find /lib/systemd/system -name "*docker*" -delete 2>/dev/null || true

# Reload daemon after cleanup
sudo systemctl daemon-reload
sudo systemctl reset-failed
```

### Phase 5: Post-Reset Service Restoration

**Restore Application Services:**
```bash
echo "=== Restoring Application Services ==="

# Restore service files if they were removed
if [ -f "archon.service.backup" ]; then
    echo "Restoring Archon service configuration..."
    sudo cp archon.service.backup /etc/systemd/system/archon.service
    sudo cp -r archon-service-overrides/ /etc/systemd/system/archon.service.d/ 2>/dev/null || true
fi

if [ -f "ollama.service.backup" ]; then
    echo "Restoring Ollama service configuration..."
    sudo cp ollama.service.backup /etc/systemd/system/ollama.service
    sudo cp -r ollama-service-overrides/ /etc/systemd/system/ollama.service.d/ 2>/dev/null || true
fi

# Reload systemd
sudo systemctl daemon-reload

# Restore application data
if [ -f "archon-data-backup.tar.gz" ]; then
    echo "Restoring Archon data..."
    sudo tar xzf archon-data-backup.tar.gz -C /opt/
fi

if [ -f "ollama-data-backup.tar.gz" ]; then
    echo "Restoring Ollama data..."
    sudo tar xzf ollama-data-backup.tar.gz -C /var/lib/
fi
```

**Verify New Service Installation:**
```bash
echo "=== Verifying New Services ==="

# Check that new services are properly installed
systemctl list-unit-files | grep -E "nvidia|docker" > systemd-units-after.txt

# Enable and start new services
sudo systemctl enable nvidia-persistenced.service
sudo systemctl enable docker.service
sudo systemctl enable docker.socket
sudo systemctl enable containerd.service

# Start services
sudo systemctl start docker.service
sudo systemctl start nvidia-persistenced.service

# Verify services are running
systemctl is-active docker.service && echo "✅ Docker running"
systemctl is-active nvidia-persistenced.service && echo "✅ NVIDIA persistence running"
```

**Conditional Application Service Restart:**
```bash
echo "=== Conditional Application Service Restart ==="

# Only restart application services if their dependencies are ready
if systemctl is-active docker.service; then
    echo "Docker ready, can restart container-dependent services..."

    # Wait for Docker to be fully ready
    sleep 10

    # Restart Archon service (if containers are restored)
    if docker ps --filter "name=archon" --format "{{.Names}}" | grep -q archon; then
        sudo systemctl enable archon.service
        sudo systemctl start archon.service
        echo "✅ Archon service restarted"
    fi
fi

# Restart Ollama service
sudo systemctl enable ollama.service
sudo systemctl start ollama.service
systemctl is-active ollama.service && echo "✅ Ollama service running"
```

### Phase 6: Service Validation and Health Checks

**Comprehensive Service Health Check:**
```bash
#!/bin/bash
# Service Health Validation Script

echo "=== Infrastructure Reset Service Validation ==="
echo "Date: $(date)"
echo ""

# Core Infrastructure Services
echo "Core Infrastructure Services:"
for service in ssh NetworkManager nfs-client rpcbind; do
    if systemctl is-active $service.service >/dev/null 2>&1 || systemctl is-active $service.target >/dev/null 2>&1; then
        echo "✅ $service: Active"
    else
        echo "❌ $service: Inactive"
    fi
done

echo ""

# GPU/Docker Services
echo "GPU and Docker Services:"
for service in nvidia-persistenced docker containerd; do
    if systemctl is-active $service.service >/dev/null 2>&1; then
        echo "✅ $service: Active"
    else
        echo "❌ $service: Inactive"
    fi
done

echo ""

# Application Services
echo "Application Services:"
for service in archon ollama; do
    if systemctl is-active $service.service >/dev/null 2>&1; then
        echo "✅ $service: Active"
    else
        echo "⚠️  $service: Inactive (check if expected)"
    fi
done

echo ""

# Service Dependencies Check
echo "Service Dependencies:"
echo "Docker socket: $(systemctl is-active docker.socket)"
echo "Docker containers: $(docker ps --format '{{.Names}}' | wc -l) running"
echo "NVIDIA devices: $(nvidia-smi -L | wc -l) detected"

echo ""

# Performance Check
echo "Performance Indicators:"
echo "System load: $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory usage: $(free -h | grep '^Mem' | awk '{print $3"/"$2}')"
echo "Disk usage: $(df -h / | tail -1 | awk '{print $5}')"

echo ""
echo "=== Service Validation Complete ==="
```

---

## Service Dependencies and Critical Paths

### NVIDIA Service Dependencies

**Service Chain:**
```
nvidia-persistenced.service
├── Requires: nvidia driver modules
├── Wants: nvidia-suspend.service
├── Wants: nvidia-resume.service
└── Wants: nvidia-hibernate.service
```

**Critical for:**
- GPU memory persistence across suspend/resume
- Container GPU access
- Machine learning workload stability

### Docker Service Dependencies

**Service Chain:**
```
docker.service
├── Requires: containerd.service
├── Wants: docker.socket
├── After: network-online.target
└── Requisite: nvidia-persistenced.service (for GPU containers)
```

**Critical for:**
- Container orchestration
- Archon container stack
- GPU container access

### Application Service Dependencies

**Archon Service:**
```
archon.service
├── Requires: docker.service
├── After: docker.service
├── Wants: network-online.target
└── Requisite: archon containers + systemd service
```

**Ollama Service:**
```
ollama.service
├── After: network.target
├── Wants: nvidia-persistenced.service (for GPU)
└── Requires: filesystem access to model storage
```

---

## Integration with Infrastructure Reset Sequence

### Updated Reset Phase Integration

**Phase 2 Enhancement: Complete Removal**
```bash
# Add before existing removal procedures:
# 1. Stop application services
sudo systemctl stop archon.service ollama.service

# 2. Stop GPU services
sudo systemctl stop nvidia-persistenced.service nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service

# 3. Stop Docker services
sudo systemctl stop docker.service docker.socket containerd.service

# 4. Disable all target services
sudo systemctl disable nvidia-persistenced.service docker.service containerd.service archon.service ollama.service

# Then proceed with existing package removal...
```

**Phase 4 Enhancement: Optimal Reinstallation**
```bash
# Add after package installation:
# 1. Verify service installation
systemctl list-unit-files | grep -E "nvidia|docker"

# 2. Enable and start core services
sudo systemctl enable nvidia-persistenced.service docker.service containerd.service

# 3. Start services in order
sudo systemctl start nvidia-persistenced.service
sudo systemctl start docker.service

# 4. Verify GPU-Docker integration
docker run --rm --gpus all nvidia/cuda:12.6-base-ubuntu20.04 nvidia-smi

# 5. Conditionally restore application services
# (After container restoration is complete)
```

**Phase 5 Enhancement: Application Restoration**
```bash
# Add after Archon container restoration:
# 1. Restore application systemd services
sudo systemctl enable archon.service ollama.service

# 2. Start application services
sudo systemctl start ollama.service
sudo systemctl start archon.service

# 3. Validate service integration
systemctl status archon.service ollama.service
```

---

## Risk Management and Troubleshooting

### Common Service Issues

**NVIDIA Service Failures:**
```bash
# If nvidia-persistenced fails to start:
sudo nvidia-smi -pm 1  # Enable persistence mode manually
sudo systemctl restart nvidia-persistenced.service

# Check for module loading issues:
lsmod | grep nvidia
sudo modprobe nvidia
```

**Docker Service Issues:**
```bash
# If Docker fails to start:
sudo systemctl status docker.service  # Check detailed error
sudo journalctl -u docker.service -f  # Follow logs

# Common fix - clean Docker state:
sudo rm -rf /var/lib/docker/tmp/
sudo systemctl restart docker.service
```

**Application Service Dependencies:**
```bash
# If Archon service fails due to missing containers:
systemctl status archon.service
# Restore containers first, then restart service

# If Ollama fails due to GPU access:
nvidia-smi  # Verify GPU access
sudo systemctl restart nvidia-persistenced.service
sudo systemctl restart ollama.service
```

### Emergency Service Recovery

**Critical Service Recovery:**
```bash
# If critical services are accidentally stopped:
sudo systemctl start ssh.service NetworkManager.service
sudo systemctl start nfs-client.target rpcbind.service

# Emergency Docker restart for containers:
sudo systemctl start docker.service
docker start $(docker ps -aq)

# Emergency NVIDIA recovery:
sudo modprobe nvidia
sudo systemctl start nvidia-persistenced.service
```

---

## Conclusion

This systemd service management addendum provides:

- **Precise Service Control**: Detailed start/stop sequences for infrastructure reset
- **Dependency Management**: Understanding of service interdependencies
- **Application Preservation**: Specific procedures for Archon and Ollama services
- **Risk Mitigation**: Emergency recovery procedures for critical services
- **Integration Ready**: Direct integration with existing reset procedures

The discovery of `archon.service` and `ollama.service` as systemd services (in addition to containers) significantly enhances our understanding of the application stack and ensures complete preservation during the infrastructure reset.

**Critical Updates for Reset Strategy:**
1. **Enhanced Archon Preservation**: Handle both systemd service and containers
2. **Ollama Service Management**: Preserve systemd service configuration
3. **Service Dependency Ordering**: Ensure correct start/stop sequences
4. **Health Validation**: Comprehensive service state verification

This addendum ensures the infrastructure reset sequence maintains **100% application functionality** while achieving optimal system configuration.