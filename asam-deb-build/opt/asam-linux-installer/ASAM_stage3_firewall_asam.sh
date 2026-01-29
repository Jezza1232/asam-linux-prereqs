#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOG="/var/log/asam_stage3.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | sudo tee -a "$LOG" >/dev/null
}

log "=== Starting ASAM Stage 3 ==="

# -----------------------------
# Validate required commands
# -----------------------------
need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        zenity --error --title="ASAM Stage 3" \
            --text="Required command '$1' is missing.\nInstall it and try again."
        log "Missing command: $1"
        exit 1
    fi
}

need_cmd zenity
need_cmd sudo
need_cmd ufw
need_cmd systemctl

# -----------------------------
# Confirm user wants to proceed
# -----------------------------
zenity --question \
    --title="ASAM Stage 3" \
    --text="Stage 3 will configure the firewall and install ASAM prerequisites.\n\nProceed?"

if [[ $? -ne 0 ]]; then
    log "User cancelled Stage 3"
    exit 0
fi

# -----------------------------
# Helper: run privileged actions
# -----------------------------
run_root() {
    if ! sudo bash -c "$1"; then
        zenity --error --title="ASAM Stage 3" \
            --text="A privileged action failed:\n$1"
        log "FAILED: $1"
        exit 1
    fi
}

# -----------------------------
# Firewall configuration
# -----------------------------
log "Configuring firewall rules..."

PORTS=(
    "27015/tcp"   # Game port
    "27015/udp"
    "27016/tcp"   # Query port
    "27016/udp"
    "27020/tcp"   # RCON
    "3389/tcp"    # XRDP
    "22/tcp"      # SSH
)

for p in "${PORTS[@]}"; do
    log "Allowing port $p"
    run_root "ufw allow $p"
done

# Enable UFW if disabled
if sudo ufw status | grep -q "inactive"; then
    zenity --question \
        --title="Enable Firewall" \
        --text="UFW firewall is currently disabled.\nEnable it now?"

    if [[ $? -eq 0 ]]; then
        log "Enabling UFW firewall"
        run_root "ufw enable"
    else
        log "User declined to enable UFW"
    fi
fi

# -----------------------------
# Install ASAM systemd service
# -----------------------------
SERVICE_FILE="$SCRIPT_DIR/asam.service"

if [[ -f "$SERVICE_FILE" ]]; then
    log "Installing ASAM systemd service..."
    run_root "cp '$SERVICE_FILE' /etc/systemd/system/asam.service"
    run_root "systemctl daemon-reload"
    run_root "systemctl enable asam.service"
else
    log "asam.service not found — skipping systemd install"
fi

# -----------------------------
# Completion message
# -----------------------------
zenity --info \
    --title="ASAM Stage 3 Complete" \
    --text="Stage 3 setup is complete.\nYour system is now ready for ASAM."

log "=== Stage 3 complete ==="
exit 0