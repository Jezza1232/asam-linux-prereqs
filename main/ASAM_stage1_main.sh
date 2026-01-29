#!/bin/bash

# ============================================================
# ASAM Linux Auto Installer - Stage 1 (Main Orchestrator)
# ============================================================

# ============================================================
# LOGGING SETUP
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/asam_stage1_$(date +%Y%m%d_%H%M%S).log"

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages
log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# Function to log errors
log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ERROR: $message" | tee -a "$LOG_FILE"
}

# Function to log command execution with error checking
run_cmd() {
    local cmd="$1"
    local description="$2"
    
    log "Running: $description"
    if eval "$cmd" >> "$LOG_FILE" 2>&1; then
        log "✓ Completed: $description"
        return 0
    else
        log_error "Failed: $description"
        return 1
    fi
}

# ============================================================
# MAIN SETUP
# ============================================================

clear
log "============================================================"
log "        ASAM LINUX AUTO INSTALLER - STAGE 1"
log "============================================================"
log ""
log "Preparing system, installing Wine, .NET, XRDP, SteamCMD,"
log "and setting up the ASAM runtime environment."
log ""
log "Log file: $LOG_FILE"
log ""

# ------------------------------------------------------------
# SUDO CHECK
# ------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    log "Requesting sudo privileges..."
    exec sudo bash "$0" "$@"
fi

# ------------------------------------------------------------
# UPDATE + REPOSITORIES
# ------------------------------------------------------------
log ""
log "[1/8] Updating system and enabling Universe repository..."
run_cmd "add-apt-repository universe -y" "Add universe repository"
run_cmd "apt update -y" "Update apt package lists"
run_cmd "apt upgrade -y" "Upgrade system packages"

# ------------------------------------------------------------
# INSTALL XRDP + REMOTE DESKTOP
# ------------------------------------------------------------
log ""
log "[2/8] Installing XRDP (Remote Desktop)..."
run_cmd "apt install -y xrdp" "Install XRDP"
run_cmd "systemctl enable --now xrdp" "Enable and start XRDP service"

# ------------------------------------------------------------
# INSTALL WINE + WINETRICKS + DEPENDENCIES
# ------------------------------------------------------------
log ""
log "[3/8] Installing Wine, Winetricks, Q4Wine, Winbind..."
run_cmd "dpkg --add-architecture i386" "Add 32-bit architecture support"
run_cmd "apt update -y" "Update with 32-bit support"
run_cmd "apt install -y wine wine64 winetricks q4wine winbind" "Install Wine and tools"

# ------------------------------------------------------------
# INSTALL UNZIP + STEAMCMD
# ------------------------------------------------------------
log ""
log "[4/8] Installing unzip + SteamCMD..."
run_cmd "apt install -y unzip steamcmd" "Install unzip and SteamCMD"

# ------------------------------------------------------------
# RESET WINE PREFIX
# ------------------------------------------------------------
log ""
log "[5/8] Resetting Wine environment..."
run_cmd "wineserver -k 2>/dev/null || true" "Kill existing Wine servers"
run_cmd "rm -rf ~/.wine" "Remove old Wine prefix"
run_cmd "WINEARCH=win64 WINEPREFIX=~/.wine wineboot --init" "Initialize 64-bit Wine prefix"

# ------------------------------------------------------------
# INSTALL .NET 4.8
# ------------------------------------------------------------
log ""
log "[6/8] Installing .NET Framework 4.8 (this may take a while)..."
run_cmd "WINEPREFIX=~/.wine winetricks -q dotnet48" "Install .NET Framework 4.8"

# ------------------------------------------------------------
# APPLY WINE REGISTRY FIXES
# ------------------------------------------------------------
log ""
log "[7/8] Applying Wine registry configuration..."
cat > /tmp/wine_x11_gamma.reg << 'EOF'
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\X11 Driver]
"UseXVidMode"="N"
"UseXRandR"="Y"
EOF

run_cmd "WINEPREFIX=\"\$HOME/.wine\" wine regedit /S /tmp/wine_x11_gamma.reg" "Apply Wine registry settings"
run_cmd "rm /tmp/wine_x11_gamma.reg" "Clean up registry file"
run_cmd "wineserver -k 2>/dev/null || true" "Reset Wine servers"

# ------------------------------------------------------------
# DOWNLOAD ASAM (ZIP VERSION)
# ------------------------------------------------------------
log ""
log "[8/8] Downloading ASAM from Brad's GitHub..."
ASAM_ZIP_URL="https://github.com/CSBrad/ASAM/archive/refs/heads/main.zip"

if run_cmd "wget -O /tmp/asam.zip \"$ASAM_ZIP_URL\"" "Download ASAM zip file"; then
    log "✓ ASAM downloaded successfully"
else
    log_error "Failed to download ASAM"
fi

if run_cmd "unzip -o /tmp/asam.zip -d ~/Desktop" "Extract ASAM"; then
    log "✓ ASAM extracted successfully"
else
    log_error "Failed to extract ASAM"
fi

run_cmd "mv -f ~/Desktop/ASAM-main ~/Desktop/ASAM" "Move ASAM to Desktop"
run_cmd "rm /tmp/asam.zip" "Clean up zip file"

log ""
log "✓ ASAM has been placed on your Desktop."
log ""

# ------------------------------------------------------------
# CALL STAGE 2
# ------------------------------------------------------------
log "------------------------------------------------------------"
log "✓ Stage 1 complete."
log "  Moving to Stage 2: SSH + Remote Desktop Setup..."
log "------------------------------------------------------------"
sleep 2

bash ./ASAM_stage2_remote_access.sh

# ------------------------------------------------------------
# CALL STAGE 3
# ------------------------------------------------------------
log "------------------------------------------------------------"
log "✓ Returning to Stage 1..."
log "  Moving to Stage 3: Firewall + ASAM Finalization..."
log "------------------------------------------------------------"
sleep 2

bash ./ASAM_stage3_firewall_asam.sh

# ------------------------------------------------------------
# DONE
# ------------------------------------------------------------
log ""
log "============================================================"
log "        ASAM LINUX INSTALLATION COMPLETE"
log "============================================================"
log ""
log "✓ ASAM is now installed on your Desktop."
log "  You can launch it via Wine or Remote Desktop."
log ""
log "Installation Summary:"
log "  - Wine 64-bit: ✓ Installed"
log "  - .NET 4.8: ✓ Installed"
log "  - XRDP: ✓ Installed & Running (port 3389)"
log "  - SteamCMD: ✓ Installed"
log "  - ASAM: ✓ Downloaded & Extracted"
log ""
log "Full setup log: $LOG_FILE"
log ""
log "Thank you for using the ASAM Linux Auto Installer."
log ""