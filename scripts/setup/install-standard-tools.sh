#!/bin/bash
# Colab-Config Tool Standardization Script
# Purpose: Ensure identical modern tool availability across all cluster nodes
# Compatible with: Debian 13 (trixie) on ARM64 and x86_64

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Colab-Config Tool Standardization${NC}"
echo -e "${BLUE}Node: $(hostname) ($(uname -m))${NC}"
echo

# Function to check if command exists
has_command() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create symlink safely
create_symlink() {
    local target="$1"
    local link="$2"

    if [[ -f "$target" ]] && [[ ! -e "$link" ]]; then
        sudo ln -s "$target" "$link"
        echo -e "${GREEN}✅ Created symlink: $link → $target${NC}"
    elif [[ -e "$link" ]]; then
        echo -e "${YELLOW}⚠️  Symlink already exists: $link${NC}"
    else
        echo -e "${RED}❌ Source not found: $target${NC}"
        return 1
    fi
}

# Phase 1: Handle Debian package naming quirks
echo -e "${YELLOW}📦 Phase 1: Creating standard tool names${NC}"

# bat (batcat in Debian)
if has_command batcat && ! has_command bat; then
    create_symlink /usr/bin/batcat /usr/local/bin/bat
elif has_command bat; then
    echo -e "${GREEN}✅ bat: already available${NC}"
else
    echo -e "${RED}❌ bat/batcat: not found${NC}"
fi

# fd (fdfind in Debian)
if has_command fdfind && ! has_command fd; then
    create_symlink /usr/bin/fdfind /usr/local/bin/fd
elif has_command fd; then
    echo -e "${GREEN}✅ fd: already available${NC}"
else
    echo -e "${RED}❌ fd/fdfind: not found${NC}"
fi

echo

# Phase 2: Install missing modern tools
echo -e "${YELLOW}🔧 Phase 2: Installing missing tools${NC}"

# Check for cargo (needed for some tools)
if ! has_command cargo; then
    echo -e "${YELLOW}⚠️  Cargo not found - some tools may not be installable${NC}"
fi

# Zoxide (smart cd replacement)
if ! has_command zoxide; then
    echo -e "${BLUE}Installing zoxide...${NC}"
    if has_command cargo; then
        cargo install zoxide
        echo -e "${GREEN}✅ zoxide: installed via cargo${NC}"
    else
        echo -e "${RED}❌ zoxide: cargo required${NC}"
    fi
else
    echo -e "${GREEN}✅ zoxide: already available${NC}"
fi

# Starship (modern prompt)
if ! has_command starship; then
    echo -e "${BLUE}Installing starship...${NC}"
    if curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null 2>&1; then
        echo -e "${GREEN}✅ starship: installed via installer${NC}"
    else
        echo -e "${RED}❌ starship: installation failed${NC}"
    fi
else
    echo -e "${GREEN}✅ starship: already available${NC}"
fi

echo

# Phase 3: Verification
echo -e "${YELLOW}🔍 Phase 3: Tool verification${NC}"

TOOLS=(
    "eza:Modern ls replacement"
    "bat:Better cat with syntax highlighting"
    "fd:Modern find replacement"
    "rg:Fast grep replacement (ripgrep)"
    "fzf:Fuzzy finder"
    "zoxide:Smart cd replacement"
    "nnn:Terminal file manager"
    "atuin:Shell history management"
    "starship:Modern shell prompt"
    "delta:Git diff viewer"
    "jq:JSON processor"
    "htop:Interactive process viewer"
)

echo -e "${BLUE}Standard Tool Availability Report:${NC}"
for tool_desc in "${TOOLS[@]}"; do
    tool="${tool_desc%%:*}"
    desc="${tool_desc#*:}"

    if has_command "$tool"; then
        location=$(command -v "$tool")
        echo -e "${GREEN}✅ $tool${NC} - $desc"
        echo -e "   ${BLUE}→ $location${NC}"
    else
        echo -e "${RED}❌ $tool${NC} - $desc"
        echo -e "   ${RED}→ NOT AVAILABLE${NC}"
    fi
done

echo

# Phase 4: Environment integration
echo -e "${YELLOW}🔄 Phase 4: Shell integration${NC}"

# Add cargo bin to PATH if not already there
if [[ -d "$HOME/.cargo/bin" ]] && [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
    echo -e "${BLUE}Adding cargo bin to PATH for current session${NC}"
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Add local bin to PATH if not already there
if [[ -d "$HOME/.local/bin" ]] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${BLUE}Adding local bin to PATH for current session${NC}"
    export PATH="$HOME/.local/bin:$PATH"
fi

echo -e "${GREEN}🎉 Tool standardization complete for $(hostname)!${NC}"
echo -e "${BLUE}💡 Note: Restart shell or source ~/.profile to ensure PATH updates${NC}"
echo