---
title: "Command Reference"
description: "Comprehensive command reference for Co-lab cluster operations"
version: "1.0"
date: "2025-09-27"
category: "reference"
tags: ["commands", "cli", "reference", "cheat-sheet"]
applies_to: ["all_nodes"]
related:
  - "VARIABLES.md"
  - "TEMPLATES.md"
  - "../guides/SERVICE-MANAGEMENT.md"
---

# Command Reference

## Chezmoi Commands

### Basic Operations

**Initialize and apply configuration:**
```bash
# Initialize chezmoi with repository
chezmoi init --apply https://github.com/IMUR/colab-config.git

# Apply latest changes
chezmoi apply

# Apply with force (overwrite local changes)
chezmoi apply --force

# Show what would change without applying
chezmoi diff

# Update from remote repository
chezmoi update
```

**Status and Information:**
```bash
# Check status of managed files
chezmoi status

# List all managed files
chezmoi managed

# Show chezmoi data variables
chezmoi data

# Show source directory path
chezmoi source-path

# Show target directory path (usually $HOME)
chezmoi target-path
```

**Template Operations:**
```bash
# Execute a template without applying
chezmoi execute-template '{{ .chezmoi.hostname }}'

# Test template rendering
chezmoi execute-template --init --promptString hostname=testnode < omni-config/.chezmoi.toml.tmpl

# Edit and apply a file
chezmoi edit --apply ~/.bashrc

# Add a new file to chezmoi management
chezmoi add ~/.new-config-file
```

**Advanced Operations:**
```bash
# Forget chezmoi management (remove all)
chezmoi forget --force

# Remove chezmoi and all managed files
chezmoi purge

# Verify integrity of managed files
chezmoi verify

# Show difference for specific file
chezmoi diff ~/.bashrc

# Cat the managed version of a file
chezmoi cat ~/.bashrc
```

## Docker Commands

### Container Management

**Basic Container Operations:**
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Start a container
docker start container-name

# Stop a container
docker stop container-name

# Restart a container
docker restart container-name

# Remove a container
docker rm container-name

# Remove all stopped containers
docker container prune
```

**Container Inspection:**
```bash
# View container logs
docker logs container-name

# Follow container logs in real-time
docker logs -f container-name

# Show last 50 lines of logs
docker logs --tail 50 container-name

# Execute command in running container
docker exec -it container-name bash

# Inspect container configuration
docker inspect container-name

# Show container resource usage
docker stats container-name
```

**Archon-Specific Commands:**
```bash
# Check Archon container status
docker ps --filter "name=archon" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# View Archon server logs
docker logs -f archon-server

# Restart all Archon containers
docker restart $(docker ps --filter "name=archon" -q)

# Enter Archon database container
docker exec -it archon_postgres psql -U postgres

# Check Archon health endpoints
curl -f http://localhost:8181/health  # Server
curl -f http://localhost:8051/health  # MCP
curl -f http://localhost:8052/health  # Agents
```

### Image Management

**Image Operations:**
```bash
# List images
docker images

# Pull an image
docker pull image:tag

# Remove an image
docker rmi image:tag

# Remove unused images
docker image prune

# Build an image
docker build -t image-name .

# Save image to file
docker save image:tag | gzip > image.tar.gz

# Load image from file
docker load < image.tar.gz
```

### GPU-Specific Commands

**GPU Container Operations:**
```bash
# Run container with GPU access
docker run --gpus all nvidia/cuda:12.6-base-ubuntu20.04 nvidia-smi

# Run interactive container with GPU
docker run -it --rm --gpus all nvidia/cuda:12.6-base-ubuntu20.04 bash

# Test specific GPU
docker run --rm --gpus device=0 nvidia/cuda:12.6-base-ubuntu20.04 nvidia-smi

# Run with all capabilities
docker run --rm --gpus all --cap-add=SYS_ADMIN nvidia/cuda:12.6-base-ubuntu20.04 nvidia-smi
```

## Docker Compose Commands

### Service Management

**Basic Compose Operations:**
```bash
# Start services in background
docker compose up -d

# Start specific service
docker compose up -d service-name

# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v

# View running services
docker compose ps

