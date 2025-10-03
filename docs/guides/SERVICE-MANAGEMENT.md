---
title: "Service Management Guide"
description: "Comprehensive systemd service management for Co-lab cluster infrastructure"
version: "1.0"
date: "2025-09-27"
category: "guide"
tags: ["systemd", "services", "archon", "ollama", "docker", "nvidia"]
applies_to: ["all_nodes"]
related:
  - "INFRASTRUCTURE-RESET.md"
  - "../architecture/CONTAINER-PLATFORM-STRATEGY.md"
  - "../architecture/GPU-COMPUTE-STRATEGY.md"
---

# Service Management Guide

## Executive Summary

This guide provides comprehensive systemd service management procedures for the Co-lab cluster, based on detailed analysis of the 318 systemd units across cluster nodes. It identifies critical service dependencies, preservation requirements, and specific management sequences for infrastructure operations.

### Key Discoveries

**Critical Application Services:**
- `archon.service` - Archon running as systemd service (in addition to containers)
- `ollama.service` - Ollama running as systemd service
- Complex service interdependencies requiring careful management

**Infrastructure Dependencies:**
- NVIDIA services with suspend/resume integration
- Docker socket and service dependencies
- NFS client integration for cluster storage

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
- Verify running state before and after operations
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
- Monitor during operations for stability

## Detailed Service Management Procedures

### Pre-Operation Service Documentation

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

### Application Service Preservation

**Stop Application Services (Before Infrastructure Changes):**
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

### Infrastructure Service Management

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

### Service Cleanup During Package Removal

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

### Post-Installation Service Restoration

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

## Service Health Validation

### Comprehensive Service Health Check

**Service Health Validation Script:**
```bash
#!/bin/bash
# Service Health Validation Script

echo "=== Infrastructure Service Validation ==="
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

### Service Dependency Analysis

**NVIDIA Service Dependencies:**
```
nvidia-persistenced.service
├── Requires: nvidia driver modules
├── Wants: nvidia-suspend.service
├── Wants: nvidia-resume.service
└── Wants: nvidia-hibernate.service
```

**Docker Service Dependencies:**
```
docker.service
├── Requires: containerd.service
├── Wants: docker.socket
├── After: network-online.target
└── Requisite: nvidia-persistenced.service (for GPU containers)
```

**Application Service Dependencies:**
```
archon.service
├── Requires: docker.service
├── After: docker.service
├── Wants: network-online.target
└── Requisite: archon containers + systemd service

ollama.service
├── After: network.target
├── Wants: nvidia-persistenced.service (for GPU)
└── Requires: filesystem access to model storage
```

## Service Monitoring and Alerting

### Automated Service Monitoring

**Create Service Monitor Script:**
```bash
# Create systemd service monitoring script
sudo tee /usr/local/bin/cluster-service-monitor.sh <<'EOF'
#!/bin/bash
# Cluster Service Monitoring Script

LOG_FILE="/var/log/cluster-service-monitor.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Starting service health check" >> $LOG_FILE

# Critical services that must always be running
CRITICAL_SERVICES=("ssh" "NetworkManager" "nfs-client.target" "rpcbind")

# Infrastructure services
INFRA_SERVICES=("docker" "containerd" "nvidia-persistenced")

# Application services
APP_SERVICES=("archon" "ollama")

check_service() {
    local service=$1
    local category=$2

    if systemctl is-active "$service" >/dev/null 2>&1 || systemctl is-active "$service.target" >/dev/null 2>&1; then
        echo "[$DATE] ✅ $category: $service is active" >> $LOG_FILE
        return 0
    else
        echo "[$DATE] ❌ $category: $service is inactive" >> $LOG_FILE
        return 1
    fi
}

# Check critical services
echo "[$DATE] Checking critical services..." >> $LOG_FILE
for service in "${CRITICAL_SERVICES[@]}"; do
    if ! check_service "$service" "CRITICAL"; then
        echo "[$DATE] ALERT: Critical service $service is down!" >> $LOG_FILE
        # Could add notification here
    fi
done

# Check infrastructure services
echo "[$DATE] Checking infrastructure services..." >> $LOG_FILE
for service in "${INFRA_SERVICES[@]}"; do
    check_service "$service" "INFRA"
done

# Check application services
echo "[$DATE] Checking application services..." >> $LOG_FILE
for service in "${APP_SERVICES[@]}"; do
    check_service "$service" "APP"
done

echo "[$DATE] Service health check completed" >> $LOG_FILE
EOF

chmod +x /usr/local/bin/cluster-service-monitor.sh
```

**Create Systemd Timer for Monitoring:**
```bash
# Create systemd timer for regular service monitoring
sudo tee /etc/systemd/system/cluster-service-monitor.timer <<EOF
[Unit]
Description=Cluster Service Monitor Timer
Requires=multi-user.target

[Timer]
OnCalendar=*:0/15  # Every 15 minutes
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo tee /etc/systemd/system/cluster-service-monitor.service <<EOF
[Unit]
Description=Cluster Service Monitor
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/cluster-service-monitor.sh
EOF

# Enable and start the monitoring timer
sudo systemctl enable cluster-service-monitor.timer
sudo systemctl start cluster-service-monitor.timer
```

## Troubleshooting Common Service Issues

### NVIDIA Service Failures

**If nvidia-persistenced fails to start:**
```bash
# Enable persistence mode manually
sudo nvidia-smi -pm 1
sudo systemctl restart nvidia-persistenced.service

