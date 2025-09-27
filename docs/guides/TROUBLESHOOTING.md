---
title: "Troubleshooting Guide"
description: "Common issues and solutions for Co-lab cluster components"
version: "1.0"
date: "2025-09-27"
category: "guide"
tags: ["troubleshooting", "debugging", "support", "maintenance"]
applies_to: ["all_nodes"]
related:
  - "SERVICE-MANAGEMENT.md"
  - "INFRASTRUCTURE-RESET.md"
  - "../architecture/HYBRID-STRATEGY.md"
---

# Troubleshooting Guide

## Overview

This guide provides solutions for common issues encountered in the Co-lab cluster environment, covering everything from Chezmoi template problems to GPU access issues and service failures.

## Chezmoi Configuration Issues

### Template Rendering Problems

**Symptoms:**
- Templates not rendering correctly
- Missing environment variables
- Node-specific configurations not applying

**Diagnosis:**
```bash
# Check chezmoi status
chezmoi status

# Verify template data
chezmoi data

# Test template rendering without applying
chezmoi execute-template --init --promptString hostname=$(hostname) < omni-config/.chezmoi.toml.tmpl

# Check for template syntax errors
chezmoi diff
```

**Solutions:**
```bash
# Fix template syntax issues
chezmoi edit --apply ~/.bashrc

# Reinitialize chezmoi if corrupted
chezmoi forget --force
chezmoi init --apply https://github.com/IMUR/colab-config.git

# Update templates from repository
chezmoi update

# Force reapply all templates
chezmoi apply --force
```

### Node Detection Issues

**Symptoms:**
- Wrong node role detected
- GPU flags not set correctly
- Node-specific aliases missing

**Diagnosis:**
```bash
# Check hostname detection
hostname
echo $HOSTNAME

# Verify chezmoi data shows correct node
chezmoi data | grep -E "hostname|node_role|has_gpu"

# Test template variables
chezmoi execute-template '{{ .chezmoi.hostname }}'
chezmoi execute-template '{{ .node_role }}'
```

**Solutions:**
```bash
# Update .chezmoi.toml.tmpl with correct hostname detection
chezmoi edit omni-config/.chezmoi.toml.tmpl

# Verify hostname in system
sudo hostnamectl set-hostname cooperator  # or projector, director

# Reapply configuration
chezmoi apply
```

## GPU and CUDA Issues

### NVIDIA Driver Problems

**Symptoms:**
- `nvidia-smi` command not found
- GPU not detected
- CUDA applications fail

**Diagnosis:**
```bash
# Check if drivers are loaded
lsmod | grep nvidia

# Check PCI devices
lspci | grep -i nvidia

# Check service status
systemctl status nvidia-persistenced.service

# Check driver installation
dpkg -l | grep nvidia
```

**Solutions:**
```bash
# Reload nvidia modules
sudo modprobe nvidia
sudo modprobe nvidia-uvm

# Restart NVIDIA services
sudo systemctl restart nvidia-persistenced.service

# Reinstall drivers if corrupted
sudo apt purge nvidia-*
sudo apt autoremove
sudo apt install nvidia-driver-560

# Reboot after driver changes
sudo reboot
```

### CUDA Environment Issues

**Symptoms:**
- `nvcc` not found
- CUDA libraries not in path
- PyTorch can't find CUDA

**Diagnosis:**
```bash
# Check CUDA installation
nvcc --version
which nvcc

# Check environment variables
echo $CUDA_HOME
echo $LD_LIBRARY_PATH
echo $PATH | tr ':' '\n' | grep cuda

# Test CUDA functionality
python3 -c "import torch; print(torch.cuda.is_available())"
```

**Solutions:**
```bash
# Source profile to load CUDA environment
source ~/.profile

# Manually set CUDA environment
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

# Update dynamic linker
sudo ldconfig

# Reapply chezmoi templates with CUDA support
chezmoi apply
```

### Docker GPU Integration

**Symptoms:**
- `docker run --gpus all` fails
- Containers can't access GPU
- NVIDIA Container Runtime errors

**Diagnosis:**
```bash
# Test Docker GPU access
docker run --rm --gpus all nvidia/cuda:12.6-base-ubuntu20.04 nvidia-smi

# Check Docker daemon configuration
cat /etc/docker/daemon.json

# Check nvidia-container-runtime
which nvidia-container-runtime
```

