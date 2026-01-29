#!/bin/bash

# ASAM systemd launcher

export WINEPREFIX="/root/.wine"
export WINEARCH="win64"
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

LOGFILE="/root/asam_systemd.log"
echo "Starting ASAM via systemd at $(date)" >> "$LOGFILE"

# Navigate to ASAM directory
ASAM_DIR="/root/Desktop/ASAM"
ASAM_EXE="$ASAM_DIR/ASAM.exe"

if [[ ! -d "$ASAM_DIR" ]]; then
    echo "ASAM directory not found: $ASAM_DIR" >> "$LOGFILE"
    exit 1
fi

if [[ ! -f "$ASAM_EXE" ]]; then
    echo "ASAM executable not found: $ASAM_EXE" >> "$LOGFILE"
    exit 1
fi

cd "$ASAM_DIR"

# Launch ASAM using Wine64
/usr/bin/wine64 "$ASAM_EXE" >> "$LOGFILE" 2>&1