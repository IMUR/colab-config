#!/bin/bash
# Omni-Config Change-Aware Validation Script
# Purpose: Track and validate omni-config changes since last update
# Usage: bash validate-omniconfig-changes.sh [--since-last-update|--since DATE|--full]

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# State tracking directory
STATE_DIR="$HOME/.local/state/omniconfig"
LAST_UPDATE_FILE="$STATE_DIR/last_update"
VALIDATION_LOG="$STATE_DIR/validation.log"

# Create state directory if needed
mkdir -p "$STATE_DIR"

# Helper functions
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
change() { echo -e "${MAGENTA}Δ${NC} $1"; }
header() {
    echo
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}════════════════════════════════════════${NC}"
}

# Function to get last update timestamp
get_last_update() {
    if [[ -f "$LAST_UPDATE_FILE" ]]; then
        cat "$LAST_UPDATE_FILE"
    else
        echo "never"
    fi
}

# Function to save current update timestamp
save_update_timestamp() {
    date -Iseconds > "$LAST_UPDATE_FILE"
    echo "$1" >> "$LAST_UPDATE_FILE"
}

# Function to check chezmoi changes
check_chezmoi_changes() {
    local since_commit="${1:-}"

    header "CHECKING CONFIGURATION CHANGES"

    # Check if chezmoi is available
    CHEZMOI_CMD="chezmoi"
    if [[ -x "$HOME/.local/bin/chezmoi" ]]; then
        CHEZMOI_CMD="$HOME/.local/bin/chezmoi"
    elif ! command -v chezmoi >/dev/null 2>&1; then
        error "Chezmoi not found - cannot track changes"
        return 1
    fi

    # Get current state
    info "Fetching latest changes from remote..."
    $CHEZMOI_CMD git -- fetch origin 2>/dev/null || warn "Could not fetch remote changes"

    # Check local modifications
    info "Checking for local modifications..."
    if $CHEZMOI_CMD diff | grep -q .; then
        warn "Uncommitted local changes detected:"
        $CHEZMOI_CMD diff | head -20
        echo
    else
        success "No uncommitted local changes"
    fi

    # Check what changed in repository
    if [[ -n "$since_commit" ]] && [[ "$since_commit" != "never" ]]; then
        info "Changes since last validation ($since_commit):"

        # Get list of changed files
        CHANGED_FILES=$($CHEZMOI_CMD git -- diff --name-only "$since_commit"..HEAD 2>/dev/null || echo "")

        if [[ -n "$CHANGED_FILES" ]]; then
            echo "$CHANGED_FILES" | while read -r file; do
                case "$file" in
                    *bashrc*) change "Bash configuration modified: $file" ;;
                    *zshrc*) change "Zsh configuration modified: $file" ;;
                    *profile*) change "Profile modified: $file" ;;
                    *starship*) change "Starship prompt modified: $file" ;;
                    *.tmpl) change "Template modified: $file" ;;
                    *) change "File modified: $file" ;;
                esac
            done

            # Show commit log
            echo
            info "Recent commits:"
            $CHEZMOI_CMD git -- log --oneline "$since_commit"..HEAD 2>/dev/null | head -10
        else
            success "No configuration changes since last validation"
        fi
    else
        info "First validation run - establishing baseline"
    fi

    # Get current commit hash for tracking
    CURRENT_COMMIT=$($CHEZMOI_CMD git -- rev-parse HEAD 2>/dev/null || echo "unknown")
    echo "$CURRENT_COMMIT"
}

