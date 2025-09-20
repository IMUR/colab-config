#!/bin/bash

# SSH Non-Interactive Alias and Environment Test
# Tests if our shell configuration fixes work for SSH automation

echo "======================================================"
echo "SSH NON-INTERACTIVE CONFIGURATION TEST"
echo "======================================================"
echo ""

test_node() {
    local node=$1
    echo "Testing $node..."
    echo "----------------------------------------"

    # Test 1: Check if chezmoi is in PATH
    echo -n "1. Chezmoi in PATH: "
    ssh $node 'which chezmoi >/dev/null 2>&1 && echo "✅ PASS" || echo "❌ FAIL"'

    # Test 2: Check environment variables
    echo -n "2. HAS_EZA variable: "
    ssh $node 'bash -c "source ~/.profile && [ \"$HAS_EZA\" = \"1\" ] && echo \"✅ PASS\" || echo \"❌ FAIL (HAS_EZA=$HAS_EZA)\""'

    # Test 3: Check if eza command exists
    echo -n "3. eza command available: "
    ssh $node 'which eza >/dev/null 2>&1 && echo "✅ PASS" || echo "❌ FAIL"'

    # Test 4: Check if bashrc loads without hanging
    echo -n "4. Bashrc loads cleanly: "
    timeout 2 ssh $node 'bash -c "source ~/.bashrc 2>/dev/null && echo \"✅ PASS\" || echo \"❌ FAIL\""' || echo "❌ TIMEOUT"

    # Test 5: Direct command test (simulating automation)
    echo -n "5. Direct eza execution: "
    ssh $node 'eza --version >/dev/null 2>&1 && echo "✅ PASS" || echo "❌ FAIL"'

    echo ""
}

# Test all nodes
for node in prtr drtr; do
    test_node $node
done

echo "======================================================"
echo "SUMMARY"
echo "======================================================"
echo ""
echo "Key findings:"
echo "- If chezmoi is in PATH: Profile PATH modifications work"
echo "- If HAS_EZA=1: Environment variables are set correctly"
echo "- If eza available: Tool is installed on the system"
echo "- If bashrc loads: No infinite loops or hangs"
echo "- If direct execution works: SSH automation is functional"
echo ""
echo "Note: Aliases cannot be tested directly in non-interactive SSH"
echo "because 'alias' is a shell builtin that requires shell context."
echo "However, if the environment variables and PATH work, the"
echo "configurations are loading correctly."