#!/bin/bash
# Comprehensive Documentation Organization Script
# Purpose: Organize, consolidate, and update all documentation
# Date: 2025-09-21

set -euo pipefail

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
header() {
    echo
    echo -e "${BLUE}════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════${NC}"
}

cd /cluster-nas/colab/colab-config

# Check git status
if ! git diff --quiet || ! git diff --cached --quiet; then
    warn "Uncommitted changes detected. Please commit or stash first."
    git status --short
    exit 1
fi

header "PHASE 1: MOVING GOVERNANCE DOCUMENTS"

# Move strict rules
if [[ -f "colab-config-strict-rules.md" ]]; then
    info "Moving strict rules to governance..."
    git mv colab-config-strict-rules.md docs/governance/STRICT-RULES.md
    success "Moved STRICT-RULES.md"
fi

header "PHASE 2: MOVING GUIDE DOCUMENTS"

# Move restructure guides
if [[ -f "colab-restructure-semantic-guide.md" ]]; then
    info "Moving restructure guide..."
    git mv colab-restructure-semantic-guide.md docs/guides/RESTRUCTURE-GUIDE.md
    success "Moved RESTRUCTURE-GUIDE.md"
fi

if [[ -f "colab-config-completion-guide.md" ]]; then
    info "Moving completion guide..."
    git mv colab-config-completion-guide.md docs/guides/COMPLETION-PATH.md
    success "Moved COMPLETION-PATH.md"
fi

# Archive duplicate restructure guide
if [[ -f "colab-restructure-semantic-guide (1).md" ]]; then
    info "Archiving duplicate restructure guide..."
    git mv "colab-restructure-semantic-guide (1).md" docs/archive/restructure-guide-duplicate.md
    success "Archived duplicate guide"
fi

header "PHASE 3: ARCHIVING MIGRATION DOCUMENTS"

# Move migration documents
for file in CLAUDE-CODE-NVM-MIGRATION.md CRTR-CLAUDE-CODE-ASSESSMENT-REPORT.md migrate-installer.md; do
    if [[ -f "$file" ]]; then
        info "Archiving $file..."
        git mv "$file" docs/archive/migrations/
        success "Archived $file"
    fi
done

header "PHASE 4: ARCHIVING STAGE DOCUMENTS"

# Move stage documents
for file in STAGE2-VALIDATION-CHECKLIST.md STAGE2-VALIDATION-COMPLETE.md STAGE3-PROGRESS-REPORT.md; do
    if [[ -f "$file" ]]; then
        info "Archiving $file..."
        git mv "$file" docs/archive/stages/
        success "Archived $file"
    fi
done

header "PHASE 5: CONSOLIDATING ARCHITECTURE DOCS"

