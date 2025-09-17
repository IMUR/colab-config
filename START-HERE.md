# START HERE: Co-lab Cluster Infrastructure Optimization

**🎯 Your Complete Infrastructure Reset Journey**
**Strategy**: Clean slate → unified configuration → optimal reinstallation
**Timeline**: ~3 hours total • ~2 hours downtime • 100% application preservation

---

## 📍 Navigation Guide

This document provides a **clear path** through the comprehensive infrastructure reset documentation. Follow the three-stage process below for optimal cluster infrastructure.

### **📚 Complete Documentation Library**

**🏗️ Architecture & Implementation:**
- [NVIDIA/CUDA Implementation Strategy](documentation/architecture/NVIDIA-CUDA-IMPLEMENTATION-STRATEGY.md) - Complete GPU stack deployment
- [Docker Clean Reinstall Strategy](documentation/architecture/DOCKER-CLEAN-REINSTALL-STRATEGY.md) - Docker optimization with Archon preservation
- [Cluster Architecture Overview](documentation/architecture/COLAB-CLUSTER-ARCHITECTURE.md) - Overall system design

**📋 Procedures & Operations:**
- [Complete Infrastructure Reset Sequence](documentation/procedures/COMPLETE-INFRASTRUCTURE-RESET-SEQUENCE.md) - Master reset procedure
- [Systemd Service Management Addendum](documentation/procedures/SYSTEMD-SERVICE-MANAGEMENT-ADDENDUM.md) - Critical service management

**⚙️ Configuration Management:**
- [Omni-Config Documentation](omni-config/README.md) - User environment and template system
- [Main Repository Documentation](README.md) - Repository overview and quick start

---

## 🎯 Three-Stage Infrastructure Reset Process

### **Stage 1: Removal and Cleaning** ⚠️
*Complete system cleanup with application preservation*

