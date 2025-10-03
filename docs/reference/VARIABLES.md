---
title: "Variables Reference"
description: "Configuration variables and template parameters for Co-lab cluster"
version: "1.0"
date: "2025-09-27"
category: "reference"
tags: ["variables", "configuration", "templates", "environment"]
applies_to: ["all_nodes"]
related:
  - "TEMPLATES.md"
  - "COMMANDS.md"
  - "../architecture/HYBRID-STRATEGY.md"
---

# Variables Reference

## Chezmoi Template Variables

### Node Identification Variables

**Basic Node Information:**
```toml
# From .chezmoi.toml.tmpl
[data]
    # Core node identification
    hostname = "{{ .chezmoi.hostname }}"      # cooperator, projector, director
    node_role = "gateway|compute|ml_platform" # Role-based classification
    cluster_member = true                     # All nodes are cluster members
```

**Node-Specific Detection:**
```toml
# Cooperator (crtr) - Gateway Node
{{ if eq .chezmoi.hostname "cooperator" -}}
node_role = "gateway"
has_gpu = false
has_nfs_server = true
has_dns_server = true
is_gateway = true
external_access = true
{{- end }}

# Projector (prtr) - Compute Node
{{ if eq .chezmoi.hostname "projector" -}}
node_role = "compute"
has_gpu = true
gpu_count = 4
gpu_architecture = "multi_gpu"
has_archon_service = true
has_ollama_service = true
{{- end }}

# Director (drtr) - ML Platform Node
{{ if eq .chezmoi.hostname "director" -}}
node_role = "ml_platform"
has_gpu = true
gpu_count = 1
gpu_architecture = "single_gpu"
has_ollama_service = true
{{- end }}
```

### Hardware Capability Variables

**GPU and CUDA Configuration:**
```toml
# GPU presence and configuration
has_gpu = true|false                    # GPU hardware present
has_cuda_runtime = true|false          # CUDA runtime installed
has_cuda_toolkit = true|false          # CUDA development tools
cuda_version = "12.6"                  # CUDA version string
cuda_home = "/usr/local/cuda"          # CUDA installation path
gpu_architecture = "multi_gpu|single_gpu|none"  # GPU configuration type

# GPU-specific flags
supports_vllm = true|false             # vLLM inference support
supports_llama_cpp = true|false        # llama.cpp support
supports_pytorch_cuda = true|false     # PyTorch CUDA support
```

**Container and Docker:**
```toml
# Docker configuration
has_docker = true|false                # Docker installed
has_nvidia_container = true|false     # NVIDIA container runtime
docker_gpu_support = true|false       # GPU access in containers
```

### Network Configuration Variables

**Network Settings:**
```toml
# Node network configuration
node_ip = "192.168.254.10|20|30"      # Static IP address per node
cluster_subnet = "192.168.254.0/24"   # Cluster network subnet
cluster_domain = "ism.la"             # Internal domain
dns_server = "192.168.254.10"         # DNS server (cooperator)
nfs_server = "192.168.254.10"         # NFS server (cooperator)
gateway_ip = "192.168.254.10"         # Gateway (cooperator)
```

**Service Network Flags:**
```toml
# Network service capabilities
has_dns_server = true|false           # Pi-hole DNS server
has_nfs_server = true|false           # NFS server capability
is_gateway = true|false               # Internet gateway role
external_access = true|false          # Direct external connectivity
```

### Tool and Application Variables

**Development Tools:**
```toml
# Modern CLI tools
has_modern_shell = true               # Enhanced shell environment
uses_starship = true                  # Starship prompt
has_nvm = true                        # Node Version Manager
uses_uv = true                        # Python package manager

# Tool detection flags
HAS_EZA = true|false                  # Modern ls replacement
HAS_BAT = true|false                  # Syntax highlighting cat
HAS_FZF = true|false                  # Fuzzy finder
HAS_ZOXIDE = true|false               # Smart cd replacement
HAS_ATUIN = true|false                # Shell history
```

