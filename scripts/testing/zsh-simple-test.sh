#!/bin/bash
# The SIMPLEST POSSIBLE zsh alignment test
# If these 5 things work, everything important works

echo "ZSH TEST: $(hostname)"
echo "=================="

# Test 1: Is zsh the default shell?
echo -n "1. Default shell is zsh: "
[[ $SHELL == */zsh ]] && echo "✅" || echo "❌"

# Test 2: Does PATH include local bins?
echo -n "2. PATH has ~/.local/bin: "
echo $PATH | grep -q .local/bin && echo "✅" || echo "❌"

# Test 3: Do configs point to shared files?
echo -n "3. Using shared configs: "
[[ -L ~/.zshrc && -L ~/.zshenv ]] && echo "✅" || echo "❌"

# Test 4: Do modern tools work?
echo -n "4. Modern CLI tools work: "
command -v eza >/dev/null && command -v starship >/dev/null && echo "✅" || echo "❌"

# Test 5: Does interactive shell have aliases?
echo -n "5. Aliases work (ls→eza): "
zsh -i -c 'alias ls' 2>/dev/null | grep -q eza && echo "✅" || echo "❌"

echo "=================="
