# NVIDIA/CUDA Implementation Strategy for Co-lab Cluster

**Document Version**: 1.0
**Date**: September 2025
**Scope**: Production GPU compute infrastructure for Co-lab cluster
**Focus**: Node-specific installations with chezmoi configuration management

---

## Executive Summary

This document outlines the comprehensive strategy for implementing a unified, production-ready NVIDIA/CUDA stack across the Co-lab cluster's GPU-enabled nodes (projector, director). The approach prioritizes **clean installation**, **performance optimization**, and **configuration unification** through the existing chezmoi-based infrastructure management system.

### Key Objectives

1. **Performance-First**: Optimize for inference workloads (Ollama, vLLM, llama.cpp)
2. **Configuration Unification**: Standardize NVIDIA/CUDA setup across GPU nodes
3. **Future-Proof**: Modern stack that supports 5+ years of ML/AI workloads
4. **Chezmoi Integration**: Node-specific configurations managed through templates
5. **Bare-Metal Optimization**: Direct GPU access without virtualization overhead

---

## Current State Assessment

### Hardware Configuration
- **projector (prtr)**: 4x GPU (2x GTX 1080, 2x GTX 970) - Compute node
- **director (drtr)**: 1x GPU - ML platform node
- **cooperator (crtr)**: No GPU - Gateway node

### Current Issues
- **Fragmented Installation**: Mix of system packages and manual installations
- **Missing CUDA Toolkit**: No development tools (nvcc, headers, libraries)
- **Incomplete Python Stack**: No PyTorch/CUDA integration via uv
- **Template Inconsistency**: chezmoi templates assume CUDA paths that don't exist
- **Performance Gaps**: Inference workloads cannot utilize full GPU potential

### Working Components
- ✅ NVIDIA drivers (550.163.01) functional
- ✅ GPU detection and power management
- ✅ Docker Engine with nvidia-container-toolkit
- ✅ Basic nvidia-smi monitoring

---

## Strategic Implementation Plan

### Phase 1: Complete System Reset and Clean Installation

#### 1.1 Pre-Installation Preparation

**Container Management:**
```bash
# Document running containers for restoration
docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}" > /tmp/containers_backup.txt

# Stop all GPU-dependent containers
docker stop $(docker ps -q)

# Export important container configurations
docker-compose -f /path/to/archon/docker-compose.yml config > /tmp/archon_config_backup.yml
```

**System State Documentation:**
```bash
# Document current NVIDIA installation
dpkg -l | grep -E 'nvidia|cuda' > /tmp/nvidia_packages_before.txt
nvidia-smi -q > /tmp/gpu_state_before.txt
lspci | grep -i nvidia > /tmp/pci_devices.txt
```

#### 1.2 Complete NVIDIA Removal

**Package Removal (Comprehensive):**
```bash
# Stop NVIDIA services
sudo systemctl stop nvidia-persistenced
sudo systemctl disable nvidia-persistenced

# Remove all NVIDIA/CUDA packages
sudo apt purge -y $(dpkg -l | grep -E 'nvidia|cuda' | awk '{print $2}')
sudo apt purge -y 'nvidia-*' 'cuda-*' 'libnvidia-*' 'libcuda*'
sudo apt autoremove -y --purge

# Remove DKMS modules
sudo dkms remove -m nvidia -v ALL --all 2>/dev/null || true
```

**Configuration Cleanup:**
```bash
# Remove system configurations
sudo rm -rf /usr/local/cuda*
sudo rm -rf /etc/nvidia/
sudo rm -rf /var/lib/dkms/nvidia*
sudo rm -rf /usr/share/nvidia/
sudo rm -rf /usr/lib/nvidia/

# Clean modprobe configurations
sudo rm -f /etc/modprobe.d/nvidia*.conf
sudo rm -f /etc/modprobe.d/blacklist-nvidia*.conf

# Remove user configurations
rm -rf ~/.nv/
rm -rf ~/.nvidia/

# Clean kernel modules
sudo modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia || true
```

**System Reboot (Critical):**
```bash
# Essential for clean kernel state
sudo reboot
```