**Solutions:**
```bash
# Install nvidia-container-toolkit
sudo apt install nvidia-container-toolkit

# Configure Docker daemon
sudo tee /etc/docker/daemon.json <<EOF
{
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "default-runtime": "nvidia"
}
EOF

# Restart Docker
sudo systemctl restart docker

# Test GPU access
docker run --rm --gpus all nvidia/cuda:12.6-base-ubuntu20.04 nvidia-smi
```

## Service Management Issues

### Systemd Service Failures

**Symptoms:**
- Services fail to start
- Services crash unexpectedly
- Dependencies not met

**Diagnosis:**
```bash
# Check service status
systemctl status service-name.service

# View service logs
sudo journalctl -u service-name.service -f

# Check service dependencies
systemctl list-dependencies service-name.service

# Check for failed services
systemctl list-units --failed
```

**Solutions:**
```bash
# Restart failed service
sudo systemctl restart service-name.service

# Reset failed state
sudo systemctl reset-failed

# Reload systemd configuration
sudo systemctl daemon-reload

# Check service file syntax
sudo systemd-analyze verify /etc/systemd/system/service-name.service
```

### Archon Service Issues

**Symptoms:**
- Archon containers not starting
- Database connectivity issues
- API endpoints not responding

**Diagnosis:**
```bash
# Check Archon containers
docker ps --filter "name=archon"

# Check Archon systemd service
systemctl status archon.service

# Check container logs
docker logs archon-server
docker logs archon-mcp
docker logs archon-agents

# Test API endpoints
curl -f http://localhost:8181/health
curl -f http://localhost:8051/health
```

**Solutions:**
```bash
# Restart Archon containers
docker restart $(docker ps --filter "name=archon" -q)

# Restart Archon systemd service
sudo systemctl restart archon.service

# Check database connectivity
docker exec archon_postgres pg_isready -U postgres

# Recreate Archon networks
docker network create archon_app-network
docker network create archon_network

# Full Archon restoration from backup
cd /cluster-nas/backups/archon-preservation-latest/
./restore-archon.sh
```

### Ollama Service Issues

**Symptoms:**
- Ollama service won't start
- GPU not accessible to Ollama
- Model loading failures

**Diagnosis:**
```bash
# Check Ollama service
systemctl status ollama.service

# Check Ollama logs
sudo journalctl -u ollama.service -f

# Test Ollama manually
ollama list
ollama ps

# Check GPU access for Ollama
nvidia-smi
sudo -u ollama nvidia-smi
```

**Solutions:**
```bash
# Restart Ollama service
sudo systemctl restart ollama.service

# Check Ollama user permissions
sudo usermod -aG docker ollama

# Manually start Ollama for testing
sudo -u ollama ollama serve

# Reinstall Ollama if corrupted
curl -fsSL https://ollama.ai/install.sh | sh
```

## Network and Connectivity Issues

### SSH Access Problems

**Symptoms:**
- SSH connections refused
- Key authentication failures
- Connection timeouts

**Diagnosis:**
```bash
# Check SSH service
systemctl status ssh.service

# Test SSH locally
ssh localhost

# Check SSH configuration
sudo sshd -T

# Check firewall rules
sudo iptables -L
```

**Solutions:**
```bash
# Restart SSH service
sudo systemctl restart ssh.service

# Check SSH key permissions
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 700 ~/.ssh/

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Test SSH configuration
sudo sshd -t
```

### NFS Mount Issues

**Symptoms:**
- `/cluster-nas` not mounted
- Permission denied on shared files
- NFS timeouts

**Diagnosis:**
```bash
# Check NFS mount status
df -h | grep cluster-nas
mount | grep nfs

# Check NFS client status
systemctl status nfs-client.target

# Test NFS server accessibility
showmount -e cooperator.ism.la

# Check NFS logs
sudo journalctl -u nfs-client.target
```

**Solutions:**
```bash
# Remount NFS share
sudo umount /cluster-nas
sudo mount -a

# Restart NFS client services
sudo systemctl restart nfs-client.target

# Check and fix permissions
sudo chown -R cluster:cluster /cluster-nas
sudo chmod -R 755 /cluster-nas

# Add to fstab if missing
echo "cooperator.ism.la:/cluster-nas /cluster-nas nfs4 defaults,_netdev 0 0" | sudo tee -a /etc/fstab
```

