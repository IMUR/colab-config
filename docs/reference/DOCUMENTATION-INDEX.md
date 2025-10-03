---
title: "Documentation Index"
description: "Complete index and navigation guide for Co-lab cluster documentation"
version: "1.0"
date: "2025-09-27"
category: "reference"
tags: ["index", "navigation", "documentation", "reference"]
applies_to: ["all_nodes"]
related:
  - "COMMANDS.md"
  - "VARIABLES.md"
  - "TEMPLATES.md"
---

# Documentation Index

## Overview

This index provides a comprehensive map of all documentation in the Co-lab cluster repository, organized by category and purpose. Use this as your starting point for finding specific information about cluster architecture, configuration, and operations.

## Quick Navigation

### By Audience
- **New Users**: Start with [Cluster Architecture](../architecture/CLUSTER-ARCHITECTURE.md) → [Hybrid Strategy](../architecture/HYBRID-STRATEGY.md) → [Project Completion](../guides/PROJECT-COMPLETION.md)
- **System Administrators**: Focus on [Infrastructure Reset](../guides/INFRASTRUCTURE-RESET.md) → [Service Management](../guides/SERVICE-MANAGEMENT.md) → [Troubleshooting](../guides/TROUBLESHOOTING.md)
- **Developers**: See [Templates Reference](TEMPLATES.md) → [Variables Reference](VARIABLES.md) → [Commands Reference](COMMANDS.md)
- **AI Agents**: Review all architecture documents → reference materials → specific guides as needed

### By Task
- **Initial Setup**: [Infrastructure Reset Guide](../guides/INFRASTRUCTURE-RESET.md)
- **Daily Operations**: [Service Management](../guides/SERVICE-MANAGEMENT.md) + [Commands Reference](COMMANDS.md)
- **Configuration Changes**: [Templates Reference](TEMPLATES.md) + [Variables Reference](VARIABLES.md)
- **Problem Solving**: [Troubleshooting Guide](../guides/TROUBLESHOOTING.md)
- **Repository Organization**: [Repository Restructure](../guides/REPOSITORY-RESTRUCTURE.md)

## Architecture Documentation

### Core Architecture
- **[Cluster Architecture](../architecture/CLUSTER-ARCHITECTURE.md)** - Complete 3-node cluster design and node roles
- **[Network Topology](../architecture/NETWORK-TOPOLOGY.md)** - Network design, DNS, NFS, and connectivity
- **[Hybrid Strategy](../architecture/HYBRID-STRATEGY.md)** - Strategic rationale for Ansible + Chezmoi approach

### Infrastructure Components
- **[GPU Compute Strategy](../architecture/GPU-COMPUTE-STRATEGY.md)** - NVIDIA/CUDA implementation for GPU nodes
- **[Container Platform Strategy](../architecture/CONTAINER-PLATFORM-STRATEGY.md)** - Docker architecture with Archon preservation

## Implementation Guides

### Essential Guides
- **[Infrastructure Reset Guide](../guides/INFRASTRUCTURE-RESET.md)** - Complete end-to-end infrastructure reset sequence
- **[Service Management Guide](../guides/SERVICE-MANAGEMENT.md)** - Systemd service management for cluster applications
- **[Repository Restructure Guide](../guides/REPOSITORY-RESTRUCTURE.md)** - Semantic implementation of repository organization

### Strategic Guides
- **[Project Completion Guide](../guides/PROJECT-COMPLETION.md)** - Understanding the path to completion and maintenance
- **[Troubleshooting Guide](../guides/TROUBLESHOOTING.md)** - Common issues and solutions across cluster components

## Reference Materials

### Technical References
- **[Commands Reference](COMMANDS.md)** - Comprehensive command reference for all cluster operations
- **[Variables Reference](VARIABLES.md)** - Configuration variables and template parameters
- **[Templates Reference](TEMPLATES.md)** - Chezmoi template examples and patterns
- **[Documentation Index](DOCUMENTATION-INDEX.md)** - This document - complete navigation guide

## Archive Documentation

### Historical Decisions
- **[001 - Hybrid Approach Decision](../archive/decisions/001-hybrid-approach.md)** - Strategic decision rationale
- **[002 - Chezmoi Adoption Decision](../archive/decisions/002-chezmoi-adoption.md)** - Migration from complex Ansible
- **[003 - Configuration Constraints](../archive/decisions/003-configuration-constraints.md)** - Design constraints and rules

