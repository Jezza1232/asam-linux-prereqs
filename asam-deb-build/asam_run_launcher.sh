#!/bin/bash
# ASAM launcher wrapper (manual desktop launch)

export WINEPREFIX="$HOME/.wine"
export WINEARCH="win64"
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

ASAM_DIR="$HOME/Desktop/ASAM"
ASAM_EXE="$ASAM_DIR/ASAM.exe"

# Optional: log file for debugging
LOGFILE="$HOME/asam_manual_launch.log"
echo "Launching ASAM manually at $(date)" >> "$LOGFILE"

# Check directory
if [[ ! -d "$ASAM_DIR" ]]; then
    echo "ASAM directory not found: $ASAM_DIR" >> "$LOGFILE"
    exit 1
fi

# Check executable
if [[ ! -f "$ASAM_EXE" ]]; then
    echo "ASAM executable not found: $ASAM_EXE" >> "$LOGFILE"
    exit 1
fi

# Launch ASAM
exec /usr/bin/wine64 "$ASAM_EXE" "$@" >> "$LOGFILE" 2>&1