# View service logs
docker compose logs service-name

# Follow logs for all services
docker compose logs -f
```

**Archon Compose Operations:**
```bash
# Navigate to Archon directory
cd /opt/archon

# Start Archon stack
docker compose up -d

# Check Archon services
docker compose ps

# View Archon logs
docker compose logs -f

# Restart specific Archon service
docker compose restart archon-server

# Scale a service (if supported)
docker compose scale archon-agents=2
```

## NVIDIA/CUDA Commands

### GPU Monitoring

**Basic GPU Information:**
```bash
# Show GPU status
nvidia-smi

# List all GPUs
nvidia-smi -L

# Query specific GPU information
nvidia-smi --query-gpu=name,memory.total,memory.used --format=csv

# Show GPU utilization
nvidia-smi --query-gpu=utilization.gpu,utilization.memory --format=csv

# Show GPU temperature
nvidia-smi --query-gpu=temperature.gpu --format=csv

# Show power consumption
nvidia-smi --query-gpu=power.draw,power.limit --format=csv
```

**Continuous Monitoring:**
```bash
# Watch GPU status (refresh every 1 second)
watch -n 1 nvidia-smi

# Monitor specific metrics
nvidia-smi --query-gpu=utilization.gpu,memory.used --format=csv -l 1

# Log GPU metrics to file
nvidia-smi --query-gpu=timestamp,name,utilization.gpu,memory.used --format=csv -l 60 > gpu-metrics.csv
```

**GPU Configuration:**
```bash
# Enable persistence mode
sudo nvidia-smi -pm 1

# Set power limit (adjust for your GPU)
sudo nvidia-smi -pl 200

# Reset GPU
sudo nvidia-smi -r

# Set application clocks
sudo nvidia-smi -ac 4004,1911  # memory,graphics clocks for GTX 1080
```

### CUDA Development

**CUDA Compiler:**
```bash
# Check CUDA version
nvcc --version

# Compile CUDA program
nvcc -o program program.cu

# Compile with optimization
nvcc -O3 -arch=sm_61 -o program program.cu

# Show CUDA device properties
nvidia-smi --query-gpu=compute_cap --format=csv
```

**CUDA Environment:**
```bash
# Check CUDA environment variables
echo $CUDA_HOME
echo $LD_LIBRARY_PATH
echo $PATH | grep cuda

# Test CUDA installation
/usr/local/cuda/extras/demo_suite/deviceQuery

# Test bandwidth
/usr/local/cuda/extras/demo_suite/bandwidthTest
```

### Multi-GPU Commands (projector)

**Multi-GPU Operations:**
```bash
# Show GPU topology
nvidia-smi topo -m

# Show detailed GPU information
nvidia-smi -q

# Set GPU to exclusive mode
sudo nvidia-smi -c 3 -i 0  # Set GPU 0 to exclusive

# Query all GPUs
nvidia-smi --query-gpu=index,name,utilization.gpu --format=csv

# Reset all GPUs
sudo nvidia-smi -r
```

## Systemd Service Commands

### Service Management

**Basic Service Operations:**
```bash
# Check service status
systemctl status service-name

# Start a service
sudo systemctl start service-name

# Stop a service
sudo systemctl stop service-name

# Restart a service
sudo systemctl restart service-name

# Reload service configuration
sudo systemctl reload service-name

# Enable service at boot
sudo systemctl enable service-name

# Disable service at boot
sudo systemctl disable service-name
```

**Service Information:**
```bash
# List all services
systemctl list-units --type=service

# List failed services
systemctl list-units --failed

# Show service dependencies
systemctl list-dependencies service-name

# Show service properties
systemctl show service-name

# Check if service is active
systemctl is-active service-name

# Check if service is enabled
systemctl is-enabled service-name
```

### Application Services

**Archon Service:**
```bash
# Check Archon systemd service
systemctl status archon.service

# Start Archon service
sudo systemctl start archon.service

# View Archon service logs
sudo journalctl -u archon.service -f

# Restart Archon service
sudo systemctl restart archon.service
```

**Ollama Service:**
```bash
# Check Ollama service
systemctl status ollama.service

