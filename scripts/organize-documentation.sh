#!/bin/bash
# Documentation Organization Script
# Purpose: Restructure documentation with proper git tracking
# Date: 2025-09-21

set -euo pipefail

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

cd /cluster-nas/colab/colab-config

# Create directory structure
info "Creating documentation directory structure..."
mkdir -p docs/governance
mkdir -p docs/guides  
mkdir -p docs/archive/migrations
mkdir -p docs/archive/stages
success "Directory structure created"

# Move governance documents
info "Moving governance documents..."
if [[ -f "colab-config-strict-rules.md" ]]; then
    git mv colab-config-strict-rules.md docs/governance/STRICT-RULES.md
    success "Moved strict rules to governance/"
fi

# Move guides
info "Moving guide documents..."
if [[ -f "colab-restructure-semantic-guide.md" ]]; then
    git mv colab-restructure-semantic-guide.md docs/guides/RESTRUCTURE-GUIDE.md
    success "Moved restructure guide"
fi

if [[ -f "colab-config-completion-guide.md" ]]; then
    git mv colab-config-completion-guide.md docs/guides/COMPLETION-PATH.md
    success "Moved completion guide"
fi

# Handle duplicate restructure guide
if [[ -f "colab-restructure-semantic-guide (1).md" ]]; then
    # This appears to be a duplicate, archive it
    git mv "colab-restructure-semantic-guide (1).md" docs/archive/restructure-guide-v1.md
    success "Archived duplicate restructure guide"
fi

# Archive migration and stage documents
info "Archiving migration and stage documents..."
for file in CLAUDE-CODE-NVM-MIGRATION.md CRTR-CLAUDE-CODE-ASSESSMENT-REPORT.md migrate-installer.md; do
    if [[ -f "$file" ]]; then
        git mv "$file" docs/archive/migrations/
        success "Archived $file"
    fi
done

for file in STAGE2-VALIDATION-CHECKLIST.md STAGE2-VALIDATION-COMPLETE.md STAGE3-PROGRESS-REPORT.md; do
    if [[ -f "$file" ]]; then
        git mv "$file" docs/archive/stages/
        success "Archived $file"
    fi
done

# Clean up empty doc-.md if it exists
if [[ -f "doc-.md" ]] && [[ ! -s "doc-.md" ]]; then
    git rm doc-.md
    success "Removed empty doc-.md"
fi

# Create governance README
cat > docs/governance/README.md << 'EOF'
# Governance Documentation

This directory contains the rules, standards, and decisions that govern the colab-config project.

## Documents

### 📏 STRICT-RULES.md
Non-negotiable constraints, forbidden actions, and hard requirements for the project.

**Key Sections:**
- Chezmoi configuration constraints
- Directory structure requirements
- Git operation rules
- Tool installation strategy
- Validation requirements

### 🏗️ DESIGN-DECISIONS.md
Architectural choices and their rationale, documenting why certain approaches were chosen.

**Key Topics:**
- Hybrid configuration strategy (Ansible + Chezmoi)
- Node.js environment decisions (System vs NVM)
- Repository structure evolution
- Documentation strategy

## Quick Reference

### Non-Negotiables
- `.chezmoiroot = omni-config` (immutable)
- Chezmoi templates stay at `omni-config/` root
- Always use `git mv` for file moves
- AGENTS.md stays under 30 lines

### Decision Tree
For "where does this file go?" questions, see the Quick Decision Tree in STRICT-RULES.md

## Related Documentation
- [Project README](../../README.md) - Complete project documentation
- [Implementation Guides](../guides/) - How to implement changes
- [trail.yaml](../../trail.yaml) - Machine-readable structure
EOF
success "Created governance README"

# Create guides README
cat > docs/guides/README.md << 'EOF'
# Implementation Guides

This directory contains guides for implementing various aspects of the colab-config project.

## Available Guides

### 🔄 RESTRUCTURE-GUIDE.md
Semantic implementation guide for repository restructuring.

**Covers:**
- Pre-restructure verification
- Phase-by-phase implementation
- Git-aware migration strategies
- Post-restructure validation

### 🎯 COMPLETION-PATH.md
Understanding the path to project completion.

**Topics:**
- Current state assessment
- Three phases of completion
- Critical success factors
- Documentation foundation

## Quick Start

1. **Planning a restructure?** Start with RESTRUCTURE-GUIDE.md
2. **Understanding the big picture?** Read COMPLETION-PATH.md
3. **Need the rules?** Check ../governance/STRICT-RULES.md

## Implementation Principles

- **Preserve functionality** - Nothing should break during changes
- **Maintain history** - Use git mv for all file moves
- **Test incrementally** - Validate after each phase
- **Document changes** - Update relevant documentation

## Related Documentation
- [Governance Rules](../governance/) - Constraints and decisions
- [Project README](../../README.md) - Complete documentation
- [trail.yaml](../../trail.yaml) - Machine-readable structure
EOF
success "Created guides README"

# Create archive README
cat > docs/archive/README.md << 'EOF'
# Archive Documentation

This directory contains historical documentation, completed migrations, and stage reports.

## Directory Structure

### 📁 migrations/
Completed migration documentation including:
- Claude-Code NVM migration plans
- Assessment reports
- Migration instructions

### 📁 stages/
Infrastructure reset stage documentation:
- Stage 2 validation checklists and completion reports
- Stage 3 progress reports
- Historical stage documentation

## Archived Documents

### Migration Documents
- `CLAUDE-CODE-NVM-MIGRATION.md` - NVM to System Node migration plan
- `CRTR-CLAUDE-CODE-ASSESSMENT-REPORT.md` - Node assessment report
- `migrate-installer.md` - Claude migrate-installer documentation

### Stage Documents
- `STAGE2-VALIDATION-CHECKLIST.md` - Stage 2 validation checklist
- `STAGE2-VALIDATION-COMPLETE.md` - Stage 2 completion report
- `STAGE3-PROGRESS-REPORT.md` - Stage 3 GPU & Docker implementation

## Purpose

These documents are preserved for:
1. **Historical reference** - Understanding past decisions
2. **Rollback information** - If we need to reverse changes
3. **Learning** - What worked and what didn't
4. **Audit trail** - Tracking infrastructure evolution

## Note

These documents are no longer actively maintained but are preserved for reference.
For current documentation, see:
- [Project README](../../README.md)
- [Governance](../governance/)
- [Implementation Guides](../guides/)
EOF
success "Created archive README"

info "Documentation restructure complete!"
echo
echo "Next steps:"
echo "1. Review the changes with: git status"
echo "2. Commit with: git commit -m 'refactor: Reorganize documentation structure'"
echo "3. Update any references to moved documents"
echo "4. Remove this script after execution"
