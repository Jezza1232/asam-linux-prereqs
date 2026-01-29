#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOG="/var/log/asam_stage2.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | sudo tee -a "$LOG" >/dev/null
}

log "=== Starting ASAM Stage 2 ==="

# -----------------------------
# Validate required commands
# -----------------------------
need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        zenity --error --title="ASAM Stage 2" \
            --text="Required command '$1' is missing.\nInstall it and try again."
        log "Missing command: $1"
        exit 1
    fi
}

need_cmd zenity
need_cmd sudo
need_cmd systemctl

# -----------------------------
# Confirm user wants to proceed
# -----------------------------
zenity --question \
    --title="ASAM Stage 2" \
    --text="Stage 2 will configure remote access (XRDP + SSH).\n\nProceed?"

if [[ $? -ne 0 ]]; then
    log "User cancelled Stage 2"
    exit 0
fi

# -----------------------------
# Helper: run privileged actions
# -----------------------------
run_root() {
    if ! sudo bash -c "$1"; then
        zenity --error --title="ASAM Stage 2" \
            --text="A privileged action failed:\n$1"
        log "FAILED: $1"
        exit 1
    fi
}

# -----------------------------
# Enable SSH
# -----------------------------
log "Enabling SSH service..."
run_root "systemctl enable ssh"
run_root "systemctl restart ssh"

# -----------------------------
# Enable XRDP
# -----------------------------
log "Enabling XRDP service..."
run_root "systemctl enable xrdp"
run_root "systemctl restart xrdp"

# -----------------------------
# Firewall adjustments (optional)
# -----------------------------
zenity --question \
    --title="ASAM Stage 2" \
    --text="Would you like to automatically open XRDP (3389) and SSH (22) in the firewall?"

if [[ $? -eq 0 ]]; then
    log "Opening firewall ports for XRDP + SSH"
    run_root "ufw allow 3389/tcp"
    run_root "ufw allow 22/tcp"
else
    log "User skipped firewall configuration"
fi

# -----------------------------
# Completion message
# -----------------------------
zenity --info \
    --title="ASAM Stage 2 Complete" \
    --text="Stage 2 setup is complete.\nYou may now continue to Stage 3."

log "=== Stage 2 complete ==="
exit 0