### Migration Records
- **[Documentation Reorganization](../archive/migrations/documentation-reorganization.md)** - Record of documentation restructure process

## Examples and Templates

### Node Configurations
- **[Cooperator Example Config](../examples/node-configs/cooperator-example.yml)** - Gateway node configuration example
- **[Projector Example Config](../examples/node-configs/projector-example.yml)** - Multi-GPU compute node example
- **[Director Example Config](../examples/node-configs/director-example.yml)** - ML platform node example

### Template Examples
- **[Node-Specific Template](../examples/templates/node-specific-template.tmpl)** - Template patterns for node detection
- **[Service Configuration Templates](../examples/templates/)** - Various service configuration examples

### Playbook Examples
- **[Infrastructure Example](../examples/playbooks/infrastructure-example.yml)** - Ansible playbook patterns

## Documentation by Component

### Chezmoi Configuration Management
**Core Documents:**
- [Hybrid Strategy](../architecture/HYBRID-STRATEGY.md) - Strategic approach
- [Templates Reference](TEMPLATES.md) - Template syntax and examples
- [Variables Reference](VARIABLES.md) - Data variables and environment

**Supporting Documents:**
- [Repository Restructure](../guides/REPOSITORY-RESTRUCTURE.md) - Repository organization
- [Project Completion](../guides/PROJECT-COMPLETION.md) - Implementation guidance

### Docker and Containers
**Core Documents:**
- [Container Platform Strategy](../architecture/CONTAINER-PLATFORM-STRATEGY.md) - Docker architecture
- [Infrastructure Reset](../guides/INFRASTRUCTURE-RESET.md) - Installation procedures

**Supporting Documents:**
- [Service Management](../guides/SERVICE-MANAGEMENT.md) - Container service management
- [Commands Reference](COMMANDS.md) - Docker commands

### GPU and CUDA
**Core Documents:**
- [GPU Compute Strategy](../architecture/GPU-COMPUTE-STRATEGY.md) - NVIDIA/CUDA implementation
- [Infrastructure Reset](../guides/INFRASTRUCTURE-RESET.md) - GPU installation procedures

**Supporting Documents:**
- [Variables Reference](VARIABLES.md) - GPU-related variables
- [Commands Reference](COMMANDS.md) - GPU and CUDA commands
- [Troubleshooting](../guides/TROUBLESHOOTING.md) - GPU-specific issues

### Network and Services
**Core Documents:**
- [Network Topology](../architecture/NETWORK-TOPOLOGY.md) - Network design
- [Cluster Architecture](../architecture/CLUSTER-ARCHITECTURE.md) - Service distribution

**Supporting Documents:**
- [Service Management](../guides/SERVICE-MANAGEMENT.md) - Network service management
- [Commands Reference](COMMANDS.md) - Network commands

### Applications (Archon, Ollama)
**Core Documents:**
- [Service Management Guide](../guides/SERVICE-MANAGEMENT.md) - Application service management
- [Container Platform Strategy](../architecture/CONTAINER-PLATFORM-STRATEGY.md) - Archon preservation

**Supporting Documents:**
- [Troubleshooting Guide](../guides/TROUBLESHOOTING.md) - Application-specific issues
- [Commands Reference](COMMANDS.md) - Application management commands

## Documentation Standards

### File Organization
```
docs/
├── architecture/           # System design and strategy
│   ├── CLUSTER-ARCHITECTURE.md
│   ├── GPU-COMPUTE-STRATEGY.md
│   ├── CONTAINER-PLATFORM-STRATEGY.md
│   ├── HYBRID-STRATEGY.md
│   └── NETWORK-TOPOLOGY.md
├── guides/                # Implementation and operational guides
│   ├── INFRASTRUCTURE-RESET.md
│   ├── SERVICE-MANAGEMENT.md
│   ├── REPOSITORY-RESTRUCTURE.md
│   ├── PROJECT-COMPLETION.md
│   └── TROUBLESHOOTING.md
├── reference/             # Technical references and cheat sheets
│   ├── COMMANDS.md
│   ├── VARIABLES.md
│   ├── TEMPLATES.md
│   └── DOCUMENTATION-INDEX.md
├── archive/               # Historical records and decisions
│   ├── decisions/
│   └── migrations/
└── examples/              # Configuration and template examples
    ├── node-configs/
    ├── templates/
    └── playbooks/
```

