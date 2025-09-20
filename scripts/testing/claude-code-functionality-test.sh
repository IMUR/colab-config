#!/bin/bash

# Claude-Code Functionality Test Script for CRTR
# Based on Phase 1: Environmental Assessment requirements
# Execute this script on the crtr node to assess current claude-code state

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create timestamped results file
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RESULTS_FILE="/tmp/claude-code-functionality-test-${TIMESTAMP}.md"

echo "# Claude-Code Functionality Test Results" > "$RESULTS_FILE"
echo "**Date**: $(date)" >> "$RESULTS_FILE"
echo "**Node**: $(hostname)" >> "$RESULTS_FILE"
echo "**Test Script Version**: 1.0" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# Function to log both to console and file
log_result() {
    local test_name="$1"
    local status="$2"
    local details="$3"
    
    echo -e "${BLUE}Testing: ${test_name}${NC}"
    echo "## $test_name" >> "$RESULTS_FILE"
    
    if [[ "$status" == "WORKING" ]]; then
        echo -e "${GREEN}✅ WORKING${NC}"
        echo "**Status**: ✅ WORKING" >> "$RESULTS_FILE"
    elif [[ "$status" == "BROKEN" ]]; then
        echo -e "${RED}❌ BROKEN${NC}"
        echo "**Status**: ❌ BROKEN" >> "$RESULTS_FILE"
    elif [[ "$status" == "PARTIAL" ]]; then
        echo -e "${YELLOW}⚠️ PARTIAL${NC}"
        echo "**Status**: ⚠️ PARTIAL" >> "$RESULTS_FILE"
    else
        echo -e "${YELLOW}❓ UNKNOWN${NC}"
        echo "**Status**: ❓ UNKNOWN" >> "$RESULTS_FILE"
    fi
    
    echo "Details: $details"
    echo "**Details**: $details" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo ""
}

# Function to test command execution
test_command() {
    local cmd="$1"
    local timeout_duration="${2:-10}"
    
    if timeout "$timeout_duration" bash -c "$cmd" 2>&1; then
        return 0
    else
        return 1
    fi
}

echo -e "${BLUE}🔍 Starting Claude-Code Functionality Assessment${NC}"
echo -e "${BLUE}Results will be saved to: $RESULTS_FILE${NC}"
echo ""

# Test 1: Basic execution without NVM
echo -e "${BLUE}=== Test 1: Basic Execution (No NVM) ===${NC}"
if command -v claude-code >/dev/null 2>&1; then
    if output=$(claude-code --version 2>&1); then
        log_result "Basic Execution (No NVM)" "WORKING" "Version: $output"
        BASIC_NO_NVM="WORKING"
    else
        log_result "Basic Execution (No NVM)" "BROKEN" "Command exists but version check failed: $output"
        BASIC_NO_NVM="BROKEN"
    fi
else
    log_result "Basic Execution (No NVM)" "BROKEN" "claude-code not found in PATH"
    BASIC_NO_NVM="BROKEN"
fi

# Test 2: Basic execution with NVM environment
echo -e "${BLUE}=== Test 2: Basic Execution (With NVM) ===${NC}"
if [[ -d ~/.nvm && -s ~/.nvm/nvm.sh ]]; then
    if output=$(bash -c "source ~/.nvm/nvm.sh && claude-code --version" 2>&1); then
        log_result "Basic Execution (With NVM)" "WORKING" "Version: $output"
        BASIC_WITH_NVM="WORKING"
    else
        log_result "Basic Execution (With NVM)" "BROKEN" "NVM sourced but claude-code failed: $output"
        BASIC_WITH_NVM="BROKEN"
    fi
else
    log_result "Basic Execution (With NVM)" "BROKEN" "NVM not found or not properly installed"
    BASIC_WITH_NVM="BROKEN"
fi

# Test 3: Search functionality
echo -e "${BLUE}=== Test 3: Search Functionality ===${NC}"
if [[ "$BASIC_NO_NVM" == "WORKING" ]]; then
    if output=$(timeout 30 claude-code search "test query" 2>&1 | head -10); then
        if echo "$output" | grep -q -i "error\|failed\|not found"; then
            log_result "Search Functionality" "BROKEN" "Search command executed but returned errors: $output"
            SEARCH_STATUS="BROKEN"
        else
            log_result "Search Functionality" "WORKING" "Search executed successfully: $(echo "$output" | head -3 | tr '\n' ' ')"
            SEARCH_STATUS="WORKING"
        fi
    else
        log_result "Search Functionality" "BROKEN" "Search command timed out or failed to execute"
        SEARCH_STATUS="BROKEN"
    fi
elif [[ "$BASIC_WITH_NVM" == "WORKING" ]]; then
    if output=$(bash -c "source ~/.nvm/nvm.sh && timeout 30 claude-code search 'test query'" 2>&1 | head -10); then
        if echo "$output" | grep -q -i "error\|failed\|not found"; then
            log_result "Search Functionality" "BROKEN" "Search with NVM executed but returned errors: $output"
            SEARCH_STATUS="BROKEN"
        else
            log_result "Search Functionality" "WORKING" "Search with NVM executed successfully: $(echo "$output" | head -3 | tr '\n' ' ')"
            SEARCH_STATUS="WORKING"
        fi
    else
        log_result "Search Functionality" "BROKEN" "Search with NVM timed out or failed"
        SEARCH_STATUS="BROKEN"
    fi
