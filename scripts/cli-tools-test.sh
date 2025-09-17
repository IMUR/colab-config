#!/bin/bash
# The SIMPLEST POSSIBLE CLI tools alignment test
# Tests all modern CLI tools across cluster

echo "CLI TOOLS TEST: $(hostname)"
echo "=========================="

# Core modern replacements
echo -n "1. eza (ls replacement): "
eza --version >/dev/null 2>&1 && echo "✅" || echo "❌"

echo -n "2. bat (cat replacement): "
(bat --version >/dev/null 2>&1 || batcat --version >/dev/null 2>&1) && echo "✅" || echo "❌"

echo -n "3. fd (find replacement): "
(fd --version >/dev/null 2>&1 || fdfind --version >/dev/null 2>&1) && echo "✅" || echo "❌"

echo -n "4. ripgrep (grep replacement): "
rg --version >/dev/null 2>&1 && echo "✅" || echo "❌"

echo -n "5. dust (du replacement): "
dust --version >/dev/null 2>&1 && echo "✅" || echo "❌"

# Navigation & Shell enhancements
echo -n "6. zoxide (smart cd): "
zoxide --version >/dev/null 2>&1 && echo "✅" || echo "❌"

echo -n "7. fzf (fuzzy finder): "
fzf --version >/dev/null 2>&1 && echo "✅" || echo "❌"

echo -n "8. starship (prompt): "
starship --version >/dev/null 2>&1 && echo "✅" || echo "❌"

echo -n "9. atuin (better history): "
atuin --version >/dev/null 2>&1 && echo "✅" || echo "❌"

# File managers & viewers
echo -n "10. nnn (file manager): "
nnn -V >/dev/null 2>&1 && echo "✅" || echo "❌"

echo -n "11. fastfetch (system info): "
fastfetch --version >/dev/null 2>&1 && echo "✅" || echo "❌"

echo -n "12. tmux (terminal mux): "
tmux -V >/dev/null 2>&1 && echo "✅" || echo "❌"

# Development tools
echo -n "13. git: "
git --version >/dev/null 2>&1 && echo "✅" || echo "❌"

echo -n "14. delta (git diff): "
delta --version >/dev/null 2>&1 && echo "✅" || echo "❌"

echo -n "15. jq (json processor): "
jq --version >/dev/null 2>&1 && echo "✅" || echo "❌"

echo "=========================="