#### 1.3 Modern NVIDIA Stack Installation

**Repository Setup:**
```bash
# Add official NVIDIA repository (most current packages)
wget https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
```

**Driver and CUDA Installation:**
```bash
# Install latest driver + complete CUDA toolkit
sudo apt install -y \
    nvidia-driver-560 \
    cuda-toolkit-12-6 \
    nvidia-container-toolkit \
    nvidia-cuda-dev \
    nvidia-cuda-toolkit

# Alternative: Use NVIDIA's unified installer for latest features
# wget https://developer.download.nvidia.com/compute/cuda/12.6.2/local_installers/cuda_12.6.2_560.35.03_linux.run
# sudo sh cuda_12.6.2_560.35.03_linux.run --silent --toolkit --driver
```

**Container Runtime Configuration:**
```bash
# Configure Docker for GPU access
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
```

**System Integration:**
```bash
# Configure NVIDIA persistence daemon
sudo systemctl enable nvidia-persistenced
sudo systemctl start nvidia-persistenced

# Update dynamic linker
sudo ldconfig

# Verify installation
nvidia-smi
nvcc --version
```

### Phase 2: Chezmoi Template Integration

#### 2.1 Enhanced Node Capability Detection

**Update `.chezmoi.toml.tmpl`:**
```toml
[data]
    # Existing node identification...

    # Enhanced GPU and CUDA capabilities
    {{ if or (eq .chezmoi.hostname "projector") (eq .chezmoi.hostname "director") -}}
    has_gpu = true
    has_cuda_runtime = true
    has_cuda_toolkit = true
    cuda_version = "12.6"
    cuda_home = "/usr/local/cuda"
    gpu_architecture = {{ if eq .chezmoi.hostname "projector" }}"multi_gpu"{{ else }}"single_gpu"{{ end }}

    # Inference optimization flags
    supports_vllm = true
    supports_llama_cpp = true
    supports_pytorch_cuda = true

    # Container capabilities
    has_nvidia_container = true
    docker_gpu_support = true
    {{- else -}}
    has_gpu = false
    has_cuda_runtime = false
    has_cuda_toolkit = false
    cuda_version = ""
    cuda_home = ""
    gpu_architecture = "none"
    supports_vllm = false
    supports_llama_cpp = false
    supports_pytorch_cuda = false
    has_nvidia_container = false
    docker_gpu_support = false
    {{- end }}

    # Python environment management
    uses_uv = true
    python_gpu_package_index = "https://download.pytorch.org/whl/cu126"
```

#### 2.2 Enhanced Environment Configuration

**Update `dot_profile.tmpl`:**
```bash
# GPU and CUDA Environment (Template-Conditional)
{{- if .has_cuda_toolkit }}
# CUDA Development Toolkit
if [ -d "{{ .cuda_home }}/bin" ]; then
    add_to_path "{{ .cuda_home }}/bin"
    export CUDA_HOME="{{ .cuda_home }}"
    export CUDA_VERSION="{{ .cuda_version }}"
fi

# CUDA Libraries
if [ -d "{{ .cuda_home }}/lib64" ]; then
    export LD_LIBRARY_PATH="{{ .cuda_home }}/lib64${LD_LIBRARY_PATH:+":$LD_LIBRARY_PATH"}"
fi

# CUDA Include Path (for compilation)
if [ -d "{{ .cuda_home }}/include" ]; then
    export CUDA_INCLUDE_PATH="{{ .cuda_home }}/include"
    export CPATH="{{ .cuda_home }}/include${CPATH:+":$CPATH"}"
fi
{{- end }}

{{- if .has_nvidia_container }}
# NVIDIA Container Runtime Environment
export NVIDIA_VISIBLE_DEVICES="${NVIDIA_VISIBLE_DEVICES:-all}"
export NVIDIA_DRIVER_CAPABILITIES="${NVIDIA_DRIVER_CAPABILITIES:-compute,utility,graphics}"
{{- end }}

{{- if .uses_uv }}
# UV Python Package Management with CUDA
export UV_EXTRA_INDEX_URL="{{ .python_gpu_package_index }}"
export UV_CUDA_VERSION="{{ .cuda_version }}"
{{- end }}

# Node-specific GPU optimizations
{{- if eq .gpu_architecture "multi_gpu" }}
# Multi-GPU optimizations (projector)
export CUDA_DEVICE_ORDER="PCI_BUS_ID"
export NCCL_DEBUG=INFO
export OMP_NUM_THREADS=8
{{- else if eq .gpu_architecture "single_gpu" }}
# Single GPU optimizations (director)
export CUDA_DEVICE_ORDER="FASTEST_FIRST"
export OMP_NUM_THREADS=4
{{- end }}
```

