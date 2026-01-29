#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOG="/var/log/asam_stage1.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | sudo tee -a "$LOG" >/dev/null
}

log "=== Starting ASAM Stage 1 ==="

# -----------------------------
# Validate required commands
# -----------------------------
need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        zenity --error --title="ASAM Stage 1" \
            --text="Required command '$1' is missing.\nInstall it and try again."
        log "Missing command: $1"
        exit 1
    fi
}

need_cmd zenity
need_cmd sudo
need_cmd apt

# -----------------------------
# Confirm user wants to proceed
# -----------------------------
zenity --question \
    --title="ASAM Stage 1" \
    --text="Stage 1 will install base dependencies for ASAM.\n\nProceed?"

if [[ $? -ne 0 ]]; then
    log "User cancelled Stage 1"
    exit 0
fi

# -----------------------------
# Install dependencies
# -----------------------------
log "Installing base packages..."

run_root() {
    if ! sudo bash "$1"; then
        zenity --error --title="ASAM Linux Installer" \
            --text="A privileged action failed:\n\n$1"
        exit 1
    fi
}

run_root "apt update -y"
run_root "apt install -y wine64 winbind unzip git xrdp openssh-server"

log "Base packages installed."

# -----------------------------
# Enable XRDP
# -----------------------------
log "Enabling XRDP service..."
run_root "systemctl enable xrdp"
run_root "systemctl restart xrdp"

# -----------------------------
# Completion message
# -----------------------------
zenity --info \
    --title="ASAM Stage 1 Complete" \
    --text="Stage 1 setup is complete.\nYou may now continue to Stage 2."

log "=== Stage 1 complete ==="
exit 0