**Python Environment:**
```toml
# Python and UV configuration
uses_uv = true                        # UV package manager
python_gpu_package_index = "https://download.pytorch.org/whl/cu126"  # GPU packages
```

### Service Management Variables

**Application Services:**
```toml
# Service presence flags
has_archon_service = true|false       # Archon systemd service
has_ollama_service = true|false       # Ollama systemd service
has_service_management = true         # Service management aliases
systemctl_aliases = true             # Systemd convenience aliases
```

**Infrastructure Services:**
```toml
# Infrastructure capabilities
has_gpu_services = true|false         # NVIDIA services
has_container_services = true         # Docker/containerd
has_monitoring = true|false           # Monitoring services
```

## Environment Variables

### System Environment Variables

**Cluster Identification:**
```bash
# Set by system configuration
export CLUSTER_NODE="cooperator|projector|director"  # Node identifier
export NODE_ROLE="gateway|compute|ml_platform"       # Role classification
export CLUSTER_SUBNET="192.168.254.0/24"            # Network subnet
export CLUSTER_DOMAIN="ism.la"                      # Internal domain
```

**Path Configuration:**
```bash
# Standard path additions
export PATH="/usr/local/bin:~/.local/bin:$PATH"     # Local binaries
export PATH="~/.local/share/nvim/bin:$PATH"         # Neovim tools (if installed)

# Node-specific paths (template-driven)
{{- if .has_cuda_toolkit }}
export PATH="{{ .cuda_home }}/bin:$PATH"            # CUDA binaries
{{- end }}
```

### GPU and CUDA Environment Variables

**CUDA Environment:**
```bash
# CUDA configuration (GPU nodes only)
export CUDA_HOME="/usr/local/cuda"                  # CUDA installation
export CUDA_VERSION="12.6"                          # CUDA version
export CUDA_INCLUDE_PATH="/usr/local/cuda/include"  # CUDA headers
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"  # CUDA libraries
export CPATH="/usr/local/cuda/include:$CPATH"       # Compilation includes
```

**NVIDIA Container Runtime:**
```bash
# Container GPU access
export NVIDIA_VISIBLE_DEVICES="all"                 # All GPUs visible
export NVIDIA_DRIVER_CAPABILITIES="compute,utility,graphics"  # GPU capabilities
```

**GPU Optimization:**
```bash
# Multi-GPU optimization (projector)
export CUDA_DEVICE_ORDER="PCI_BUS_ID"              # Consistent GPU ordering
export NCCL_DEBUG="INFO"                           # NCCL debugging
export OMP_NUM_THREADS="8"                         # OpenMP threads

# Single GPU optimization (director)
export CUDA_DEVICE_ORDER="FASTEST_FIRST"           # Performance ordering
export OMP_NUM_THREADS="4"                         # Fewer threads
```

### Development Environment Variables

**Node.js and NVM:**
```bash
# NVM configuration
export NVM_DIR="$HOME/.nvm"                        # NVM directory
# NVM loading handled by templates

# System Node.js (for tools)
export NODE_PATH="/usr/lib/node_modules"           # System modules
```

**Python and UV:**
```bash
# UV package manager
export UV_EXTRA_INDEX_URL="https://download.pytorch.org/whl/cu126"  # GPU packages
export UV_CUDA_VERSION="12.6"                      # CUDA version for UV
```

**Docker Environment:**
```bash
# Docker configuration
export DOCKER_BUILDKIT="1"                         # Enable BuildKit
export COMPOSE_DOCKER_CLI_BUILD="1"                # Use Docker CLI for builds

# GPU nodes only
{{- if .has_nvidia_container }}
export DOCKER_DEFAULT_RUNTIME="nvidia"             # Default to GPU runtime
{{- end }}
```

### Service-Specific Variables

**Archon Configuration:**
```bash
# Archon service environment (projector)
export ARCHON_HOME="/opt/archon"                   # Archon installation
export ARCHON_DATA="/var/lib/archon"               # Archon data directory
export ARCHON_LOGS="/var/log/archon"               # Archon logs
```