#### 2.3 GPU-Optimized Shell Aliases

**Update `dot_bashrc.tmpl` and `dot_zshrc.tmpl`:**
```bash
{{- if .has_gpu }}
# GPU Monitoring and Management
alias gpus='nvidia-smi'
alias gpu-watch='watch -n 1 nvidia-smi'
alias gpu-mem='nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader'
alias gpu-util='nvidia-smi --query-gpu=utilization.gpu,utilization.memory --format=csv,noheader'
alias gpu-temp='nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader'
alias gpu-power='nvidia-smi --query-gpu=power.draw,power.limit --format=csv,noheader'

# CUDA Development
{{- if .has_cuda_toolkit }}
alias cuda-version='nvcc --version'
alias cuda-devices='nvidia-smi -L'
alias cuda-compile='nvcc -O3 -arch=sm_61'  # Adjust for your GPU architecture
{{- end }}
{{- end }}

{{- if .has_nvidia_container }}
# Docker GPU Integration
alias docker-gpu='docker run --gpus all'
alias docker-gpu-it='docker run -it --rm --gpus all'
alias docker-gpu-test='docker run --rm --gpus all nvidia/cuda:{{ .cuda_version }}-base-ubuntu20.04 nvidia-smi'
{{- end }}

{{- if .supports_vllm }}
# vLLM Inference Optimization
alias vllm-serve='python -m vllm.entrypoints.openai.api_server'
alias vllm-benchmark='python -m vllm.benchmark'
{{- end }}

{{- if .supports_llama_cpp }}
# llama.cpp with CUDA
alias llama-cpp-cuda='make LLAMA_CUDA=1'
alias llama-serve='./server -m models/ --gpu-layers -1'
{{- end }}

{{- if eq .gpu_architecture "multi_gpu" }}
# Multi-GPU specific aliases (projector)
alias gpu-topology='nvidia-smi topo -m'
alias gpu-reset-all='sudo nvidia-smi -r'
alias distributed-test='python -m torch.distributed.launch --nproc_per_node={{ .projector_gpu_count | default "4" }}'
{{- end }}
```

### Phase 3: Modern ML/AI Stack Integration

#### 3.1 UV-Based Python Environment Management

**Global UV Configuration:**
```bash
# Create UV configuration for CUDA-enabled packages
uv config set extra-index-url https://download.pytorch.org/whl/cu126

# Install essential GPU tools globally
uv tool install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
uv tool install nvidia-ml-py3  # For GPU monitoring
```

**Project-Specific Environments:**
```bash
# Inference Environment
mkdir -p /opt/inference-env
cd /opt/inference-env
uv init
uv add torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
uv add vllm transformers accelerate
uv add llama-cpp-python --config-settings=cmake.args="-DLLAMA_CUDA=on"

# Research Environment
mkdir -p /opt/research-env
cd /opt/research-env
uv init
uv add torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
uv add jupyter matplotlib pandas scikit-learn
uv add huggingface-hub datasets

# Ollama Environment (if needed)
mkdir -p /opt/ollama-env
cd /opt/ollama-env
uv init
uv add ollama-python requests
```

#### 3.2 Container Optimization

**GPU-Optimized Docker Images:**
```dockerfile
# Base inference image
FROM nvidia/cuda:12.6-devel-ubuntu22.04

# Install UV
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Install Python packages via UV
RUN uv init && \
    uv add torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126 && \
    uv add vllm transformers

# Optimize for inference
ENV CUDA_VISIBLE_DEVICES=all
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
```

