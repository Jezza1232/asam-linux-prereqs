#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOG="/var/log/asam_launcher.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG" >/dev/null
}

log "=== ASAM systemd launcher starting ==="

# -----------------------------
# Configurable section
# -----------------------------
ASAM_WINE_PREFIX="/opt/asam-wine-prefix"
ASAM_EXE_PATH="/opt/asam/ASAM.exe"   # adjust if needed
ASAM_WORKDIR="/opt/asam"

# If you want to force a specific user when run from systemd,
# you should set User= in asam.service instead of here.

# -----------------------------
# Validate environment
# -----------------------------
need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log "Missing command: $1"
        exit 1
    fi
}

need_cmd wine64

if [[ ! -f "$ASAM_EXE_PATH" ]]; then
    log "ASAM executable not found at: $ASAM_EXE_PATH"
    exit 1
fi

if [[ ! -d "$ASAM_WORKDIR" ]]; then
    log "ASAM working directory not found at: $ASAM_WORKDIR"
    exit 1
fi

# -----------------------------
# Launch ASAM via Wine
# -----------------------------
export WINEPREFIX="$ASAM_WINE_PREFIX"

log "Using WINEPREFIX: $WINEPREFIX"
log "Launching ASAM from: $ASAM_EXE_PATH"

cd "$ASAM_WORKDIR"

# Run in background, keep logs
nohup wine64 "$ASAM_EXE_PATH" >>"$LOG" 2>&1 &

PID=$!
log "ASAM launched with PID $PID"

log "=== ASAM systemd launcher exiting (process continues in background) ==="
exit 0