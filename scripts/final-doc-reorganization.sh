#!/bin/bash
# Final Documentation Reorganization Script
# Purpose: Execute all git moves to reorganize documentation
# Date: 2025-09-21
# IMPORTANT: Run this script only once after reviewing changes

set -euo pipefail

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
header() {
    echo
    echo -e "${CYAN}════════════════════════════════════════════${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}════════════════════════════════════════════${NC}"
}

cd /cluster-nas/colab/colab-config

# Check git status
header "PRE-FLIGHT CHECK"
if ! git diff --quiet || ! git diff --cached --quiet; then
    warn "Uncommitted changes detected!"
    git status --short
    echo
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Aborting. Please commit or stash changes first."
        exit 1
    fi
fi

header "DOCUMENTATION REORGANIZATION"
info "This script will reorganize all documentation files."
echo "The following operations will be performed:"
echo
echo "  GOVERNANCE → docs/governance/"
echo "    • colab-config-strict-rules.md → STRICT-RULES.md"
echo
echo "  GUIDES → docs/guides/"
echo "    • colab-restructure-semantic-guide.md → RESTRUCTURE-GUIDE.md"
echo "    • colab-config-completion-guide.md → COMPLETION-PATH.md"
echo
echo "  ARCHIVE → docs/archive/"
echo "    • Migration documents (3 files)"
echo "    • Stage documents (3 files)"
echo "    • Duplicate guide"
echo
echo "  CONSOLIDATE → docs/"
echo "    • architecture/ (from documentation/)"
echo "    • procedures/ (from documentation/)"
echo
echo "  CLEANUP"
echo "    • Remove doc-.md (archived as config-file-standards.md)"
echo "    • Remove empty documentation/ directory"
echo
read -p "Proceed with reorganization? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    info "Reorganization cancelled."
    exit 0
fi

# Track success
MOVES_COMPLETED=0
MOVES_FAILED=0

# Function to safely move files
safe_git_mv() {
    local source="$1"
    local dest="$2"
    
    if [[ -f "$source" ]]; then
        if git mv "$source" "$dest" 2>/dev/null; then
            success "Moved: $(basename "$source") → $dest"
            ((MOVES_COMPLETED++))
        else
            error "Failed to move: $source"
            ((MOVES_FAILED++))
        fi
    else
        warn "Not found: $source (skipping)"
    fi
}

header "PHASE 1: GOVERNANCE DOCUMENTS"
safe_git_mv "colab-config-strict-rules.md" "docs/governance/STRICT-RULES.md"

header "PHASE 2: GUIDE DOCUMENTS"
safe_git_mv "colab-restructure-semantic-guide.md" "docs/guides/RESTRUCTURE-GUIDE.md"
safe_git_mv "colab-config-completion-guide.md" "docs/guides/COMPLETION-PATH.md"
safe_git_mv "colab-restructure-semantic-guide (1).md" "docs/archive/restructure-guide-duplicate.md"

header "PHASE 3: MIGRATION DOCUMENTS"
safe_git_mv "CLAUDE-CODE-NVM-MIGRATION.md" "docs/archive/migrations/CLAUDE-CODE-NVM-MIGRATION.md"
safe_git_mv "CRTR-CLAUDE-CODE-ASSESSMENT-REPORT.md" "docs/archive/migrations/CRTR-CLAUDE-CODE-ASSESSMENT-REPORT.md"
safe_git_mv "migrate-installer.md" "docs/archive/migrations/migrate-installer.md"

header "PHASE 4: STAGE DOCUMENTS"
safe_git_mv "STAGE2-VALIDATION-CHECKLIST.md" "docs/archive/stages/STAGE2-VALIDATION-CHECKLIST.md"
safe_git_mv "STAGE2-VALIDATION-COMPLETE.md" "docs/archive/stages/STAGE2-VALIDATION-COMPLETE.md"
safe_git_mv "STAGE3-PROGRESS-REPORT.md" "docs/archive/stages/STAGE3-PROGRESS-REPORT.md"

header "PHASE 5: ARCHITECTURE CONSOLIDATION"
if [[ -d "documentation/architecture" ]]; then
    info "Moving architecture documentation..."
    mkdir -p docs/architecture
    
    for file in documentation/architecture/*.md; do
        if [[ -f "$file" ]]; then
            basename=$(basename "$file")
            safe_git_mv "$file" "docs/architecture/$basename"
        fi
    done
fi

header "PHASE 6: PROCEDURES CONSOLIDATION"
if [[ -d "documentation/procedures" ]]; then
    info "Moving procedure documentation..."
    mkdir -p docs/procedures
    
    for file in documentation/procedures/*.md; do
        if [[ -f "$file" ]]; then
            basename=$(basename "$file")
            safe_git_mv "$file" "docs/procedures/$basename"
        fi
    done
fi

header "PHASE 7: CLEANUP"
if [[ -f "doc-.md" ]]; then
    info "Removing doc-.md (already archived)..."
    if git rm doc-.md 2>/dev/null; then
        success "Removed doc-.md"
        ((MOVES_COMPLETED++))
    else
        error "Failed to remove doc-.md"
        ((MOVES_FAILED++))
    fi
fi

# Remove empty documentation directories
for dir in documentation/architecture documentation/procedures documentation; do
    if [[ -d "$dir" ]] && [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
        if rmdir "$dir" 2>/dev/null; then
            success "Removed empty directory: $dir"
        fi
    fi
done

header "REORGANIZATION COMPLETE"
echo
info "Summary:"
echo "  ✅ Successful moves: $MOVES_COMPLETED"
if [[ $MOVES_FAILED -gt 0 ]]; then
    echo "  ❌ Failed moves: $MOVES_FAILED"
fi
echo
info "Next steps:"
echo "1. Review changes: git status"
echo "2. Stage new files: git add docs/ trail.yaml AGENTS.md"
echo "3. Commit changes:"
echo "   git commit -m 'refactor: Complete documentation reorganization"
echo ""
echo "   - Move governance docs to docs/governance/"
echo "   - Move guides to docs/guides/"
echo "   - Archive migration and stage documents"
echo "   - Consolidate architecture and procedures"
echo "   - Create trail.yaml for machine-readable navigation"
echo "   - Add minimal AGENTS.md for AI runtime'"
echo
echo "4. Update any remaining broken links in documents"
echo "5. Delete organization scripts after verification"
