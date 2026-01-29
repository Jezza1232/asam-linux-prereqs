#!/bin/bash

# ============================================================================
# ASAM Automatic Setup Script for Ubuntu Linux
# ============================================================================
# This script automatically sets up ASAM on Ubuntu Linux with Wine support
# Logs are saved to logs/setup.log

# Set up logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/setup_$(date +%Y%m%d_%H%M%S).log"

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages
log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# Function to log errors and exit
log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ERROR: $message" | tee -a "$LOG_FILE"
    exit 1
}

# Function to run commands with logging
run_cmd() {
    local cmd="$1"
    local description="$2"
    
    log "Running: $description"
    if eval "$cmd" >> "$LOG_FILE" 2>&1; then
        log "✓ Completed: $description"
        return 0
    else
        log_error "Failed: $description"
    fi
}

# ============================================================================
# MAIN SETUP SCRIPT
# ============================================================================

log "====== ASAM Ubuntu Setup Started ======"
log "Log file: $LOG_FILE"
log "Starting at $(date)"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log "Requesting sudo privileges..."
    exec sudo bash "$0" "$@"
fi

# Update system repositories
log "====== Step 1: Updating System ======"
run_cmd "apt update" "Update apt package lists"
run_cmd "apt upgrade -y" "Upgrade system packages"
run_cmd "add-apt-repository universe -y" "Add universe repository"
run_cmd "apt update" "Update apt with universe repository"

# Install remote desktop support
log "====== Step 2: Installing Remote Desktop (XRDP) ======"
run_cmd "apt install -y xrdp" "Install XRDP remote desktop"
run_cmd "systemctl enable --now xrdp" "Enable and start XRDP service"
log "XRDP service is now running on port 3389"

# Install Wine and dependencies
log "====== Step 3: Installing Wine and Tools ======"
run_cmd "dpkg --add-architecture i386" "Add 32-bit architecture support"
run_cmd "apt update" "Update with 32-bit support"
run_cmd "apt install -y wine wine64" "Install Wine (32-bit and 64-bit)"
run_cmd "apt install -y q4wine" "Install Q4Wine GUI"
run_cmd "apt install -y winetricks" "Install Wine tricks"
run_cmd "apt install -y winbind" "Install Winbind"

# Install additional tools
log "====== Step 4: Installing Additional Tools ======"
run_cmd "apt install -y unzip wget" "Install unzip and wget"
run_cmd "apt install -y ufw" "Install UFW firewall (if not present)"

# Configure firewall
log "====== Step 5: Configuring Firewall ======"
run_cmd "ufw allow 3389/tcp" "Allow XRDP port (3389)"
run_cmd "ufw allow 7777" "Allow port 7777"
run_cmd "ufw allow 25015" "Allow port 25015"

# Clean and initialize Wine prefix
log "====== Step 6: Setting up Wine Environment ======"
run_cmd "wineserver -k" "Kill existing Wine servers"
run_cmd "rm -rf ~/.wine" "Remove old Wine prefix"
run_cmd "WINEARCH=win64 WINEPREFIX=~/.wine wineboot --init" "Initialize 64-bit Wine prefix"

# Install .NET Framework 4.8
log "====== Step 7: Installing .NET Framework 4.8 ======"
run_cmd "WINEPREFIX=~/.wine winetricks -q dotnet48" "Install .NET Framework 4.8"

# Apply Wine X11 configuration
log "====== Step 8: Configuring Wine X11 Driver ======"
cat > /tmp/wine_x11_gamma.reg << 'REGEOF'
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\X11 Driver]
"UseXVidMode"="N"
"UseXRandR"="Y"
REGEOF

run_cmd "WINEPREFIX=\"$HOME/.wine\" wine regedit /S /tmp/wine_x11_gamma.reg" "Apply Wine registry settings"
run_cmd "rm -f /tmp/wine_x11_gamma.reg" "Clean up temporary registry file"
run_cmd "wineserver -k" "Reset Wine servers"