# Check for module loading issues
lsmod | grep nvidia
sudo modprobe nvidia

# Check service logs
sudo journalctl -u nvidia-persistenced.service -f
```

### Docker Service Issues

**If Docker fails to start:**
```bash
# Check detailed error
sudo systemctl status docker.service
sudo journalctl -u docker.service -f

# Common fix - clean Docker state
sudo rm -rf /var/lib/docker/tmp/
sudo systemctl restart docker.service

# Check Docker daemon logs
sudo journalctl -u docker.service --since "1 hour ago"
```

### Application Service Dependencies

**If Archon service fails due to missing containers:**
```bash
# Check service status and logs
systemctl status archon.service
sudo journalctl -u archon.service -f

# Restore containers first, then restart service
docker ps --filter "name=archon"
# If containers missing, restore from backup first

# Then restart service
sudo systemctl restart archon.service
```

**If Ollama fails due to GPU access:**
```bash
# Verify GPU access
nvidia-smi

# Restart NVIDIA services
sudo systemctl restart nvidia-persistenced.service

# Restart Ollama service
sudo systemctl restart ollama.service

# Check Ollama logs
sudo journalctl -u ollama.service -f
```

### Emergency Service Recovery

**Critical Service Recovery:**
```bash
# If critical services are accidentally stopped
sudo systemctl start ssh.service NetworkManager.service
sudo systemctl start nfs-client.target rpcbind.service

# Emergency Docker restart for containers
sudo systemctl start docker.service
docker start $(docker ps -aq)

# Emergency NVIDIA recovery
sudo modprobe nvidia
sudo systemctl start nvidia-persistenced.service
```

## Service Configuration Templates

### Chezmoi Service Templates

**Template Variables (.chezmoi.toml.tmpl):**
```toml
[data]
    # Service configuration per node
    {{ if eq .chezmoi.hostname "cooperator" -}}
    has_archon_service = false
    has_ollama_service = false
    has_gpu_services = false
    {{- else if eq .chezmoi.hostname "projector" -}}
    has_archon_service = true
    has_ollama_service = true
    has_gpu_services = true
    {{- else if eq .chezmoi.hostname "director" -}}
    has_archon_service = false
    has_ollama_service = true
    has_gpu_services = true
    {{- end }}

    # Service management aliases
    has_service_management = true
    systemctl_aliases = true
```

**Service Management Aliases (Shell Templates):**
```bash
# In dot_bashrc.tmpl and dot_zshrc.tmpl
{{- if .has_service_management }}
# Service management aliases
alias svc-status='systemctl status'
alias svc-start='sudo systemctl start'
alias svc-stop='sudo systemctl stop'
alias svc-restart='sudo systemctl restart'
alias svc-enable='sudo systemctl enable'
alias svc-disable='sudo systemctl disable'
alias svc-logs='sudo journalctl -u'
alias svc-follow='sudo journalctl -u -f'

# Cluster-specific service aliases
{{- if .has_archon_service }}
alias archon-status='systemctl status archon.service'
alias archon-logs='sudo journalctl -u archon.service -f'
alias archon-restart='sudo systemctl restart archon.service'
{{- end }}

{{- if .has_ollama_service }}
alias ollama-status='systemctl status ollama.service'
alias ollama-logs='sudo journalctl -u ollama.service -f'
alias ollama-restart='sudo systemctl restart ollama.service'
{{- end }}

{{- if .has_gpu_services }}
alias nvidia-status='systemctl status nvidia-persistenced.service'
alias gpu-check='nvidia-smi && systemctl is-active nvidia-persistenced.service'
{{- end }}

# Universal service monitoring
alias cluster-services='/usr/local/bin/cluster-service-monitor.sh'
alias service-health='systemctl list-units --failed'
{{- end }}
```

## Integration with Infrastructure Operations

### Service Management in Infrastructure Reset

**Enhanced Reset Phase Integration:**
```bash
# Phase 2 Enhancement: Complete Removal
# 1. Stop application services
sudo systemctl stop archon.service ollama.service

# 2. Stop GPU services
sudo systemctl stop nvidia-persistenced.service nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service

# 3. Stop Docker services
sudo systemctl stop docker.service docker.socket containerd.service

# 4. Disable all target services
sudo systemctl disable nvidia-persistenced.service docker.service containerd.service archon.service ollama.service

# Then proceed with package removal...
```

**Post-Installation Service Restoration:**
```bash
# Phase 4 Enhancement: Optimal Reinstallation
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

## Conclusion

This service management guide provides:

- **Precise Service Control**: Detailed management procedures for all cluster services
- **Dependency Management**: Understanding of service interdependencies
- **Application Preservation**: Specific procedures for Archon and Ollama services
- **Risk Mitigation**: Emergency recovery procedures for critical services
- **Monitoring Integration**: Automated service health monitoring
- **Template Integration**: Chezmoi-driven service management configurations

The discovery of `archon.service` and `ollama.service` as systemd services (in addition to containers) significantly enhances our understanding of the application stack and ensures complete preservation during infrastructure operations.

**Critical Benefits:**
1. **Enhanced Application Preservation**: Handle both systemd service and containers
2. **Service Dependency Ordering**: Ensure correct start/stop sequences
3. **Health Validation**: Comprehensive service state verification
4. **Template-Driven Management**: Consistent service configuration across nodes

This guide ensures infrastructure operations maintain **100% application functionality** while achieving optimal system configuration and reliability.