# View Ollama logs
sudo journalctl -u ollama.service -f

# Restart Ollama
sudo systemctl restart ollama.service
```

**Infrastructure Services:**
```bash
# Docker service
systemctl status docker.service
sudo systemctl restart docker.service

# NVIDIA persistence
systemctl status nvidia-persistenced.service
sudo systemctl restart nvidia-persistenced.service

# SSH service
systemctl status ssh.service
sudo systemctl restart ssh.service
```

## Network Commands

### Basic Network Operations

**Connectivity Testing:**
```bash
# Test connectivity to node
ping cooperator.ism.la
ping projector.ism.la
ping director.ism.la

# Test specific port
nc -zv projector.ism.la 8181

# Test HTTP endpoint
curl -I http://archon.ism.la

# Test HTTPS endpoint
curl -k -I https://archon.ism.la
```

**DNS Operations:**
```bash
# Query DNS
dig cooperator.ism.la
nslookup projector.ism.la

# Query specific DNS server
dig @192.168.254.10 google.com

# Reverse DNS lookup
dig -x 192.168.254.20

# Query specific record type
dig MX google.com
dig AAAA google.com
```

### Network Diagnostics

**Interface Information:**
```bash
# Show network interfaces
ip addr show
ifconfig

# Show routing table
ip route show
route -n

# Show network statistics
netstat -i
ss -i
```

**Port and Connection Information:**
```bash
# Show listening ports
netstat -tulpn
ss -tulpn

# Show established connections
netstat -tupln
ss -tupln

# Show connections to specific port
netstat -an | grep :8181
ss -an | grep :8181
```

## NFS Commands

### NFS Client Operations

**Mount Operations:**
```bash
# Check NFS mounts
mount | grep nfs
df -t nfs4

# Mount NFS share
sudo mount -t nfs4 cooperator.ism.la:/cluster-nas /cluster-nas

# Unmount NFS share
sudo umount /cluster-nas

# Remount all NFS shares
sudo mount -a

# Show NFS mount options
mount | grep cluster-nas
```

**NFS Diagnostics:**
```bash
# Show available exports
showmount -e cooperator.ism.la

# Show mount information
showmount -m cooperator.ism.la

# Test NFS connectivity
rpcinfo -p cooperator.ism.la

# Show NFS statistics
nfsstat -c  # client stats
nfsstat -s  # server stats (on cooperator)
```

## Cluster Management Commands

### Ansible Operations

**Basic Ansible Commands:**
```bash
# Test connectivity to all nodes
ansible all -m ping

# Run command on all nodes
ansible all -a "uptime"

# Run command on specific group
ansible compute -a "nvidia-smi -L"

# Gather facts from all nodes
ansible all -m setup

# Run playbook
ansible-playbook playbooks/cluster-health.yml

# Run playbook with check mode
ansible-playbook --check playbooks/cluster-health.yml
```

**Inventory Management:**
```bash
# List inventory
ansible-inventory --list

# Show specific host information
ansible-inventory --host cooperator

# Validate inventory
ansible-inventory --list --yaml

# Graph inventory relationships
ansible-inventory --graph
```

### SSH and Remote Operations

**SSH Operations:**
```bash
# SSH to cluster nodes
ssh cooperator.ism.la
ssh projector.ism.la
ssh director.ism.la

# SSH with specific key
ssh -i ~/.ssh/id_ed25519 user@cooperator.ism.la

# SSH jump host pattern
ssh -J user@cooperator.external.ip user@projector.ism.la

# Run command via SSH
ssh projector.ism.la "nvidia-smi"

# Copy files via SSH
scp file.txt projector.ism.la:/tmp/
rsync -av directory/ projector.ism.la:/backup/
```

**Cluster-wide Operations:**
```bash
# Check all nodes status
for node in crtr prtr drtr; do
    echo "=== $node ==="
    ssh $node "uptime; free -h"
done

# Update all nodes
for node in crtr prtr drtr; do
    ssh $node "sudo apt update && sudo apt upgrade -y"
done

# Restart service on all compute nodes
for node in prtr drtr; do
    ssh $node "sudo systemctl restart ollama.service"