# Move architecture documentation to docs/
if [[ -d "documentation/architecture" ]]; then
    info "Consolidating architecture documentation..."
    
    # Create architecture directory in docs
    mkdir -p docs/architecture
    
    # Move each architecture doc
    for file in documentation/architecture/*.md; do
        if [[ -f "$file" ]]; then
            basename=$(basename "$file")
            if [[ "$basename" != "README.md" ]]; then
                git mv "$file" "docs/architecture/$basename"
                success "Moved $basename to docs/architecture/"
            fi
        fi
    done
    
    # Handle architecture README separately
    if [[ -f "documentation/architecture/README.md" ]]; then
        git mv documentation/architecture/README.md docs/architecture/
        success "Moved architecture README"
    fi
fi

header "PHASE 6: CONSOLIDATING PROCEDURE DOCS"

# Move procedure documentation to docs/
if [[ -d "documentation/procedures" ]]; then
    info "Consolidating procedure documentation..."
    
    # Create procedures directory in docs
    mkdir -p docs/procedures
    
    # Move each procedure doc
    for file in documentation/procedures/*.md; do
        if [[ -f "$file" ]]; then
            basename=$(basename "$file")
            if [[ "$basename" != "README.md" ]]; then
                git mv "$file" "docs/procedures/$basename"
                success "Moved $basename to docs/procedures/"
            fi
        fi
    done
    
    # Handle procedures README
    if [[ -f "documentation/procedures/README.md" ]]; then
        git mv documentation/procedures/README.md docs/procedures/
        success "Moved procedures README"
    fi
fi

header "PHASE 7: CLEANING UP"

# Remove empty doc-.md if it exists
if [[ -f "doc-.md" ]]; then
    info "Removing doc-.md (archived as config-file-standards.md)..."
    git rm doc-.md
    success "Removed doc-.md"
fi

# Remove empty documentation directory
if [[ -d "documentation" ]]; then
    # Check if empty
    if [[ -z "$(ls -A documentation 2>/dev/null)" ]]; then
        rmdir documentation
        success "Removed empty documentation directory"
    fi
fi

header "PHASE 8: CREATING CONSOLIDATED INDICES"

# Create main architecture index
cat > docs/architecture/README.md << 'EOF'
# Architecture Documentation

Comprehensive system architecture and design documentation for the Co-lab cluster.

## Core Documents

### 🏗️ COLAB-CLUSTER-ARCHITECTURE.md
Complete cluster architecture overview including:
- Node specifications and roles
- Network architecture
- Storage architecture (NFS)
- Service distribution
- Hybrid configuration strategy

### 🎮 NVIDIA-CUDA-IMPLEMENTATION-STRATEGY.md
GPU and CUDA deployment strategy:
- Multi-GPU configuration for projector (4x GPUs)
- Single GPU setup for director
- CUDA toolkit deployment
- Container GPU passthrough

### 🐳 DOCKER-CLEAN-REINSTALL-STRATEGY.md
Docker optimization with service preservation:
- Archon preservation procedures
- Clean Docker installation
- nvidia-container-toolkit setup
- Service restoration

## Quick Reference

### Node Architecture
| Node | Role | Hardware | Special Features |
|------|------|----------|------------------|
| crtr | Gateway | Pi5, 16GB | NFS, DNS, Proxy |
| prtr | Compute | x86, 128GB | 4x GPU |
| drtr | ML Platform | x86, 64GB | 1x GPU |

### Configuration Strategy
- **System Level**: Minimal Ansible for infrastructure
- **User Level**: Chezmoi for dotfiles and tools
- **Hybrid Approach**: Right tool for right job

## Related Documentation
- [Procedures](../procedures/) - Implementation procedures
- [Governance](../governance/) - Rules and decisions
- [Main README](../../README.md) - Project overview
EOF
success "Created architecture index"

# Create main procedures index
cat > docs/procedures/README.md << 'EOF'
# Procedure Documentation

Operational procedures and implementation guides for the Co-lab cluster.

## Core Procedures

### 🔄 COMPLETE-INFRASTRUCTURE-RESET-SEQUENCE.md
End-to-end infrastructure reset procedure:
- Three-stage approach
- Service preservation
- Validation checkpoints
- Rollback procedures

### 🛠️ SYSTEMD-SERVICE-MANAGEMENT-ADDENDUM.md
Critical service management during infrastructure operations:
- Archon dual-stack management
- Ollama service preservation
- Service backup and restoration
- Health monitoring

## Implementation Stages

### Stage 1: Complete Removal & Cleaning
- ✅ Completed on all nodes
- NVIDIA and Docker packages removed
- Archon infrastructure preserved

### Stage 2: Unified Configuration Deployment
- ✅ Completed - Chezmoi deployed
- Omni-config active on all nodes
- Validation scripts in place

### Stage 3: Strategic Reinstallation
- 85% Complete
- prtr: ✅ Fully operational
- drtr: ⚠️ Minor Docker config issue

## Related Documentation
- [Architecture](../architecture/) - System design
- [Implementation Guides](../guides/) - How-to guides
- [Stage Reports](../archive/stages/) - Historical progress
EOF
success "Created procedures index"

header "DOCUMENTATION ORGANIZATION COMPLETE!"

echo
info "Summary of changes:"
echo "  • Governance docs → docs/governance/"
echo "  • Guide docs → docs/guides/"
echo "  • Migration docs → docs/archive/migrations/"
echo "  • Stage docs → docs/archive/stages/"
echo "  • Architecture docs → docs/architecture/"
echo "  • Procedure docs → docs/procedures/"
echo
info "Next steps:"
echo "1. Review changes: git status"
echo "2. Add new files: git add docs/"
echo "3. Commit: git commit -m 'refactor: Complete documentation reorganization'"
echo "4. Update any broken internal links"
echo "5. Remove this script after execution"
