#!/bin/bash
# Omni-Config Validation Script
# Purpose: Comprehensive validation of omni-config deployment on cluster nodes
# Usage: bash validate-omniconfig.sh [node_name]
#        If no node_name provided, validates current node
#        Use 'all' to validate all cluster nodes from gateway

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNED=0

# Helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNED++))
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

header() {
    echo
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check if running on all nodes
if [[ "${1:-}" == "all" ]]; then
    header "VALIDATING ALL CLUSTER NODES"
    for node in crtr prtr drtr; do
        echo
        info "Validating $node..."
        ssh "$node" 'bash -s' < "$0"
    done
    exit 0
fi

# Get node information
NODE_NAME="${1:-$(hostname)}"
if [[ "$NODE_NAME" != "$(hostname)" ]]; then
    # Run validation on remote node
    info "Running validation on $NODE_NAME..."
    ssh "$NODE_NAME" 'bash -s' < "$0"
    exit $?
fi

# Start validation
header "OMNI-CONFIG VALIDATION: $(hostname)"
info "Starting validation at $(date)"

# ============================================
# 1. CORE CONFIGURATION FILES
# ============================================
header "1. CORE CONFIGURATION FILES"

# Check essential dotfiles
for file in ~/.profile ~/.bashrc ~/.zshrc; do
    if [[ -f "$file" ]]; then
        if [[ -s "$file" ]]; then
            pass "$file exists and has content"
        else
            fail "$file exists but is empty"
        fi
    else
        fail "$file does not exist"
    fi
done

# Check starship config
if [[ -f ~/.config/starship.toml ]]; then
    pass "~/.config/starship.toml exists"
else
    warn "~/.config/starship.toml missing (optional)"
fi

# Check if files are managed by chezmoi
if command -v chezmoi >/dev/null 2>&1 || [[ -x ~/.local/bin/chezmoi ]]; then
    CHEZMOI_CMD="${HOME}/.local/bin/chezmoi"
    [[ -x "$CHEZMOI_CMD" ]] || CHEZMOI_CMD="chezmoi"

    if $CHEZMOI_CMD managed 2>/dev/null | grep -q "\.profile"; then
        pass "Files managed by chezmoi"
    else
        warn "Files may not be managed by chezmoi"
    fi
else
    warn "Chezmoi not found - cannot check management status"
fi

# ============================================
# 2. SHELL LOADING TESTS
# ============================================
header "2. SHELL LOADING TESTS"

# Test bash loading
if bash -c 'source ~/.bashrc 2>&1' | grep -q "error\|Error\|ERROR"; then
    fail "Bashrc has errors"
else
    pass "Bashrc loads without errors"
fi

# Test zsh loading if available
if command -v zsh >/dev/null 2>&1; then
    if zsh -c 'source ~/.zshrc 2>&1' | grep -q "error\|Error\|ERROR"; then
        fail "Zshrc has errors"
    else
        pass "Zshrc loads without errors"
    fi
else
    info "Zsh not installed - skipping zshrc test"
fi

# Test profile loading
if bash -c 'source ~/.profile 2>&1' | grep -q "error\|Error\|ERROR"; then
    fail "Profile has errors"
else
    pass "Profile loads without errors"
fi

# ============================================
# 3. ENVIRONMENT VARIABLES
# ============================================
header "3. ENVIRONMENT VARIABLES"

# Source profile for tests
source ~/.profile 2>/dev/null || true

# Check core variables
if [[ -n "${NODE_ROLE:-}" ]]; then
    pass "NODE_ROLE set: $NODE_ROLE"
else
    fail "NODE_ROLE not set"
fi

if [[ -n "${ARCH:-}" ]]; then
    pass "ARCH set: $ARCH"
else
    fail "ARCH not set"
fi

# Check tool detection variables
TOOL_VARS=(HAS_EZA HAS_BAT HAS_FD HAS_RG HAS_ZOXIDE HAS_FZF HAS_NNN
           HAS_DELTA HAS_DUST HAS_STARSHIP HAS_ATUIN HAS_FASTFETCH)

DETECTION_OK=true
for var in "${TOOL_VARS[@]}"; do
    if [[ -n "${!var:-}" ]]; then
        if [[ "${!var}" == "1" ]] || [[ "${!var}" == "0" ]]; then
            : # Variable is set correctly (1 or 0)
        else
            warn "$var has unexpected value: ${!var}"
            DETECTION_OK=false
        fi
    else
        warn "$var not set"
        DETECTION_OK=false
    fi
done

if $DETECTION_OK; then
    pass "All HAS_* tool detection variables properly set"
else
    warn "Some tool detection variables have issues"
fi

# ============================================
# 4. MODERN CLI TOOLS
# ============================================
header "4. MODERN CLI TOOLS"

# Check essential modern tools
TOOLS=(eza bat fd rg zoxide fzf starship)
ALT_TOOLS=(batcat fdfind) # Debian alternatives

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        pass "$tool installed"
    elif [[ "$tool" == "bat" ]] && command -v batcat >/dev/null 2>&1; then
        pass "batcat installed (bat alternative)"
    elif [[ "$tool" == "fd" ]] && command -v fdfind >/dev/null 2>&1; then
        pass "fdfind installed (fd alternative)"
    else
        warn "$tool not installed (optional enhancement)"
    fi
done

# Check optional tools
OPTIONAL_TOOLS=(nnn delta dust atuin fastfetch)
for tool in "${OPTIONAL_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        info "$tool installed (optional)"
    fi
done

# ============================================
# 5. ALIASES AND FUNCTIONS
# ============================================
header "5. ALIASES AND FUNCTIONS"

# Test in bash context
BASH_ALIASES_OK=true
bash -c 'source ~/.bashrc 2>/dev/null
    # Navigation aliases
    alias .. >/dev/null 2>&1 || exit 1
    alias ... >/dev/null 2>&1 || exit 1
    # File listing
    alias ll >/dev/null 2>&1 || exit 1
    alias la >/dev/null 2>&1 || exit 1
    # Cluster navigation
    alias nas >/dev/null 2>&1 || exit 1
    alias configs >/dev/null 2>&1 || exit 1
    alias colab >/dev/null 2>&1 || exit 1
' || BASH_ALIASES_OK=false

if $BASH_ALIASES_OK; then
    pass "Bash aliases configured correctly"
else
    fail "Some bash aliases missing"
fi

# Test zsh aliases if available
if command -v zsh >/dev/null 2>&1; then
    ZSH_ALIASES_OK=true
    zsh -c 'source ~/.zshrc 2>/dev/null
        alias .. >/dev/null 2>&1 || exit 1
        alias cluster >/dev/null 2>&1 || exit 1
    ' || ZSH_ALIASES_OK=false

    if $ZSH_ALIASES_OK; then
        pass "Zsh aliases configured correctly"
    else
        warn "Some zsh aliases missing"
    fi
fi

# ============================================
# 6. PATH CONFIGURATION
# ============================================
header "6. PATH CONFIGURATION"

# Check critical paths
PATH_OK=true
if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || [[ ":$PATH:" == *":$HOME/bin:"* ]]; then
    pass "User bin directories in PATH"
else
    warn "User bin directories may not be in PATH"
    PATH_OK=false
fi

if [[ -d "$HOME/.cargo/bin" ]] && [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
    warn "~/.cargo/bin exists but not in PATH"
    PATH_OK=false
fi

if [[ -n "${NVM_DIR:-}" ]] && [[ -d "$NVM_DIR" ]]; then
    pass "NVM_DIR configured: $NVM_DIR"
else
    info "NVM not configured (optional)"
fi

# ============================================
# 7. CHEZMOI STATE
# ============================================
header "7. CHEZMOI STATE"

if command -v chezmoi >/dev/null 2>&1 || [[ -x ~/.local/bin/chezmoi ]]; then
    CHEZMOI_CMD="${HOME}/.local/bin/chezmoi"
    [[ -x "$CHEZMOI_CMD" ]] || CHEZMOI_CMD="chezmoi"

    # Check for uncommitted changes
    if $CHEZMOI_CMD diff 2>/dev/null | grep -q .; then
        warn "Uncommitted chezmoi changes detected"
    else
        pass "No uncommitted chezmoi changes"
    fi

    # Check remote configuration
    if $CHEZMOI_CMD git remote -v 2>/dev/null | grep -q "github.com/IMUR/colab-config"; then
        pass "Chezmoi configured with correct GitHub remote"
    else
        warn "Chezmoi remote may not be configured correctly"
    fi
else
    fail "Chezmoi not installed"
fi

# ============================================
# 8. INTERACTIVE FEATURES
# ============================================
header "8. INTERACTIVE FEATURES"

# Check starship prompt
if command -v starship >/dev/null 2>&1; then
    if starship prompt >/dev/null 2>&1; then
        pass "Starship prompt functional"
    else
        fail "Starship installed but not working"
    fi
else
    warn "Starship not installed (custom prompt unavailable)"
fi

# Check completion systems
if command -v zsh >/dev/null 2>&1; then
    if zsh -c 'autoload -Uz compinit && compinit 2>/dev/null'; then
        pass "Zsh completion system functional"
    else
        warn "Zsh completion may have issues"
    fi
fi

# ============================================
# 9. CLUSTER INFRASTRUCTURE
# ============================================
header "9. CLUSTER INFRASTRUCTURE"

# Check NFS mount
if [[ -d /cluster-nas ]] && ls /cluster-nas >/dev/null 2>&1; then
    pass "NFS mount /cluster-nas accessible"
else
    fail "NFS mount /cluster-nas not accessible"
fi

# Check specific cluster directories
for dir in /cluster-nas/colab /cluster-nas/configs; do
    if [[ -d "$dir" ]]; then
        info "$dir exists"
    else
        warn "$dir missing"
    fi
done

# ============================================
# 10. DEVELOPMENT TOOLS
# ============================================
header "10. DEVELOPMENT TOOLS"

# Check essential development tools
DEV_TOOLS=(git python3 vim)
for tool in "${DEV_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        pass "$tool available"
    else
        fail "$tool not installed"
    fi
done

# Check optional development tools
OPT_DEV_TOOLS=(cargo npm node docker)
for tool in "${OPT_DEV_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        info "$tool available (optional)"
    fi
done

# ============================================
# VALIDATION SUMMARY
# ============================================
header "VALIDATION SUMMARY"

TOTAL=$((PASSED + FAILED + WARNED))
SCORE=$((PASSED * 100 / TOTAL))

echo
info "Node: $(hostname)"
info "Architecture: $(uname -m)"
info "OS: $(uname -s)"
info "Date: $(date)"
echo
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo -e "${YELLOW}Warnings:${NC} $WARNED"
echo -e "${BLUE}Total Checks:${NC} $TOTAL"
echo -e "${BLUE}Score:${NC} ${SCORE}%"
echo

# Determine overall status
if [[ $FAILED -eq 0 ]]; then
    if [[ $WARNED -eq 0 ]]; then
        echo -e "${GREEN}✨ VALIDATION SUCCESSFUL - Perfect Score!${NC}"
        exit 0
    else
        echo -e "${GREEN}✓ VALIDATION PASSED - With minor warnings${NC}"
        exit 0
    fi
else
    if [[ $SCORE -ge 80 ]]; then
        echo -e "${YELLOW}⚠ VALIDATION PARTIAL - Some issues need attention${NC}"
        exit 1
    else
        echo -e "${RED}✗ VALIDATION FAILED - Critical issues detected${NC}"
        exit 2
    fi
fi