# Function to validate affected components
validate_affected_components() {
    local changes="${1:-}"

    header "TARGETED VALIDATION BASED ON CHANGES"

    # Parse changes and determine what to validate
    VALIDATE_BASH=false
    VALIDATE_ZSH=false
    VALIDATE_PROFILE=false
    VALIDATE_TOOLS=false
    VALIDATE_PROMPT=false

    if [[ -z "$changes" ]] || [[ "$changes" == "all" ]]; then
        # Full validation
        VALIDATE_BASH=true
        VALIDATE_ZSH=true
        VALIDATE_PROFILE=true
        VALIDATE_TOOLS=true
        VALIDATE_PROMPT=true
        info "Performing full validation"
    else
        # Selective validation based on changes
        echo "$changes" | while read -r file; do
            case "$file" in
                *bashrc*) VALIDATE_BASH=true ;;
                *zshrc*) VALIDATE_ZSH=true ;;
                *profile*) VALIDATE_PROFILE=true; VALIDATE_TOOLS=true ;;
                *starship*) VALIDATE_PROMPT=true ;;
                *.tmpl) VALIDATE_BASH=true; VALIDATE_ZSH=true ;;
            esac
        done
        info "Performing targeted validation based on changes"
    fi

    # Run targeted validations
    if $VALIDATE_PROFILE; then
        info "Validating profile and environment..."
        if source ~/.profile 2>/dev/null; then
            success "Profile loads successfully"
            [[ -n "${NODE_ROLE:-}" ]] && success "NODE_ROLE: $NODE_ROLE" || error "NODE_ROLE not set"
            [[ -n "${ARCH:-}" ]] && success "ARCH: $ARCH" || error "ARCH not set"
        else
            error "Profile loading failed"
        fi
    fi

    if $VALIDATE_BASH; then
        info "Validating bash configuration..."
        if bash -c 'source ~/.bashrc 2>&1' | grep -q "error\|Error"; then
            error "Bashrc has errors"
        else
            success "Bashrc validated"
        fi
    fi

    if $VALIDATE_ZSH && command -v zsh >/dev/null 2>&1; then
        info "Validating zsh configuration..."
        if zsh -c 'source ~/.zshrc 2>&1' | grep -q "error\|Error"; then
            error "Zshrc has errors"
        else
            success "Zshrc validated"
        fi
    fi

    if $VALIDATE_TOOLS; then
        info "Validating tool detection..."
        source ~/.profile 2>/dev/null

        # Check tool detection variables
        local tool_count=0
        local detected_count=0

        for var in HAS_EZA HAS_BAT HAS_FD HAS_RG HAS_FZF HAS_STARSHIP; do
            ((tool_count++))
            if [[ "${!var:-}" == "1" ]] || [[ "${!var:-}" == "0" ]]; then
                ((detected_count++))
            fi
        done

        if [[ $detected_count -eq $tool_count ]]; then
            success "All tool detection variables set ($detected_count/$tool_count)"
        else
            warn "Some tool detection issues ($detected_count/$tool_count set)"
        fi
    fi

    if $VALIDATE_PROMPT && command -v starship >/dev/null 2>&1; then
        info "Validating prompt configuration..."
        if starship prompt >/dev/null 2>&1; then
            success "Starship prompt functional"
        else
            error "Starship configuration issue"
        fi
    fi
}

# Function to check synchronization status
check_sync_status() {
    header "SYNCHRONIZATION STATUS"

    CHEZMOI_CMD="chezmoi"
    [[ -x "$HOME/.local/bin/chezmoi" ]] && CHEZMOI_CMD="$HOME/.local/bin/chezmoi"

    # Check if we're behind remote
    info "Checking synchronization with remote..."

    LOCAL_COMMIT=$($CHEZMOI_CMD git -- rev-parse HEAD 2>/dev/null || echo "unknown")
    REMOTE_COMMIT=$($CHEZMOI_CMD git -- rev-parse origin/main 2>/dev/null || echo "unknown")

    if [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]; then
        success "Local configuration up-to-date with remote"
    else
        warn "Local configuration differs from remote"
        info "Local:  $LOCAL_COMMIT"
        info "Remote: $REMOTE_COMMIT"

        # Show what would be updated
        echo
        info "Changes available from remote:"
        $CHEZMOI_CMD git -- log --oneline HEAD..origin/main 2>/dev/null | head -5

        echo
        warn "Run 'chezmoi update' to synchronize"
    fi

    # Check managed files status
    echo
    info "Checking managed files..."
    MANAGED_COUNT=$($CHEZMOI_CMD managed | wc -l)
    success "$MANAGED_COUNT files managed by chezmoi"

    # Check for unmanaged dotfiles that should be managed
    UNMANAGED=""
    for file in ~/.profile ~/.bashrc ~/.zshrc; do
        if [[ -f "$file" ]] && ! $CHEZMOI_CMD managed | grep -q "$(basename $file)"; then
            UNMANAGED="$UNMANAGED $file"
        fi
    done

    if [[ -n "$UNMANAGED" ]]; then
        warn "Unmanaged files that should be managed:$UNMANAGED"
    fi
}