else
    log_result "Search Functionality" "BROKEN" "Cannot test - basic execution not working"
    SEARCH_STATUS="BROKEN"
fi

# Test 4: Agent detection
echo -e "${BLUE}=== Test 4: Agent Detection ===${NC}"
if [[ "$BASIC_NO_NVM" == "WORKING" ]]; then
    if output=$(timeout 15 claude-code agent list 2>&1); then
        if echo "$output" | grep -q -i "error\|failed\|not found"; then
            log_result "Agent Detection" "BROKEN" "Agent list command executed but returned errors: $output"
            AGENT_STATUS="BROKEN"
        else
            log_result "Agent Detection" "WORKING" "Agent list executed successfully: $(echo "$output" | head -3 | tr '\n' ' ')"
            AGENT_STATUS="WORKING"
        fi
    else
        log_result "Agent Detection" "BROKEN" "Agent list command failed or timed out"
        AGENT_STATUS="BROKEN"
    fi
elif [[ "$BASIC_WITH_NVM" == "WORKING" ]]; then
    if output=$(bash -c "source ~/.nvm/nvm.sh && timeout 15 claude-code agent list" 2>&1); then
        if echo "$output" | grep -q -i "error\|failed\|not found"; then
            log_result "Agent Detection" "BROKEN" "Agent list with NVM executed but returned errors: $output"
            AGENT_STATUS="BROKEN"
        else
            log_result "Agent Detection" "WORKING" "Agent list with NVM executed successfully: $(echo "$output" | head -3 | tr '\n' ' ')"
            AGENT_STATUS="WORKING"
        fi
    else
        log_result "Agent Detection" "BROKEN" "Agent list with NVM failed or timed out"
        AGENT_STATUS="BROKEN"
    fi
else
    log_result "Agent Detection" "BROKEN" "Cannot test - basic execution not working"
    AGENT_STATUS="BROKEN"
fi

# Test 5: Authentication status
echo -e "${BLUE}=== Test 5: Authentication Status ===${NC}"
if [[ "$BASIC_NO_NVM" == "WORKING" ]]; then
    if output=$(timeout 10 claude-code auth status 2>&1); then
        if echo "$output" | grep -q -i "authenticated\|logged in\|valid"; then
            log_result "Authentication Status" "WORKING" "Authentication verified: $output"
            AUTH_STATUS="WORKING"
        elif echo "$output" | grep -q -i "not authenticated\|not logged in\|login required"; then
            log_result "Authentication Status" "NEEDS_REAUTH" "Authentication required: $output"
            AUTH_STATUS="NEEDS_REAUTH"
        else
            log_result "Authentication Status" "BROKEN" "Auth status command returned unexpected output: $output"
            AUTH_STATUS="BROKEN"
        fi
    else
        log_result "Authentication Status" "BROKEN" "Auth status command failed or timed out"
        AUTH_STATUS="BROKEN"
    fi
elif [[ "$BASIC_WITH_NVM" == "WORKING" ]]; then
    if output=$(bash -c "source ~/.nvm/nvm.sh && timeout 10 claude-code auth status" 2>&1); then
        if echo "$output" | grep -q -i "authenticated\|logged in\|valid"; then
            log_result "Authentication Status" "WORKING" "Authentication verified with NVM: $output"
            AUTH_STATUS="WORKING"
        elif echo "$output" | grep -q -i "not authenticated\|not logged in\|login required"; then
            log_result "Authentication Status" "NEEDS_REAUTH" "Authentication required with NVM: $output"
            AUTH_STATUS="NEEDS_REAUTH"
        else
            log_result "Authentication Status" "BROKEN" "Auth status with NVM returned unexpected output: $output"
            AUTH_STATUS="BROKEN"
        fi
    else
        log_result "Authentication Status" "BROKEN" "Auth status with NVM failed or timed out"
        AUTH_STATUS="BROKEN"
    fi
else
    log_result "Authentication Status" "BROKEN" "Cannot test - basic execution not working"
    AUTH_STATUS="BROKEN"
fi