**Container Runtime Verification:**
```bash
# Test GPU access in containers
docker run --rm --gpus all nvidia/cuda:12.6-base-ubuntu20.04 nvidia-smi

# Test PyTorch CUDA in container
docker run --rm --gpus all -v $(pwd):/workspace \
  pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime \
  python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}, Devices: {torch.cuda.device_count()}')"
```

### Phase 4: Performance Optimization and Monitoring

#### 4.1 GPU Performance Tuning

**System-Level Optimizations:**
```bash
# GPU persistence mode (reduces startup latency)
sudo nvidia-smi -pm 1

# Set optimal power limits (adjust per GPU model)
sudo nvidia-smi -pl 200  # GTX 1080
sudo nvidia-smi -pl 180  # GTX 970

# Memory clock optimization
sudo nvidia-smi -ac 4004,1911  # GTX 1080 memory,graphics clocks
```

**Multi-GPU Communication Optimization (Projector):**
```bash
# NCCL optimization for multi-GPU inference
echo 'export NCCL_SOCKET_IFNAME=enp4s0' >> /etc/environment
echo 'export NCCL_IB_DISABLE=1' >> /etc/environment
echo 'export NCCL_P2P_DISABLE=1' >> /etc/environment  # If needed for stability
```

#### 4.2 Monitoring and Alerting

**GPU Monitoring Service:**
```bash
# Create systemd service for GPU monitoring
sudo tee /etc/systemd/system/gpu-monitor.service <<EOF
[Unit]
Description=GPU Monitoring and Logging
After=nvidia-persistenced.service

[Service]
Type=simple
ExecStart=/usr/bin/nvidia-smi -l 60 --format=csv --filename=/var/log/gpu-metrics.csv
Restart=always
User=nobody

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable gpu-monitor.service
sudo systemctl start gpu-monitor.service
```

**Health Check Scripts:**
```bash
#!/bin/bash
# /usr/local/bin/gpu-health-check.sh

# Check GPU accessibility
if ! nvidia-smi >/dev/null 2>&1; then
    echo "ERROR: nvidia-smi not accessible"
    exit 1
fi

# Check CUDA functionality
if ! nvcc --version >/dev/null 2>&1; then
    echo "ERROR: CUDA toolkit not accessible"
    exit 1
fi

# Check Docker GPU integration
if ! docker run --rm --gpus all nvidia/cuda:12.6-base-ubuntu20.04 nvidia-smi >/dev/null 2>&1; then
    echo "ERROR: Docker GPU integration failed"
    exit 1
fi

echo "GPU stack healthy"
```

### Phase 5: Validation and Testing

#### 5.1 Comprehensive Testing Suite

**GPU Hardware Testing:**
```bash
# Basic functionality
nvidia-smi
nvcc --version

# Memory and compute testing
nvidia-smi --query-gpu=name,memory.total,compute_cap --format=csv
gpu-burn -d 60  # Stress test (install via apt)

# Multi-GPU testing (projector only)
nvidia-smi topo -m  # Check topology
```

**Software Stack Testing:**
```bash
# PyTorch CUDA integration
python3 -c "
import torch
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
print(f'CUDA version: {torch.version.cuda}')
print(f'GPU count: {torch.cuda.device_count()}')
for i in range(torch.cuda.device_count()):
    print(f'GPU {i}: {torch.cuda.get_device_name(i)}')
"

# vLLM functionality test
python3 -c "
from vllm import LLM
llm = LLM(model='microsoft/DialoGPT-medium', gpu_memory_utilization=0.3)
outputs = llm.generate(['Hello, how are you?'])
print(f'vLLM working: {len(outputs) > 0}')
"

# Container GPU access
docker run --rm --gpus all nvidia/cuda:12.6-base-ubuntu20.04 nvidia-smi
```