### DNS Resolution Issues

**Symptoms:**
- Can't resolve .ism.la domains
- Pi-hole not responding
- External DNS queries fail

**Diagnosis:**
```bash
# Test DNS resolution
dig cooperator.ism.la
nslookup projector.ism.la

# Check resolv.conf
cat /etc/resolv.conf

# Test Pi-hole
dig @192.168.254.10 google.com

# Check Pi-hole service
systemctl status pihole-FTL
```

**Solutions:**
```bash
# Restart Pi-hole service (on cooperator)
sudo systemctl restart pihole-FTL

# Fix resolv.conf
echo "nameserver 192.168.254.10" | sudo tee /etc/resolv.conf

# Flush DNS cache
sudo systemctl restart systemd-resolved

# Restart NetworkManager
sudo systemctl restart NetworkManager
```

## Application-Specific Issues

### Claude Code Problems (ARM64)

**Symptoms:**
- Agent discovery not working
- Search functionality disabled
- Terminal interaction issues

**Diagnosis:**
```bash
# Check Claude installation
which claude
claude --version

# Check agent directory
ls -la ~/.claude/agents/

# Test basic functionality
claude help
claude doctor
```

**Solutions:**
```bash
# Fix agent discovery
cp .claude/agents/*.md ~/.claude/agents/
chmod 600 ~/.claude/agents/*.md

# Use alternative search tools
alias search='rg'
alias fuzzy='fzf'

# TTY workarounds for commands
script -q -c "claude doctor" /dev/null

# Downgrade if needed
npm install -g @anthropic-ai/claude-code@0.2.114
```

### Container Issues

**Symptoms:**
- Containers won't start
- Port conflicts
- Volume mount failures

**Diagnosis:**
```bash
# Check container status
docker ps -a

# Check container logs
docker logs container-name

# Check port usage
netstat -tulpn | grep :8181

# Check disk space
df -h
docker system df
```

**Solutions:**
```bash
# Clean up stopped containers
docker container prune

# Clean up unused images
docker image prune

# Clean up volumes
docker volume prune

# Restart Docker service
sudo systemctl restart docker

# Free up disk space
docker system prune -a
```

## Hardware-Specific Issues

### Raspberry Pi (cooperator) Issues

**Symptoms:**
- SD card corruption
- Thermal throttling
- Power supply issues

**Diagnosis:**
```bash
# Check system temperature
vcgencmd measure_temp

# Check throttling status
vcgencmd get_throttled

# Check SD card health
sudo badblocks -v /dev/mmcblk0

# Check power supply
dmesg | grep -i voltage
```

**Solutions:**
```bash
# Enable memory split for GPU
echo "gpu_mem=64" | sudo tee -a /boot/config.txt

# Add cooling configuration
echo "dtparam=act_led_trigger=none" | sudo tee -a /boot/config.txt
echo "dtparam=act_led_activelow=on" | sudo tee -a /boot/config.txt

# Monitor temperature
watch vcgencmd measure_temp

# Consider SD card replacement if errors persist
```

### Multi-GPU Issues (projector)

**Symptoms:**
- Only some GPUs detected
- GPU communication errors
- Performance degradation

**Diagnosis:**
```bash
# Check all GPUs
nvidia-smi -L

# Check GPU topology
nvidia-smi topo -m

# Check GPU memory
nvidia-smi --query-gpu=memory.used,memory.total --format=csv

# Check GPU utilization
nvidia-smi --query-gpu=utilization.gpu --format=csv
```

**Solutions:**
```bash
# Reset GPU state
sudo nvidia-smi -r

# Check PCIe links
nvidia-smi -q | grep -A3 "GPU Link Info"

# Optimize for multi-GPU
export CUDA_DEVICE_ORDER="PCI_BUS_ID"
export NCCL_DEBUG=INFO

# Test GPU communication
python3 -c "
import torch
if torch.cuda.device_count() > 1:
    print(f'GPUs available: {torch.cuda.device_count()}')
    for i in range(torch.cuda.device_count()):
        print(f'GPU {i}: {torch.cuda.get_device_name(i)}')
"
```

## Performance Issues

