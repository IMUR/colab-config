#!/bin/bash
# Fix OpenWebUI Production Installation
# Migrates from UV cache-based deployment to proper virtual environment
# Based on /cluster-nas/documentation/development/uv_production_analysis.md

set -e

echo "=== Fixing OpenWebUI Production Installation ==="

# Configuration
SERVICE_NAME="open-webui"
INSTALL_DIR="/opt/open-webui"
DATA_DIR="/var/lib/open-webui"
USER="openwebui"

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: This script must be run as root"
        echo "Usage: sudo $0"
        exit 1
    fi
}

# Function to create system user
create_user() {
    if ! id "$USER" &>/dev/null; then
        echo "Creating system user: $USER"
        useradd --system --home-dir "$DATA_DIR" --shell /bin/false "$USER"
    else
        echo "User $USER already exists"
    fi
}

# Function to stop current service
stop_service() {
    echo "Stopping current OpenWebUI service..."
    systemctl --user stop "$SERVICE_NAME" 2>/dev/null || true
    systemctl stop "$SERVICE_NAME" 2>/dev/null || true
    echo "Service stopped"
}

# Function to create proper installation
create_proper_installation() {
    echo "Creating proper OpenWebUI installation..."
    
    # Create directories
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$DATA_DIR"
    
    # Create virtual environment
    echo "Creating virtual environment..."
    uv venv "$INSTALL_DIR/venv"
    
    # Install OpenWebUI in virtual environment
    echo "Installing OpenWebUI..."
    "$INSTALL_DIR/venv/bin/pip" install open-webui
    
    # Set proper ownership
    chown -R "$USER:$USER" "$INSTALL_DIR"
    chown -R "$USER:$USER" "$DATA_DIR"
    
    echo "Installation created at: $INSTALL_DIR/venv"
}

# Function to create systemd service
create_systemd_service() {
    echo "Creating systemd service..."
    
    cat > "/etc/systemd/system/$SERVICE_NAME.service" << EOF
[Unit]
Description=Open WebUI - AI Chat Interface
After=network.target
Wants=network.target

[Service]
Type=exec
ExecStart=$INSTALL_DIR/venv/bin/open-webui serve --port 8080 --host 0.0.0.0
Environment=OLLAMA_BASE_URL=http://localhost:11434
Environment=DATA_DIR=$DATA_DIR
Environment=OPENAI_API_KEY=""
User=$USER
Group=$USER
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

# Security settings
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$DATA_DIR
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    
    echo "Systemd service created"
}

# Function to backup old installation data
backup_old_data() {
    echo "Looking for existing OpenWebUI data..."
    
    # Common data locations
    POSSIBLE_DATA_DIRS=(
        "/home/prtr/.cache/open-webui"
        "/home/prtr/.config/open-webui" 
        "/tmp/open-webui"
    )
    
    for dir in "${POSSIBLE_DATA_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            echo "Found data in: $dir"
            echo "Copying to: $DATA_DIR"
            cp -r "$dir"/* "$DATA_DIR/" 2>/dev/null || true
        fi
    done
    
    # Fix ownership after copying
    chown -R "$USER:$USER" "$DATA_DIR"
}

# Function to enable and start service
start_service() {
    echo "Reloading systemd and starting service..."
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME"
    systemctl start "$SERVICE_NAME"
    
    echo "Checking service status..."
    systemctl status "$SERVICE_NAME" --no-pager || true
}

# Function to verify installation
verify_installation() {
    echo "Verifying installation..."
    
    if [ -f "$INSTALL_DIR/venv/bin/open-webui" ]; then
        echo "✅ OpenWebUI binary found"
    else
        echo "❌ OpenWebUI binary missing"
    fi
    
    if systemctl is-active "$SERVICE_NAME" >/dev/null; then
        echo "✅ Service is running"
    else
        echo "❌ Service is not running"
    fi
    
    echo ""
    echo "Installation details:"
    echo "- Install directory: $INSTALL_DIR"
    echo "- Data directory: $DATA_DIR"
    echo "- Service user: $USER"
    echo "- Service: $SERVICE_NAME.service"
    echo ""
    echo "Access OpenWebUI at: http://$(hostname):8080"
}

# Main process
main() {
    check_root
    
    echo "Starting OpenWebUI production fix..."
    echo "This will:"
    echo "1. Stop current service"
    echo "2. Create proper virtual environment installation"
    echo "3. Create system user and directories"
    echo "4. Create systemd service"
    echo "5. Migrate existing data"
    echo "6. Start new service"
    echo ""
    
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
    
    stop_service
    create_user
    create_proper_installation
    create_systemd_service
    backup_old_data
    start_service
    verify_installation
    
    echo ""
    echo "=== OpenWebUI Production Fix Completed ==="
    echo "The service is now running from a proper virtual environment"
    echo "instead of the UV cache directory."
}

# Run main function
main "$@"