**Performance Benchmarking:**
```bash
# GPU memory bandwidth test
cd /tmp
git clone https://github.com/NVIDIA/cuda-samples.git
cd cuda-samples/Samples/1_Utilities/bandwidthTest
make
./bandwidthTest

# Inference performance test
cd /opt/inference-env
uv run python -c "
import torch
import time

# Test tensor operations
device = torch.device('cuda:0')
x = torch.randn(10000, 10000, device=device)
start = time.time()
y = torch.matmul(x, x)
torch.cuda.synchronize()
end = time.time()
print(f'Matrix multiply time: {end-start:.3f}s')
"
```

#### 5.2 Integration Verification

**Chezmoi Template Verification:**
```bash
# Verify template rendering
chezmoi diff
chezmoi data | jq '.has_cuda_toolkit, .cuda_version, .supports_vllm'

# Test environment variables
echo $CUDA_HOME
echo $LD_LIBRARY_PATH
which nvcc

# Test aliases
gpus
cuda-version
docker-gpu-test
```

**Container Service Restoration:**
```bash
# Restore Archon containers with GPU support
docker-compose -f /path/to/archon/docker-compose.yml up -d

# Verify GPU access in containers
docker exec archon-server nvidia-smi
```

---

## Risk Management and Rollback Strategy

### Backup and Recovery

**Pre-Installation Backup:**
```bash
# Create system snapshot (if using LVM/ZFS)
sudo lvcreate -s -n nvidia-backup -L 10G /dev/vg0/root

# Document current state
dpkg -l > /tmp/packages-before.txt
nvidia-smi -q > /tmp/nvidia-before.txt
docker ps -a > /tmp/containers-before.txt
```

**Rollback Procedure:**
```bash
# If installation fails, rollback to previous driver
sudo apt install nvidia-driver-470  # or previous working version
sudo reboot

# Restore from system snapshot
sudo lvconvert --merge /dev/vg0/nvidia-backup
sudo reboot
```

### Risk Mitigation

1. **Staged Deployment**: Test on director (single GPU) before projector (multi-GPU)
2. **Monitoring**: Continuous GPU health monitoring during transition
3. **Container Isolation**: GPU workloads in containers limit system impact
4. **Configuration Management**: All changes tracked through chezmoi git history

---

## Post-Implementation Maintenance

### Regular Updates

**Driver Updates:**
```bash
# Monthly driver update check
sudo apt update && apt list --upgradable | grep nvidia

# CUDA toolkit updates (quarterly)
sudo apt update && apt list --upgradable | grep cuda
```

**Performance Monitoring:**
```bash
# Weekly performance checks
/usr/local/bin/gpu-health-check.sh
nvidia-smi --query-gpu=temperature.gpu,power.draw --format=csv

# Monthly comprehensive testing
cd /opt/inference-env && uv run python benchmark_suite.py
```

### Scaling Considerations

**Adding New GPU Nodes:**
1. Apply chezmoi configuration: `chezmoi init --apply`
2. Run installation playbook: `ansible-playbook gpu-setup.yml`
3. Verify with test suite: `./gpu-validation.sh`

**CUDA Version Upgrades:**
1. Update chezmoi templates with new version
2. Test in isolated environment
3. Deploy with rolling update strategy

---

## Conclusion

This implementation strategy provides a comprehensive, production-ready NVIDIA/CUDA stack for the Co-lab cluster. The approach prioritizes:

- **Reliability**: Clean installation eliminates configuration conflicts
- **Performance**: Optimized for inference workloads and multi-GPU scenarios
- **Maintainability**: Chezmoi integration ensures consistent, manageable configurations
- **Scalability**: UV-based Python environments support diverse ML/AI workloads
- **Future-Proofing**: Modern stack supports emerging inference technologies

The combination of bare-metal performance, containerized workloads, and template-driven configuration management creates an optimal foundation for production AI/ML compute infrastructure.

**Next Steps:**
1. Execute Phase 1 (Clean Installation) on director node (single GPU, lower risk)
2. Validate functionality and performance
3. Apply to projector node (multi-GPU)
4. Update chezmoi templates and deploy cluster-wide
5. Implement monitoring and maintenance procedures

This strategy transforms the Co-lab cluster into a state-of-the-art GPU compute platform capable of supporting the most demanding inference workloads while maintaining operational excellence through unified configuration management.