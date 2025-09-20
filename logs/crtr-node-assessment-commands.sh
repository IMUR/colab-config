#!/bin/bash
# System Node.js Assessment Commands for CRTR Node
# Execute these commands when you have SSH access to the cluster

echo "=== SYSTEM NODE.JS ASSESSMENT ON CRTR ==="
echo
echo "1. Checking for system Node at /usr/bin/node:"
if [ -f /usr/bin/node ]; then
    echo "✅ /usr/bin/node exists"
    echo "Version: $(/usr/bin/node --version)"
    
    # Check if it's a binary or symlink
    echo "2. Path type analysis:"
    if [ -L /usr/bin/node ]; then
        echo "📎 /usr/bin/node is a SYMLINK"
        echo "   Points to: $(readlink -f /usr/bin/node)"
    else
        echo "🔧 /usr/bin/node is a BINARY"
    fi
    
    # Extract version number for compatibility check
    NODE_VERSION=$(/usr/bin/node --version | sed 's/v//' | cut -d. -f1)
    echo "3. Version compatibility check:"
    if [ "$NODE_VERSION" -ge 18 ]; then
        echo "✅ Version $NODE_VERSION is adequate for claude-code (≥18.x required)"
    else
        echo "❌ Version $NODE_VERSION is too old for claude-code (≥18.x required)"
    fi
else
    echo "❌ /usr/bin/node does not exist"
fi

echo
echo "4. Checking system npm:"
if [ -f /usr/bin/npm ]; then
    echo "✅ /usr/bin/npm exists"
    echo "Version: $(/usr/bin/npm --version)"
    
    if [ -L /usr/bin/npm ]; then
        echo "📎 /usr/bin/npm is a SYMLINK"
        echo "   Points to: $(readlink -f /usr/bin/npm)"
    else
        echo "🔧 /usr/bin/npm is a BINARY"
    fi
else
    echo "❌ /usr/bin/npm does not exist"
fi

echo
echo "5. Alternative Node installations check:"
echo "Checking for Node in other common locations:"
for path in /usr/local/bin/node /opt/nodejs/bin/node ~/.local/bin/node; do
    if [ -f "$path" ]; then
        echo "📍 Found Node at: $path (version: $($path --version))"
    fi
done

echo
echo "6. Current PATH analysis:"
echo "PATH: $PATH"
echo "Node in PATH: $(which node 2>/dev/null || echo 'Not found')"
echo "NPM in PATH: $(which npm 2>/dev/null || echo 'Not found')"