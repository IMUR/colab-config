#!/bin/bash
# UV Cluster Migration Script
# Based on /cluster-nas/documentation/architecture/python_package_management_strategy.md

set -e

NODE_NAME=$(hostname)
echo "=== Starting UV migration on $NODE_NAME ==="

# Function to install UV if not present
install_uv() {
    if ! command -v uv &> /dev/null; then
        echo "Installing UV..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo "UV already installed ($(uv --version))"
    fi
}

# Function to update PATH in shell profile
setup_path() {
    if ! grep -q "/.local/bin" ~/.bashrc; then
        echo "Adding ~/.local/bin to PATH in ~/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    else
        echo "PATH already configured in ~/.bashrc"
    fi
    
    # Ensure PATH is set for current session
    export PATH="$HOME/.local/bin:$PATH"
}

# Function to migrate from pipx
migrate_pipx() {
    if command -v pipx &> /dev/null; then
        echo "Found pipx installation, migrating..."
        
        # Get list of pipx packages
        PACKAGES=$(pipx list 2>/dev/null | grep "package" | awk '{print $2}' || true)
        
        if [ -n "$PACKAGES" ]; then
            echo "Found pipx packages: $PACKAGES"
            
            # Install each package with UV
            for pkg in $PACKAGES; do
                echo "Migrating $pkg from pipx to UV..."
                uv tool install "$pkg" || echo "Warning: Failed to install $pkg"
            done
            
            # Remove pipx packages after successful UV installation
            for pkg in $PACKAGES; do
                echo "Removing pipx package: $pkg"
                pipx uninstall "$pkg" 2>/dev/null || true
            done
            
            # Clean up pipx installation
            echo "Cleaning up pipx..."
            rm -rf ~/.local/pipx
        else
            echo "No pipx packages to migrate"
        fi
    else
        echo "No pipx installation found"
    fi
}

# Function to migrate from pip --user
migrate_pip_user() {
    # Check for pip user packages
    USER_PACKAGES=$(pip list --user 2>/dev/null | grep -v "^Package" | grep -v "^-" | awk '{print $1}' || true)
    
    if [ -n "$USER_PACKAGES" ]; then
        echo "Found pip --user packages: $USER_PACKAGES"
        echo "Warning: These should be reviewed manually"
        echo "Consider: pip freeze --user | xargs pip uninstall -y"
    else
        echo "No pip --user packages found"
    fi
}

# Function to install standard cluster tools
install_cluster_tools() {
    echo "Installing standard cluster tools..."
    
    # Core tools for all nodes
    TOOLS="ansible ansible-lint yamllint ruff"
    
    for tool in $TOOLS; do
        echo "Installing $tool..."
        uv tool install "$tool" || echo "Warning: Failed to install $tool"
    done
    
    # Optional tools based on node role
    case $NODE_NAME in
        *prtr*|*projector*)
            echo "Installing projector-specific tools..."
            # Add projector-specific tools here if needed
            ;;
        *drtr*|*director*)
            echo "Installing director-specific tools..."
            # Add director-specific tools here if needed
            ;;
    esac
}

# Function to clean up broken symlinks
cleanup_symlinks() {
    echo "Cleaning up broken symlinks..."
    find ~/.local/bin -type l -exec test ! -e {} \; -delete 2>/dev/null || true
}

# Function to verify installation
verify_installation() {
    echo "Verifying UV installation..."
    uv tool list
    echo ""
    echo "UV tools installed in: $HOME/.local/share/uv/tools/"
    echo "Executables available in: $HOME/.local/bin/"
}

# Main migration process
main() {
    echo "Node: $NODE_NAME"
    echo "User: $(whoami)"
    echo "Date: $(date)"
    echo ""
    
    # Step 1: Install UV
    install_uv
    
    # Step 2: Setup PATH
    setup_path
    
    # Step 3: Migrate existing installations
    migrate_pipx
    migrate_pip_user
    
    # Step 4: Clean up broken symlinks
    cleanup_symlinks
    
    # Step 5: Install standard tools
    install_cluster_tools
    
    # Step 6: Verify
    verify_installation
    
    echo ""
    echo "=== UV migration completed on $NODE_NAME ==="
    echo "Logout and login again to ensure PATH is loaded"
}

# Run main function
main "$@"