### High CPU/Memory Usage

**Symptoms:**
- System sluggishness
- Applications being killed
- High load averages

**Diagnosis:**
```bash
# Check system resources
top
htop
free -h

# Check memory usage
ps aux --sort=-%mem | head -10

# Check disk I/O
iotop

# Check system load
uptime
```

**Solutions:**
```bash
# Identify memory hogs
ps aux --sort=-%mem | head -20

# Clean up logs
sudo journalctl --vacuum-time=7d

# Clean temporary files
sudo find /tmp -type f -atime +7 -delete

# Restart heavy services
sudo systemctl restart docker
sudo systemctl restart archon.service
```

### Storage Issues

**Symptoms:**
- Disk full errors
- Docker build failures
- Application crashes

**Diagnosis:**
```bash
# Check disk usage
df -h
du -sh /var/lib/docker
du -sh /cluster-nas

# Check inodes
df -i

# Find large files
find / -size +1G -type f 2>/dev/null
```

**Solutions:**
```bash
# Clean Docker system
docker system prune -a --volumes

# Clean package cache
sudo apt clean
sudo apt autoremove

# Clean logs
sudo journalctl --vacuum-size=100M

# Move large files to cluster storage
mv /home/user/large-file /cluster-nas/storage/
```

## General Diagnostic Tools

### Health Check Scripts

**System Health Check:**
```bash
#!/bin/bash
# /usr/local/bin/system-health-check.sh

echo "=== System Health Check - $(date) ==="

# System basics
echo "Uptime: $(uptime)"
echo "Load: $(cat /proc/loadavg)"
echo "Memory: $(free -h | grep '^Mem' | awk '{print $3"/"$2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $5}')"

# Services
echo "SSH: $(systemctl is-active ssh.service)"
echo "Docker: $(systemctl is-active docker.service)"
echo "NFS: $(systemctl is-active nfs-client.target)"

# GPU (if applicable)
if command -v nvidia-smi >/dev/null; then
    echo "GPU: $(nvidia-smi -L | wc -l) detected"
    echo "NVIDIA Service: $(systemctl is-active nvidia-persistenced.service)"
fi

# Chezmoi
echo "Chezmoi: $(chezmoi status | wc -l) pending changes"

echo "=== Health Check Complete ==="
```

**Network Connectivity Check:**
```bash
#!/bin/bash
# /usr/local/bin/network-health-check.sh

echo "=== Network Health Check - $(date) ==="

# Internal connectivity
for node in cooperator projector director; do
    if ping -c 1 ${node}.ism.la >/dev/null 2>&1; then
        echo "✅ $node.ism.la: reachable"
    else
        echo "❌ $node.ism.la: unreachable"
    fi
done

# DNS resolution
if dig @192.168.254.10 google.com >/dev/null 2>&1; then
    echo "✅ DNS: working"
else
    echo "❌ DNS: failing"
fi

# NFS connectivity
if showmount -e cooperator.ism.la >/dev/null 2>&1; then
    echo "✅ NFS: accessible"
else
    echo "❌ NFS: inaccessible"
fi

echo "=== Network Check Complete ==="
```

## Getting Help

### Log Collection

When reporting issues, collect these logs:
```bash
# System logs
sudo journalctl --since "1 hour ago" > system-logs.txt

# Service-specific logs
sudo journalctl -u docker.service --since "1 hour ago" > docker-logs.txt
sudo journalctl -u archon.service --since "1 hour ago" > archon-logs.txt

# Chezmoi status
chezmoi status > chezmoi-status.txt
chezmoi data > chezmoi-data.txt

# System information
uname -a > system-info.txt
lscpu >> system-info.txt
free -h >> system-info.txt
df -h >> system-info.txt
```

### Emergency Contacts and Resources

**Internal Resources:**
- Cluster documentation: `/cluster-nas/colab/colab-config/docs/`
- Backup configurations: `/cluster-nas/backups/`
- Service logs: `/var/log/` and `journalctl`

**External Resources:**
- Chezmoi documentation: https://www.chezmoi.io/
- Docker documentation: https://docs.docker.com/
- NVIDIA documentation: https://docs.nvidia.com/

Remember: When in doubt, check the service logs first. Most issues leave clear traces in the systemd journal that can guide you to the root cause and solution.