done
```

## Monitoring Commands

### System Monitoring

**Resource Monitoring:**
```bash
# System overview
top
htop

# Memory usage
free -h
cat /proc/meminfo

# CPU information
lscpu
cat /proc/cpuinfo

# Disk usage
df -h
du -sh /var/lib/docker

# Process monitoring
ps aux --sort=-%mem | head -10
ps aux --sort=-%cpu | head -10
```

**Log Monitoring:**
```bash
# System logs
sudo journalctl -f

# Service logs
sudo journalctl -u docker.service -f
sudo journalctl -u archon.service -f

# Kernel messages
dmesg
dmesg -T

# Boot logs
sudo journalctl -b

# Log size management
sudo journalctl --vacuum-time=7d
sudo journalctl --vacuum-size=100M
```

### Application Monitoring

**Docker Monitoring:**
```bash
# Container resource usage
docker stats

# System-wide Docker info
docker system df
docker system info

# Container health
docker inspect container-name | grep -A5 Health

# Docker events
docker events
```

**Archon Monitoring:**
```bash
# Archon health check script
/usr/local/bin/archon-health-check.sh

# Manual health checks
curl -f http://localhost:8181/health
curl -f http://localhost:8051/health
curl -f http://localhost:8052/health

# Database health
docker exec archon_postgres pg_isready -U postgres
```

## Backup and Recovery Commands

### Backup Operations

**Configuration Backup:**
```bash
# Backup chezmoi source
tar czf chezmoi-backup-$(date +%Y%m%d).tar.gz -C ~/.local/share/chezmoi .

# Backup system configs
sudo tar czf system-configs-$(date +%Y%m%d).tar.gz /etc/

# Backup Docker volumes
docker run --rm -v volume-name:/source -v $(pwd):/backup alpine tar czf /backup/volume-backup.tar.gz -C /source .
```

**Archon Backup:**
```bash
# Full Archon backup (as shown in procedures)
cd /cluster-nas/backups/archon-preservation-$(date +%Y%m%d-%H%M%S)

# Save images
docker save $(docker images --filter "name=archon" --format "{{.Repository}}:{{.Tag}}") | gzip > archon-images.tar.gz

# Backup database
docker exec archon_postgres pg_dumpall -U postgres > archon-database.sql

# Backup volumes
docker run --rm -v archon-supabase_postgres_data:/source:ro -v $(pwd):/backup alpine tar czf /backup/archon-postgres-volume.tar.gz -C /source .
```

### Recovery Operations

**System Recovery:**
```bash
# Restore chezmoi
chezmoi forget --force
chezmoi init --apply https://github.com/IMUR/colab-config.git

# Restore from backup
tar xzf chezmoi-backup.tar.gz -C ~/.local/share/chezmoi

# Emergency service restart
sudo systemctl restart ssh.service
sudo systemctl restart docker.service
sudo systemctl restart nginx.service
```

## Utility Commands

### File Operations

**Text Processing:**
```bash
# Search in files
grep -r "pattern" /path/
rg "pattern" /path/

# Find files
find /path -name "*.log" -type f
fd "*.log" /path

# Directory listing
ls -la
eza -la  # modern replacement

# File viewing
cat file.txt
bat file.txt  # syntax highlighted
less file.txt
```

**Archive Operations:**
```bash
# Create archive
tar czf archive.tar.gz directory/

# Extract archive
tar xzf archive.tar.gz

# List archive contents
tar tzf archive.tar.gz

# Zip operations
zip -r archive.zip directory/
unzip archive.zip
```

### Performance Testing

**Network Performance:**
```bash
# Network bandwidth test
iperf3 -s  # server
iperf3 -c server-ip  # client

# Network latency
ping -c 10 target-host

# HTTP performance
curl -w "@curl-format.txt" -o /dev/null -s "http://example.com"
```

**Disk Performance:**
```bash
# Disk speed test
dd if=/dev/zero of=/tmp/testfile bs=1G count=1 oflag=direct

# Random I/O test
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=randrw --rwmixread=75
```

This command reference provides a comprehensive collection of the most commonly used commands in the Co-lab cluster environment. Each section includes both basic operations and advanced usage patterns specific to the cluster's configuration and services.