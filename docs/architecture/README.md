---
meta:
  directory_type: "system_architecture"
  management_tool: "design_documentation"
  automation_safe: true
  last_updated: "2025-09-27"
agent_context:
  purpose: "Complete Co-lab cluster architecture documentation"
  scope: "infrastructure_design_and_strategy"
  safe_operations: ["architecture_analysis", "design_documentation", "strategy_explanation"]
  restricted_operations: ["architecture_modification", "design_changes"]
---

# System Architecture Documentation

Complete architectural documentation for the Co-lab cluster infrastructure, covering hardware design, network topology, service distribution, and management strategies.

## Architecture Documents

### 🏗️ [CLUSTER-ARCHITECTURE.md](CLUSTER-ARCHITECTURE.md)
**Complete 3-node cluster design and implementation**
- **Node Specifications**: Hardware details and role assignments
- **Network Topology**: 192.168.254.0/24 internal network design
- **Service Distribution**: NFS, DNS, proxy, and compute service allocation
- **Hybrid Management Strategy**: Ansible + Chezmoi configuration approach
- **Success Criteria**: Operational achievements and validation metrics

### 🎮 [GPU-COMPUTE-STRATEGY.md](GPU-COMPUTE-STRATEGY.md)
**NVIDIA/CUDA infrastructure and optimization**
- **Hardware Configuration**: GPU allocation across compute nodes
- **Installation Strategy**: Clean NVIDIA/CUDA deployment procedures
- **Template Integration**: Chezmoi templates for GPU-aware configurations
- **Performance Optimization**: GPU compute workload optimization
- **Monitoring Integration**: GPU utilization and health monitoring

### 🐳 [CONTAINER-PLATFORM-STRATEGY.md](CONTAINER-PLATFORM-STRATEGY.md)
**Docker infrastructure and service management**
- **Container Platform Design**: Docker deployment strategy
- **Service Preservation**: Critical application container protection
- **Clean Reinstallation**: Complete Docker removal and reinstallation
- **Integration Strategy**: Container platform integration with cluster services

### 🔄 [HYBRID-STRATEGY.md](HYBRID-STRATEGY.md)
**Ansible + Chezmoi configuration management rationale**
- **Tool Separation Strategy**: Right tool for right job philosophy
- **Risk Mitigation**: Minimal system intervention approach
- **User vs System**: Clear boundaries between user and system configuration
- **Rollback Capabilities**: Safe reversion and recovery procedures

### 🌐 [NETWORK-TOPOLOGY.md](NETWORK-TOPOLOGY.md)
**Cluster networking design and service connectivity**
- **IP Allocation**: Static IP assignments and network segmentation
- **Service Routing**: Internal service discovery and external access
- **Security Design**: Network-level security and access controls
- **Performance Considerations**: Network optimization for cluster workloads

## Quick Reference

### Cluster Overview
- **Nodes**: 3 (cooperator, projector, director)
- **Management**: Hybrid Ansible + Chezmoi
- **Network**: 192.168.254.0/24 internal
- **Deployment**: GitHub remote via Chezmoi
- **Timeline**: ~15 minute deployments

### Node Roles
- **cooperator (crtr)**: Gateway, NFS, DNS (Raspberry Pi 5, ARM64)
- **projector (prtr)**: Primary compute, GPU workloads (x86_64, 4x GPU)
- **director (drtr)**: ML operations, development (x86_64, 1x GPU)

### Critical Services
- **Storage**: NFS server (cooperator)
- **DNS**: Pi-hole DNS (cooperator)
- **Proxy**: Caddy reverse proxy (cooperator)
- **Compute**: GPU workloads (projector, director)

## Design Principles

### 1. **Minimal System Intervention**
- User-level configuration changes preserve SSH access
- System modifications only when absolutely necessary
- Clear separation between user and system configuration domains

### 2. **Tool-Appropriate Management**
- Chezmoi for user environment configuration and templates
- Ansible for minimal required system-level operations
- Docker Compose for containerized service orchestration

### 3. **Risk Mitigation**
- Multiple rollback mechanisms at every configuration level
- Comprehensive validation before any system modifications
- Preservation of critical services during infrastructure changes

### 4. **Performance Optimization**
- GPU compute workload optimization and resource allocation
- Network performance tuning for cluster communication
- Storage optimization for shared NFS workloads

## Related Documentation

- **[Implementation Guides](../guides/)** - Operational procedures and tutorials
- **[Technical Reference](../reference/)** - Commands, variables, and specifications
- **[Configuration Examples](../examples/)** - Practical implementation examples
- **[Historical Decisions](../archive/decisions/)** - Architecture decision records