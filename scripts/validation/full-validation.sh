#!/usr/bin/env bash
set -euo pipefail

# Full Validation Script for Colab-Config Repository
# Purpose: Complete validation of all repository components
# Safety: Read-only operations, no system modifications

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validation counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Helper functions
log_check() {
    echo -e "${YELLOW}[CHECK]${NC} $1"
    ((TOTAL_CHECKS++))
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_CHECKS++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED_CHECKS++))
}

header() {
    echo ""
    echo "========================================="
    echo "$1"
    echo "========================================="
}

# Main validation sections

header "Repository Structure Validation"

log_check "Checking required directories..."
for dir in dotfiles ansible services scripts docs .meta; do
    if [[ -d "${REPO_ROOT}/${dir}" ]]; then
        log_pass "Directory exists: ${dir}/"
    else
        log_fail "Missing directory: ${dir}/"
    fi
done

log_check "Checking required files..."
for file in README.md AGENTS.md START-HERE.md structure.yaml .agent-context.json .chezmoiroot; do
    if [[ -f "${REPO_ROOT}/${file}" ]]; then
        log_pass "File exists: ${file}"
    else
        log_fail "Missing file: ${file}"
    fi
done

header "Chezmoi Validation"

log_check "Checking Chezmoi configuration..."
if [[ -f "${REPO_ROOT}/.chezmoiroot" ]]; then
    CHEZMOI_ROOT=$(cat "${REPO_ROOT}/.chezmoiroot")
    if [[ "${CHEZMOI_ROOT}" == "dotfiles" ]]; then
        log_pass "Chezmoi root correctly set to 'dotfiles'"
    else
        log_fail "Chezmoi root incorrect: ${CHEZMOI_ROOT} (expected: dotfiles)"
    fi
else
    log_fail "Missing .chezmoiroot file"
fi

log_check "Checking for Chezmoi templates..."
if ls "${REPO_ROOT}/dotfiles/"*.tmpl >/dev/null 2>&1; then
    log_pass "Chezmoi templates found in dotfiles/"
else
    log_fail "No Chezmoi templates found in dotfiles/"
fi

header "Ansible Validation"

log_check "Checking Ansible structure..."
for dir in playbooks inventory group_vars host_vars; do
    if [[ -d "${REPO_ROOT}/ansible/${dir}" ]]; then
        log_pass "Ansible directory exists: ansible/${dir}/"
    else
        log_fail "Missing Ansible directory: ansible/${dir}/"
    fi
done

log_check "Checking for safety rules..."
if [[ -f "${REPO_ROOT}/ansible/.safety-rules.yml" ]]; then
    log_pass "Ansible safety rules present"
else
    log_fail "Missing ansible/.safety-rules.yml"
fi

if command -v ansible-playbook >/dev/null 2>&1; then
    log_check "Validating Ansible playbook syntax..."
    if ls "${REPO_ROOT}/ansible/playbooks/"*.yml >/dev/null 2>&1; then
        for playbook in "${REPO_ROOT}/ansible/playbooks/"*.yml; do
            if ansible-playbook --syntax-check "${playbook}" >/dev/null 2>&1; then
                log_pass "Valid syntax: $(basename "${playbook}")"
            else
                log_fail "Syntax error: $(basename "${playbook}")"
            fi
        done
    else
        log_pass "No playbooks to validate yet"
    fi
else
    log_check "Ansible not installed - skipping playbook validation"
fi

header "Services Validation"

log_check "Checking Docker Compose files..."
if [[ -f "${REPO_ROOT}/services/docker-compose.yml" ]] || ls "${REPO_ROOT}/services/"*/docker-compose.yml >/dev/null 2>&1; then
    log_pass "Docker Compose files found"
else
    log_fail "No Docker Compose files found"
fi

if command -v docker >/dev/null 2>&1; then
    log_check "Validating Docker Compose syntax..."
    if [[ -f "${REPO_ROOT}/services/docker-compose.yml" ]]; then
        if docker compose -f "${REPO_ROOT}/services/docker-compose.yml" config >/dev/null 2>&1; then
            log_pass "Valid Docker Compose configuration"
        else
            log_fail "Invalid Docker Compose configuration"
        fi
    fi
else
    log_check "Docker not installed - skipping compose validation"
fi

header "Scripts Validation"

log_check "Checking script structure..."
for dir in validation setup deployment; do
    if [[ -d "${REPO_ROOT}/scripts/${dir}" ]]; then
        log_pass "Script directory exists: scripts/${dir}/"
    else
        log_fail "Missing script directory: scripts/${dir}/"
    fi
done

if command -v shellcheck >/dev/null 2>&1; then
    log_check "Running ShellCheck on scripts..."
    while IFS= read -r -d '' script; do
        if shellcheck "${script}" >/dev/null 2>&1; then
            log_pass "Valid shell script: $(basename "${script}")"
        else
            log_fail "ShellCheck errors: $(basename "${script}")"
        fi
    done < <(find "${REPO_ROOT}/scripts" -name "*.sh" -type f -print0)
else
    log_check "ShellCheck not installed - skipping script validation"
fi

header "Documentation Validation"

log_check "Checking documentation structure..."
for dir in guides examples; do
    if [[ -d "${REPO_ROOT}/docs/${dir}" ]]; then
        log_pass "Documentation directory exists: docs/${dir}/"
    else
        log_fail "Missing documentation directory: docs/${dir}/"
    fi
done

log_check "Checking for agent context files..."
for context_file in "${REPO_ROOT}/.agent-context.json" \
                   "${REPO_ROOT}/dotfiles/.agent-context.json" \
                   "${REPO_ROOT}/ansible/.agent-context.json"; do
    if [[ -f "${context_file}" ]]; then
        if command -v jq >/dev/null 2>&1; then
            if jq empty "${context_file}" >/dev/null 2>&1; then
                log_pass "Valid JSON: $(basename "$(dirname "${context_file}")")/.agent-context.json"
            else
                log_fail "Invalid JSON: $(basename "$(dirname "${context_file}")")/.agent-context.json"
            fi
        else
            log_pass "Context file exists: $(basename "$(dirname "${context_file}")")/.agent-context.json"
        fi
    else
        log_fail "Missing: $(basename "$(dirname "${context_file}")")/.agent-context.json"
    fi
done

header "Meta-Management Validation"

log_check "Checking meta-management structure..."
if [[ -d "${REPO_ROOT}/.meta" ]]; then
    log_pass "Meta directory exists"

    if [[ -f "${REPO_ROOT}/.meta/schemas/directory-schema.yml" ]]; then
        log_pass "Directory schema present"
    else
        log_fail "Missing directory schema"
    fi
else
    log_fail "Missing .meta directory"
fi

log_check "Checking for IDE integration..."
if [[ -f "${REPO_ROOT}/.cursorrules" ]]; then
    log_pass "Cursor IDE rules present"
else
    log_fail "Missing .cursorrules file"
fi

# Final summary
header "Validation Summary"

echo "Total checks performed: ${TOTAL_CHECKS}"
echo -e "${GREEN}Passed: ${PASSED_CHECKS}${NC}"
echo -e "${RED}Failed: ${FAILED_CHECKS}${NC}"

if [[ ${FAILED_CHECKS} -eq 0 ]]; then
    echo -e "\n${GREEN}✅ All validation checks passed!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Validation failed with ${FAILED_CHECKS} error(s)${NC}"
    echo "Please review the failures above and fix them before proceeding."
    exit 1
fi
