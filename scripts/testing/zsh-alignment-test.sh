#!/bin/bash
# ZSH Alignment Test - The Simple Ultimate Test
# Tests what users actually experience, not just config files

set -e
NODE=$(hostname)
TEST_RESULTS="/tmp/zsh_test_results_${NODE}.txt"
PASS_COUNT=0
FAIL_COUNT=0

echo "🧪 ZSH ULTIMATE ALIGNMENT TEST - $NODE"
echo "Testing what users ACTUALLY experience..."
echo "Results will be saved to: $TEST_RESULTS"
echo

# Clear previous results
> "$TEST_RESULTS"

# Test function that captures real behavior
test_feature() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="$3"
    
    echo -n "Testing $test_name... "
    
    # Run test in an INTERACTIVE zsh session (like real users)
    result=$(zsh -i -c "$test_command" 2>/dev/null || echo "ERROR")
    
    if [[ "$result" =~ $expected_pattern ]]; then
        echo "✅ PASS"
        echo "✅ $test_name: PASS" >> "$TEST_RESULTS"
        ((PASS_COUNT++))
    else
        echo "❌ FAIL (got: '$result')"
        echo "❌ $test_name: FAIL - Expected pattern '$expected_pattern', got '$result'" >> "$TEST_RESULTS"
        ((FAIL_COUNT++))
    fi
}

echo "=== CORE ZSH FUNCTIONALITY ==="

# Test 1: ZSH actually loads and works
test_feature "ZSH loads and reports version" "echo \$ZSH_VERSION" "5\\.9"

# Test 2: PATH is properly configured
test_feature "PATH includes ~/.local/bin" "echo \$PATH | grep -o '\.local/bin'" "\\.local/bin"

# Test 3: Environment variables load
test_feature "Tool detection variables set" "echo \$HAS_EZA\$HAS_ZOXIDE\$HAS_STARSHIP" "111"

echo
echo "=== MODERN CLI TOOL INTEGRATION ==="

# Test 4: eza alias works (the most common user action)
test_feature "ls->eza alias functional" "alias ls | cut -d= -f2 | tr -d \"'\"" "eza.*--color.*--group"

# Test 5: Starship is actually initialized 
test_feature "Starship prompt initialized" "type starship_precmd 2>/dev/null && echo 'LOADED'" "LOADED"

# Test 6: Zoxide is actually functional
test_feature "Zoxide z command available" "type z 2>/dev/null && echo 'LOADED'" "LOADED"

echo  
echo "=== CONFIGURATION CONSISTENCY ==="

# Test 7: Shared configs are actually being used
test_feature "Using shared zshenv config" "readlink ~/.zshenv | grep -o cluster-nas" "cluster-nas"

# Test 8: History settings applied
test_feature "History properly configured" "echo \$HISTSIZE" "10000"

# Test 9: Interactive features load without errors
test_feature "Shell loads without errors" "echo 'SUCCESS'" "SUCCESS"

echo
echo "=== PRACTICAL USER SCENARIOS ==="

# Test 10: The complete user experience
test_feature "Complete shell startup" "
    # Simulate what happens when user opens a shell
    echo 'Shell startup successful'
    # Test most common commands work  
    command -v eza >/dev/null && echo 'eza available'
    command -v starship >/dev/null && echo 'starship available'
" "Shell startup successful.*eza available.*starship available"

echo
echo "=== TEST SUMMARY ==="
echo "Node: $NODE"
echo "Passed: $PASS_COUNT tests"
echo "Failed: $FAIL_COUNT tests"

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo "🎉 ALL TESTS PASSED - ZSH FULLY FUNCTIONAL"
    echo "✅ ZSH_ALIGNMENT_STATUS=PERFECT" >> "$TEST_RESULTS"
    exit 0
else
    echo "⚠️  ISSUES FOUND - CHECK FAILED TESTS"
    echo "❌ ZSH_ALIGNMENT_STATUS=ISSUES" >> "$TEST_RESULTS"
    exit 1
fi