# Download and setup ASAM
log "====== Step 9: Downloading ASAM ======"
ASAM_ZIP_URL="https://github.com/CSBrad/ASAM/archive/refs/heads/main.zip"
ASAM_DIR="$HOME/Desktop/ASAM"
ASAM_ZIP_PATH="/tmp/asam.zip"

log "Downloading ASAM from: $ASAM_ZIP_URL"
if wget -O "$ASAM_ZIP_PATH" "$ASAM_ZIP_URL" >> "$LOG_FILE" 2>&1; then
    log "✓ ASAM downloaded successfully"
else
    log_error "Failed to download ASAM"
fi

# Extract ASAM
log "====== Step 10: Extracting ASAM ======"
mkdir -p "$HOME/Desktop"
if unzip -o "$ASAM_ZIP_PATH" -d "$HOME/Desktop" >> "$LOG_FILE" 2>&1; then
    log "✓ ASAM extracted successfully"
else
    log_error "Failed to extract ASAM"
fi

# Move ASAM to correct location
if [ -d "$HOME/Desktop/ASAM-main" ]; then
    run_cmd "rm -rf \"$ASAM_DIR\"" "Remove old ASAM directory"
    run_cmd "mv \"$HOME/Desktop/ASAM-main\" \"$ASAM_DIR\"" "Move ASAM to Desktop"
else
    log "Warning: ASAM-main directory not found, checking alternative locations..."
fi

run_cmd "rm -f \"$ASAM_ZIP_PATH\"" "Clean up ASAM zip file"

# Create launcher script
log "====== Step 11: Creating ASAM Launcher Scripts ======"
LAUNCHER_SCRIPT_DESKTOP="$HOME/Desktop/run_asam.sh"
LAUNCHER_SCRIPT_ROOT="$SCRIPT_DIR/launcher"

LAUNCHER_CONTENT='#!/bin/bash
export WINEPREFIX="$HOME/.wine"
export WINEARCH=win64
exec wine "$HOME/Desktop/ASAM/ASAM.exe" "$@"'

echo "$LAUNCHER_CONTENT" > "$LAUNCHER_SCRIPT_DESKTOP"
chmod +x "$LAUNCHER_SCRIPT_DESKTOP"
log "✓ Created launcher script: $LAUNCHER_SCRIPT_DESKTOP"

echo "$LAUNCHER_CONTENT" > "$LAUNCHER_SCRIPT_ROOT"
chmod +x "$LAUNCHER_SCRIPT_ROOT"
log "✓ Created launcher script: $LAUNCHER_SCRIPT_ROOT"

# Create desktop shortcut
log "====== Step 12: Creating Desktop Shortcut ======"
DESKTOP_SHORTCUT="$HOME/Desktop/ASAM.desktop"
cat > "$DESKTOP_SHORTCUT" << 'DESKTOPEOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=ASAM
Comment=ASAM Application
Exec=/home/%USERNAME%/Desktop/run_asam.sh
Icon=application-x-wine-extension-msp
Terminal=false
Categories=Utility;Application;
DESKTOPEOF

chmod +x "$DESKTOP_SHORTCUT"
log "✓ Created desktop shortcut: $DESKTOP_SHORTCUT"

# Final summary
log ""
log "====== ASAM Ubuntu Setup Completed Successfully ======"
log "Installation completed at $(date)"
log ""
log "Summary:"
log "  - XRDP installed and running on port 3389"
log "  - Wine 64-bit configured with .NET 4.8"
log "  - ASAM installed to: $ASAM_DIR"
log "  - Launcher script: $LAUNCHER_SCRIPT_DESKTOP"
log "  - Launcher script: $LAUNCHER_SCRIPT_ROOT"
log "  - Desktop shortcut created"
log ""
log "To run ASAM:"
log "  $LAUNCHER_SCRIPT_DESKTOP"
log "  or click the desktop shortcut: ASAM.desktop"
log ""
log "Full setup log: $LOG_FILE"
log "====== End of Setup ======"