### Document Metadata
All documents include YAML frontmatter with:
- `title`: Document title
- `description`: Brief description
- `version`: Document version
- `date`: Last update date
- `category`: Document category (architecture, guide, reference, etc.)
- `tags`: Searchable tags
- `applies_to`: Which nodes/components this applies to
- `related`: Links to related documents

### Cross-References
Documents are extensively cross-referenced to enable easy navigation and ensure consistency. Related documents are listed in frontmatter and linked throughout content.

## Search and Discovery

### By Technology
- **Chezmoi**: [Hybrid Strategy](../architecture/HYBRID-STRATEGY.md), [Templates Reference](TEMPLATES.md), [Variables Reference](VARIABLES.md)
- **Docker**: [Container Platform Strategy](../architecture/CONTAINER-PLATFORM-STRATEGY.md), [Commands Reference](COMMANDS.md)
- **NVIDIA/CUDA**: [GPU Compute Strategy](../architecture/GPU-COMPUTE-STRATEGY.md), [Infrastructure Reset](../guides/INFRASTRUCTURE-RESET.md)
- **Ansible**: [Hybrid Strategy](../architecture/HYBRID-STRATEGY.md), [Repository Restructure](../guides/REPOSITORY-RESTRUCTURE.md)
- **Systemd**: [Service Management](../guides/SERVICE-MANAGEMENT.md), [Troubleshooting](../guides/TROUBLESHOOTING.md)

### By Node Type
- **All Nodes**: [Cluster Architecture](../architecture/CLUSTER-ARCHITECTURE.md), [Hybrid Strategy](../architecture/HYBRID-STRATEGY.md)
- **Gateway (cooperator)**: [Network Topology](../architecture/NETWORK-TOPOLOGY.md), DNS and NFS sections
- **GPU Nodes (projector, director)**: [GPU Compute Strategy](../architecture/GPU-COMPUTE-STRATEGY.md), [Container Platform Strategy](../architecture/CONTAINER-PLATFORM-STRATEGY.md)
- **Compute (projector)**: Archon-specific sections in service management
- **ML Platform (director)**: Ollama-specific sections in service management

### By Complexity Level
- **Beginner**: [Cluster Architecture](../architecture/CLUSTER-ARCHITECTURE.md) → [Project Completion](../guides/PROJECT-COMPLETION.md)
- **Intermediate**: [Hybrid Strategy](../architecture/HYBRID-STRATEGY.md) → [Service Management](../guides/SERVICE-MANAGEMENT.md)
- **Advanced**: [Infrastructure Reset](../guides/INFRASTRUCTURE-RESET.md) → [Templates Reference](TEMPLATES.md)
- **Expert**: [Repository Restructure](../guides/REPOSITORY-RESTRUCTURE.md) → Archive documents

## Maintenance and Updates

### Document Lifecycle
1. **Creation**: New documents follow the established template and metadata standards
2. **Review**: Cross-references are validated and related documents updated
3. **Integration**: Documents are added to this index and cross-referenced appropriately
4. **Maintenance**: Regular updates to ensure accuracy and consistency
5. **Archival**: Outdated documents moved to archive with migration records

### Version Control
- All documentation changes tracked in Git
- Meaningful commit messages describe documentation changes
- Related documentation updated together to maintain consistency
- Archive documents preserve historical context

### Quality Assurance
- Internal links validated during updates
- Examples tested against actual cluster configuration
- Command references verified on target systems
- Cross-references maintained and updated

## Contributing to Documentation

### Standards for New Documents
1. Use established YAML frontmatter format
2. Include comprehensive cross-references
3. Follow naming conventions (UPPERCASE.md for primary docs)
4. Add to appropriate category in docs/ hierarchy
5. Update this index with new document

### Updating Existing Documents
1. Update version and date in frontmatter
2. Check and update cross-references
3. Verify commands and examples still work
4. Update related documents if needed
5. Commit with clear description of changes

This documentation index serves as the central navigation hub for all Co-lab cluster documentation, ensuring that information is discoverable, well-organized, and consistently maintained.