**Ollama Configuration:**
```bash
# Ollama service environment
export OLLAMA_HOME="/var/lib/ollama"               # Ollama data
export OLLAMA_MODELS="/var/lib/ollama/models"      # Model storage
export OLLAMA_HOST="0.0.0.0:11434"                # Ollama server binding
```

## Template Data Structure

### Complete Data Schema

**Full .chezmoi.toml.tmpl data structure:**
```toml
[data]
    # Node identification
    hostname = "{{ .chezmoi.hostname }}"
    node_role = "gateway|compute|ml_platform"
    cluster_member = true

    # Network configuration
    node_ip = "192.168.254.10|20|30"
    cluster_subnet = "192.168.254.0/24"
    cluster_domain = "ism.la"
    dns_server = "192.168.254.10"
    nfs_server = "192.168.254.10"
    gateway_ip = "192.168.254.10"

    # Hardware capabilities
    has_gpu = true|false
    has_cuda_runtime = true|false
    has_cuda_toolkit = true|false
    cuda_version = "12.6"
    cuda_home = "/usr/local/cuda"
    gpu_architecture = "multi_gpu|single_gpu|none"
    gpu_count = 1|4|0

    # Service capabilities
    has_docker = true|false
    has_nvidia_container = true|false
    docker_gpu_support = true|false
    has_archon_service = true|false
    has_ollama_service = true|false

    # Network services
    has_dns_server = true|false
    has_nfs_server = true|false
    is_gateway = true|false
    external_access = true|false

    # Development tools
    has_modern_shell = true
    uses_starship = true
    has_nvm = true
    uses_uv = true

    # Tool detection
    HAS_EZA = true|false
    HAS_BAT = true|false
    HAS_FZF = true|false
    HAS_ZOXIDE = true|false
    HAS_ATUIN = true|false

    # Python configuration
    python_gpu_package_index = "https://download.pytorch.org/whl/cu126"

    # Infrastructure support
    supports_vllm = true|false
    supports_llama_cpp = true|false
    supports_pytorch_cuda = true|false

    # Service management
    has_service_management = true
    systemctl_aliases = true
    has_gpu_services = true|false
    has_monitoring = true|false
```

### Variable Usage in Templates

**Conditional Configuration Loading:**
```bash
# In dot_profile.tmpl
{{- if .has_gpu }}
# GPU environment configuration
if [ -d "{{ .cuda_home }}" ]; then
    export CUDA_HOME="{{ .cuda_home }}"
    export PATH="$CUDA_HOME/bin:$PATH"
    export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"
fi
{{- end }}

{{- if .has_docker }}
# Docker environment
export DOCKER_BUILDKIT=1
{{- if .has_nvidia_container }}
export DOCKER_DEFAULT_RUNTIME=nvidia
{{- end }}
{{- end }}
```

**Tool Detection and Aliases:**
```bash
# In shell RC templates
{{- if .HAS_EZA }}
alias ls='eza'
alias ll='eza -la'
alias tree='eza --tree'
{{- end }}

{{- if .has_gpu }}
alias gpus='nvidia-smi'
alias gpu-watch='watch -n 1 nvidia-smi'
{{- if eq .gpu_count 4 }}
alias gpu-topology='nvidia-smi topo -m'
{{- end }}
{{- end }}
```

**Service-Specific Configuration:**
```bash
# Service management aliases based on node role
{{- if .has_archon_service }}
alias archon-status='systemctl status archon.service'
alias archon-logs='sudo journalctl -u archon.service -f'
alias archon-restart='sudo systemctl restart archon.service'
{{- end }}

{{- if .has_ollama_service }}
alias ollama-status='systemctl status ollama.service'
alias ollama-logs='sudo journalctl -u ollama.service -f'
{{- end }}

{{- if .is_gateway }}
alias check-dns='dig @localhost example.com'
alias pihole-status='systemctl status pihole-FTL'
{{- end }}
```

## Configuration File Variables

### Ansible Variables