# Function to generate validation report
generate_report() {
    local commit="$1"
    local status="$2"

    header "VALIDATION REPORT"

    # Create report entry
    REPORT_ENTRY="$(date -Iseconds) | Commit: $commit | Status: $status | Node: $(hostname)"

    # Append to log
    echo "$REPORT_ENTRY" >> "$VALIDATION_LOG"

    # Show recent validation history
    info "Recent validation history:"
    tail -5 "$VALIDATION_LOG" 2>/dev/null || echo "  No previous validations"

    # Save state for next run
    save_update_timestamp "$commit"

    echo
    success "Validation complete. State saved for change tracking."
}

# Function to show what would be applied
preview_updates() {
    header "PREVIEW PENDING UPDATES"

    CHEZMOI_CMD="chezmoi"
    [[ -x "$HOME/.local/bin/chezmoi" ]] && CHEZMOI_CMD="$HOME/.local/bin/chezmoi"

    info "Checking what would be updated..."

    # Check diff of what would be applied
    if $CHEZMOI_CMD diff; then
        success "No pending changes to apply"
    else
        warn "The following changes would be applied:"
        $CHEZMOI_CMD diff | head -50

        echo
        info "Run 'chezmoi apply' to apply these changes"
    fi
}

# Main execution
main() {
    local mode="${1:---since-last-update}"

    header "OMNI-CONFIG CHANGE-AWARE VALIDATION"
    info "Node: $(hostname)"
    info "Time: $(date)"

    # Determine validation scope
    case "$mode" in
        --since-last-update)
            LAST_UPDATE=$(get_last_update)
            if [[ "$LAST_UPDATE" == "never" ]]; then
                info "First validation - establishing baseline"
                SINCE_COMMIT=""
            else
                SINCE_COMMIT=$(tail -1 "$LAST_UPDATE_FILE" 2>/dev/null || echo "")
                info "Validating changes since: $LAST_UPDATE"
            fi
            ;;
        --since)
            SINCE_COMMIT="${2:-HEAD~5}"
            info "Validating changes since: $SINCE_COMMIT"
            ;;
        --full)
            SINCE_COMMIT=""
            info "Performing full validation"
            ;;
        --preview)
            preview_updates
            exit 0
            ;;
        --help)
            echo "Usage: $0 [--since-last-update|--since COMMIT|--full|--preview]"
            echo
            echo "Options:"
            echo "  --since-last-update  Check changes since last validation (default)"
            echo "  --since COMMIT       Check changes since specific commit"
            echo "  --full              Perform full validation"
            echo "  --preview           Preview what would be updated"
            echo "  --help              Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $mode"
            exit 1
            ;;
    esac

    # Check for changes
    CURRENT_COMMIT=$(check_chezmoi_changes "$SINCE_COMMIT")

    # Check sync status
    check_sync_status

    # Validate affected components
    if [[ -n "$SINCE_COMMIT" ]]; then
        CHANGED_FILES=$(chezmoi git -- diff --name-only "$SINCE_COMMIT"..HEAD 2>/dev/null || echo "")
        validate_affected_components "$CHANGED_FILES"
    else
        validate_affected_components "all"
    fi

    # Generate report
    generate_report "$CURRENT_COMMIT" "validated"

    # Suggest next steps
    echo
    header "RECOMMENDED ACTIONS"

    CHEZMOI_CMD="chezmoi"
    [[ -x "$HOME/.local/bin/chezmoi" ]] && CHEZMOI_CMD="$HOME/.local/bin/chezmoi"

    if $CHEZMOI_CMD diff | grep -q .; then
        warn "You have uncommitted changes. Consider:"
        echo "  1. Review changes: chezmoi diff"
        echo "  2. Apply changes: chezmoi apply"
        echo "  3. Or revert: chezmoi apply --force"
    fi

    LOCAL=$($CHEZMOI_CMD git -- rev-parse HEAD 2>/dev/null)
    REMOTE=$($CHEZMOI_CMD git -- rev-parse origin/main 2>/dev/null)

    if [[ "$LOCAL" != "$REMOTE" ]]; then
        warn "Your configuration is out of sync. Consider:"
        echo "  1. Update from remote: chezmoi update"
        echo "  2. Or preview first: $0 --preview"
    else
        success "Configuration is synchronized and validated!"
    fi
}

# Run main function
main "$@"