# Generate functionality matrix
echo -e "${BLUE}=== Functionality Matrix ===${NC}"
echo "## Functionality Matrix" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"
echo "| Feature | Status | Details |" >> "$RESULTS_FILE"
echo "|---------|--------|---------|" >> "$RESULTS_FILE"
echo "| Basic Execution (No NVM) | $BASIC_NO_NVM | Command accessible without NVM environment |" >> "$RESULTS_FILE"
echo "| Basic Execution (With NVM) | $BASIC_WITH_NVM | Command accessible with NVM sourced |" >> "$RESULTS_FILE"
echo "| Search Feature | $SEARCH_STATUS | Search functionality test |" >> "$RESULTS_FILE"
echo "| Agent Detection | $AGENT_STATUS | Agent list command test |" >> "$RESULTS_FILE"
echo "| Authentication | $AUTH_STATUS | Authentication status check |" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# Display matrix in terminal
printf "%-25s %-15s %s\n" "Feature" "Status" "Details"
printf "%-25s %-15s %s\n" "------------------------" "---------------" "--------"
printf "%-25s %-15s %s\n" "Basic Execution (No NVM)" "$BASIC_NO_NVM" "Command accessible without NVM"
printf "%-25s %-15s %s\n" "Basic Execution (With NVM)" "$BASIC_WITH_NVM" "Command accessible with NVM sourced"
printf "%-25s %-15s %s\n" "Search Feature" "$SEARCH_STATUS" "Search functionality test"
printf "%-25s %-15s %s\n" "Agent Detection" "$AGENT_STATUS" "Agent list command test"
printf "%-25s %-15s %s\n" "Authentication" "$AUTH_STATUS" "Authentication status check"

# Additional diagnostic information
echo "" >> "$RESULTS_FILE"
echo "## Diagnostic Information" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# Check PATH
echo "### Current PATH" >> "$RESULTS_FILE"
echo "\`\`\`" >> "$RESULTS_FILE"
echo "$PATH" >> "$RESULTS_FILE"
echo "\`\`\`" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# Check Node versions
echo "### Node.js Environment" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

if command -v node >/dev/null 2>&1; then
    echo "**System Node**: $(node --version) ($(which node))" >> "$RESULTS_FILE"
else
    echo "**System Node**: Not found" >> "$RESULTS_FILE"
fi

if [[ -d ~/.nvm && -s ~/.nvm/nvm.sh ]]; then
    NVM_NODE=$(bash -c "source ~/.nvm/nvm.sh && node --version && which node" 2>/dev/null || echo "Not available")
    echo "**NVM Node**: $NVM_NODE" >> "$RESULTS_FILE"
else
    echo "**NVM Node**: NVM not installed" >> "$RESULTS_FILE"
fi

# Check claude-code installation details
echo "" >> "$RESULTS_FILE"
echo "### Claude-Code Installation Details" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

if command -v claude-code >/dev/null 2>&1; then
    CLAUDE_PATH=$(which claude-code)
    echo "**Installation Path**: $CLAUDE_PATH" >> "$RESULTS_FILE"
    
    if [[ -f "$CLAUDE_PATH" ]]; then
        SHEBANG=$(head -1 "$CLAUDE_PATH" 2>/dev/null || echo "Cannot read shebang")
        echo "**Shebang**: $SHEBANG" >> "$RESULTS_FILE"
    fi
else
    echo "**Installation Path**: Not found in PATH" >> "$RESULTS_FILE"
fi

# Check for configuration files
echo "" >> "$RESULTS_FILE"
echo "### Configuration Files" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

if [[ -d ~/.claude ]]; then
    echo "**~/.claude directory**: Present" >> "$RESULTS_FILE"
    ls -la ~/.claude >> "$RESULTS_FILE" 2>/dev/null || echo "Cannot list contents" >> "$RESULTS_FILE"
else
    echo "**~/.claude directory**: Not found" >> "$RESULTS_FILE"
fi

if [[ -d ~/.config/claude ]]; then
    echo "**~/.config/claude directory**: Present" >> "$RESULTS_FILE"
else
    echo "**~/.config/claude directory**: Not found" >> "$RESULTS_FILE"
fi

echo ""
echo -e "${GREEN}✅ Assessment complete!${NC}"
echo -e "${BLUE}Results saved to: $RESULTS_FILE${NC}"
echo -e "${BLUE}Copy this file to the project logs directory for reference.${NC}"

# Summary recommendation
echo "" >> "$RESULTS_FILE"
echo "## Migration Recommendation" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

if [[ "$BASIC_NO_NVM" == "WORKING" && "$SEARCH_STATUS" == "WORKING" && "$AGENT_STATUS" == "WORKING" ]]; then
    echo "✅ **No migration needed** - claude-code is working properly without NVM dependency" >> "$RESULTS_FILE"
    echo -e "${GREEN}✅ No migration needed - claude-code is working properly${NC}"
elif [[ "$BASIC_WITH_NVM" == "WORKING" && "$BASIC_NO_NVM" == "BROKEN" ]]; then
    echo "⚠️ **Migration recommended** - claude-code only works with NVM environment" >> "$RESULTS_FILE"
    echo -e "${YELLOW}⚠️ Migration recommended - claude-code depends on NVM environment${NC}"
else
    echo "🚨 **Investigation required** - claude-code has significant functionality issues" >> "$RESULTS_FILE"
    echo -e "${RED}🚨 Investigation required - claude-code has significant issues${NC}"
fi

echo ""
echo "Run this command to copy results to project logs:"
echo "cp $RESULTS_FILE /cluster-nas/colab/colab-config/logs/claude-code-functionality-test-${TIMESTAMP}.md"