**Host Variables (node-configs/):**
```yaml
# crtr-config/host_vars.yml
node_role: gateway
has_gpu: false
services:
  - pihole
  - nfs-server
  - caddy

# prtr-config/host_vars.yml
node_role: compute
has_gpu: true
gpu_count: 4
services:
  - archon
  - ollama
  - docker

# drtr-config/host_vars.yml
node_role: ml_platform
has_gpu: true
gpu_count: 1
services:
  - ollama
  - jupyter
```

**Group Variables:**
```yaml
# group_vars/all.yml
cluster_subnet: "192.168.254.0/24"
cluster_domain: "ism.la"
nfs_server: "192.168.254.10"
dns_server: "192.168.254.10"

# group_vars/gpu_nodes.yml
cuda_version: "12.6"
cuda_home: "/usr/local/cuda"
nvidia_driver_version: "560"
docker_gpu_runtime: true
```

### Docker Compose Variables

**Environment Variables:**
```yaml
# docker-compose.yml environment section
environment:
  - CUDA_VISIBLE_DEVICES=all
  - NVIDIA_VISIBLE_DEVICES=all
  - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
  - ARCHON_GPU_SUPPORT=true
  - NODE_ENV=production
```

### Service Configuration Variables

**Systemd Environment:**
```ini
# /etc/systemd/system/archon.service
[Service]
Environment="CUDA_VISIBLE_DEVICES=all"
Environment="ARCHON_HOME=/opt/archon"
Environment="ARCHON_GPU=true"
```

## Path Variables

### Standard Path Hierarchy

**System Paths:**
```bash
# Standard system paths
/usr/local/bin                        # Local system binaries
/usr/bin                              # System binaries
/bin                                  # Essential binaries

# User paths
~/.local/bin                          # User local binaries
~/.local/share                        # User application data

# Cluster-specific paths
/cluster-nas                          # Shared cluster storage
/cluster-nas/configs                  # Shared configurations
/cluster-nas/backups                  # Cluster backups
```

**CUDA Paths:**
```bash
# CUDA installation (GPU nodes)
/usr/local/cuda                       # CUDA installation root
/usr/local/cuda/bin                   # CUDA binaries (nvcc, etc.)
/usr/local/cuda/lib64                 # CUDA libraries
/usr/local/cuda/include               # CUDA headers
```

**Application Paths:**
```bash
# Application installations
/opt/archon                           # Archon installation
/var/lib/ollama                       # Ollama data
/var/lib/docker                       # Docker data
/etc/docker                           # Docker configuration

# Logs
/var/log/archon                       # Archon logs
/var/log/docker                       # Docker logs (journal)
```

### Template Path Variables

**Repository Structure Paths:**
```toml
# Repository organization (post-restructure)
docs_path = "/cluster-nas/colab/colab-config/docs"
deployment_scripts = "/cluster-nas/colab/colab-config/deployment/scripts"
system_ansible = "/cluster-nas/colab/colab-config/system-ansible"
node_config_path = "/cluster-nas/colab/colab-config/node-configs/{{ .hostname }}-config"
```

## Variable Validation

### Template Validation

**Verify Template Variables:**
```bash
# Check all template data
chezmoi data

# Check specific variables
chezmoi data | jq '.has_gpu'
chezmoi data | jq '.node_role'
chezmoi data | jq '.cuda_home'

# Test template rendering
chezmoi execute-template '{{ .node_role }}'
chezmoi execute-template '{{ if .has_gpu }}GPU node{{ else }}No GPU{{ end }}'
```

### Environment Validation

**Check Environment Variables:**
```bash
# GPU environment (GPU nodes)
echo $CUDA_HOME
echo $LD_LIBRARY_PATH | tr ':' '\n' | grep cuda
echo $PATH | tr ':' '\n' | grep cuda

# Docker environment
echo $DOCKER_BUILDKIT
echo $DOCKER_DEFAULT_RUNTIME

# Tool detection
command -v eza && echo "HAS_EZA=true" || echo "HAS_EZA=false"
command -v bat && echo "HAS_BAT=true" || echo "HAS_BAT=false"
```

This comprehensive variable reference provides the foundation for understanding and customizing the Co-lab cluster configuration through templates and environment variables.