#### **Primary Documents:**
1. 📖 **[Complete Infrastructure Reset Sequence - Phase 2](documentation/procedures/COMPLETE-INFRASTRUCTURE-RESET-SEQUENCE.md#phase-2-complete-removal)**
2. 📖 **[Systemd Service Management Addendum - Phases 1-3](documentation/procedures/SYSTEMD-SERVICE-MANAGEMENT-ADDENDUM.md#phase-1-pre-reset-service-documentation)**
3. 📖 **[Docker Clean Reinstall Strategy - Phase 1](documentation/architecture/DOCKER-CLEAN-REINSTALL-STRATEGY.md#phase-1-complete-archon-preservation)**

#### **Key Activities:**
```bash
# Critical Discovery: Archon runs as BOTH systemd service AND containers
# Critical Discovery: Ollama runs as systemd service requiring preservation

1. 💾 Preserve Archon Infrastructure (100% data protection)
   - Export all container images and configurations
   - Backup PostgreSQL data volume (critical database)
   - Preserve systemd service configurations
   - Document current container state

2. 🛑 Stop All Target Services
   - Stop archon.service and ollama.service (systemd services)
   - Stop all Docker containers gracefully
   - Stop NVIDIA services (persistenced, suspend, resume, hibernate)
   - Stop Docker services (docker.service, docker.socket, containerd.service)

3. 🗑️ Complete Package Removal
   - Remove all NVIDIA packages (drivers, CUDA, libraries)
   - Remove all Docker packages (engine, CLI, compose, buildx)
   - Clean system configurations and user configs
   - Remove network interfaces and iptables rules

4. 🔄 System Cleanup and Reboot
   - Clean package cache and orphaned files
   - Remove kernel modules and system remnants
   - Reboot for completely clean state
```

#### **Expected Outcome:**
- ✅ Clean system with no NVIDIA or Docker packages
- ✅ 100% Archon application data preserved
- ✅ All service configurations backed up
- ✅ System ready for unified configuration deployment

---

### **Stage 2: Cluster-Wide Colab-Config Completion and Optimization** 🎯
*Deploy unified configuration management across all nodes*

#### **Primary Documents:**
1. 📖 **[Complete Infrastructure Reset Sequence - Phase 3](documentation/procedures/COMPLETE-INFRASTRUCTURE-RESET-SEQUENCE.md#phase-3-omni-config-deployment)**
2. 📖 **[Omni-Config Documentation](omni-config/README.md)**
3. 📖 **[Main Repository Quick Start](README.md#-quick-start-20-minutes)**

#### **Key Activities:**
```bash
# Deploy modern hybrid configuration management across cluster

1. 🔍 Verify Clean State
   - Validate complete removal on all nodes
   - Confirm no GPU/Docker processes running
   - Verify cluster connectivity and NFS access

2. ⚙️ Deploy Chezmoi Configuration
   - Initialize chezmoi on all nodes from GitHub remote
   - Apply node-specific templates (cooperator/projector/director)
   - Validate template rendering and environment variables

3. 🎛️ Template System Optimization
   - Node-specific capabilities (has_gpu, has_docker, node_role)
   - Environment detection and tool integration
   - Shell unification (bash and zsh with shared templates)

4. 🔧 Limited Ansible (If Needed)
   - Execute minimal system-wide configuration
   - Health monitoring and connectivity validation
   - System preparation for optimal reinstallation
```

#### **Expected Outcome:**
- ✅ Unified configuration management across all nodes
- ✅ Node-specific template rendering working
- ✅ Clean, consistent shell environments
- ✅ Infrastructure ready for optimal software stack

---

### **Stage 3: Strategic Re-installation** 🚀
*Install modern, unified software stack with GPU optimization*

#### **Primary Documents:**
1. 📖 **[Complete Infrastructure Reset Sequence - Phase 4](documentation/procedures/COMPLETE-INFRASTRUCTURE-RESET-SEQUENCE.md#phase-4-optimal-reinstallation)**
2. 📖 **[NVIDIA/CUDA Implementation Strategy - Phase 1.3](documentation/architecture/NVIDIA-CUDA-IMPLEMENTATION-STRATEGY.md#13-modern-nvidia-stack-installation)**
3. 📖 **[Docker Clean Reinstall Strategy - Phase 3](documentation/architecture/DOCKER-CLEAN-REINSTALL-STRATEGY.md#phase-3-clean-docker-installation)**

#### **Key Activities:**
```bash
# Install modern, optimized software stack with template integration

1. 🖥️ Fresh NVIDIA Installation (GPU Nodes)
   - Install NVIDIA drivers 560.x + CUDA 12.6+
   - Configure nvidia-container-toolkit for Docker GPU support
   - Enable NVIDIA persistence and power management
   - Test GPU functionality and memory access

2. 🐳 Clean Docker Installation (All Nodes)
   - Install Docker CE from official repository
   - Configure optimized daemon.json for GPU integration
   - Enable Docker socket and service dependencies
   - Test container operations and GPU passthrough

3. 🎯 Template-Driven Configuration
   - Apply chezmoi updates with new capabilities
   - Load GPU and Docker aliases and environment variables
   - Configure node-specific optimizations
   - Test unified shell and tool integration

4. 🔄 Application Restoration
   - Restore Archon container stack with preserved data
   - Restore systemd services (archon.service, ollama.service)
   - Test dual-stack functionality (containers + systemd)
   - Validate performance and GPU acceleration
```

#### **Expected Outcome:**
- ✅ Modern NVIDIA drivers + CUDA 12.6+ with full toolkit
- ✅ Clean Docker installation with optimal GPU integration
- ✅ 100% Archon functionality restored with GPU acceleration
- ✅ Unified, template-driven configuration management
- ✅ Production-ready cluster optimized for ML/AI workloads

---

## 🎯 Quick Decision Matrix

### **When to Execute Full Reset:**
- ✅ You want optimal, unified cluster infrastructure
- ✅ You're experiencing NVIDIA/Docker fragmentation issues
- ✅ You want to implement template-driven configuration management
- ✅ You have 3 hours available for comprehensive optimization

### **Alternative Approaches:**
- **🔧 Incremental Updates**: Use individual strategy documents for targeted improvements
- **⚙️ Configuration Only**: Deploy omni-config without infrastructure reset
- **🖥️ GPU Only**: Use NVIDIA strategy document for GPU node optimization only

---

## 📋 Pre-Execution Checklist

### **Prerequisites:**
- [ ] Cluster connectivity verified (SSH access to all nodes)
- [ ] NFS storage accessible from all nodes
- [ ] Git repository access confirmed
- [ ] Backup infrastructure in place
- [ ] 3-hour maintenance window scheduled

### **Critical Preparation:**
- [ ] Review [Systemd Service Management Addendum](documentation/procedures/SYSTEMD-SERVICE-MANAGEMENT-ADDENDUM.md) for service complexities
- [ ] Understand Archon dual-stack architecture (systemd + containers)
- [ ] Verify Ollama service requirements
- [ ] Confirm rollback procedures and emergency access

### **Execution Team:**
- [ ] Administrator with sudo access to all nodes
- [ ] Understanding of cluster architecture and dependencies
- [ ] Familiarity with chezmoi template system
- [ ] Emergency contact plan if issues arise

---

## 🚀 Execution Command

Once you've reviewed all documentation and completed the checklist:

```bash
# Navigate to the procedures directory
cd /cluster-nas/colab/colab-config/documentation/procedures/

# Follow the master procedure with service management
# 1. Review service management requirements first:
cat SYSTEMD-SERVICE-MANAGEMENT-ADDENDUM.md

# 2. Execute the complete infrastructure reset sequence:
# Follow COMPLETE-INFRASTRUCTURE-RESET-SEQUENCE.md step by step

# The sequence automatically integrates all strategy documents:
# - NVIDIA/CUDA implementation
# - Docker clean reinstall
# - Systemd service management
# - Archon preservation
# - Template-driven configuration
```

---

## 📞 Support and References

### **Documentation Hierarchy:**
```
START-HERE.md (you are here)
├── 📋 COMPLETE-INFRASTRUCTURE-RESET-SEQUENCE.md (master procedure)
│   ├── 🔧 SYSTEMD-SERVICE-MANAGEMENT-ADDENDUM.md (service management)
│   ├── 🖥️ NVIDIA-CUDA-IMPLEMENTATION-STRATEGY.md (GPU installation)
│   ├── 🐳 DOCKER-CLEAN-REINSTALL-STRATEGY.md (Docker + Archon)
│   └── ⚙️ omni-config/README.md (configuration management)
└── 📚 README.md (repository overview)
```

### **Emergency Procedures:**
- **🆘 Rollback**: Each strategy document includes rollback procedures
- **🔧 Service Recovery**: Emergency service recovery procedures in service addendum
- **📞 Support**: Issue tracking at https://github.com/IMUR/colab-config/issues

### **Key Contacts:**
- **📖 Documentation**: All procedures self-contained with examples
- **🏗️ Architecture**: Comprehensive system design documentation
- **⚙️ Configuration**: Template-driven management with node-specific capabilities

---

## 🎯 Success Metrics

After completing the three-stage process, you will have:

### **Infrastructure Excellence:**
- **🖥️ Modern GPU Stack**: NVIDIA 560.x + CUDA 12.6+ with full development toolkit
- **🐳 Optimized Docker**: Clean installation with perfect GPU integration
- **⚙️ Unified Configuration**: Template-driven, node-specific management
- **🔧 Service Reliability**: Proper systemd service management and health monitoring

### **Application Continuity:**
- **📊 100% Archon Preservation**: Complete functionality with enhanced GPU acceleration
- **🦙 Ollama Integration**: Systemd service + container optimization
- **📈 Performance Optimization**: Multi-GPU support and inference acceleration
- **🔄 Zero Data Loss**: All application data and configurations preserved

### **Operational Readiness:**
- **📋 Comprehensive Documentation**: Complete procedures and troubleshooting
- **🎯 Scalable Architecture**: Ready for future nodes and applications
- **🔍 Health Monitoring**: Automated service and performance validation
- **🚀 Production Ready**: Optimized for years of reliable ML/AI workloads

---

**🎉 Welcome to your optimized Co-lab cluster infrastructure journey!**

**Next Step**: Review the [Complete Infrastructure Reset Sequence](documentation/procedures/COMPLETE-INFRASTRUCTURE-RESET-SEQUENCE.md) to begin your transformation.