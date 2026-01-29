#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# -----------------------------
# Basic environment + version
# -----------------------------

VERSION_FILE="$SCRIPT_DIR/Version.txt"
VERSION="unknown"

if [[ -f "$VERSION_FILE" ]]; then
    VERSION="$(cat "$VERSION_FILE" 2>/dev/null || echo "unknown")"
fi

# -----------------------------
# Check for required tools
# -----------------------------

need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        zenity --error --title="ASAM Linux Installer" \
            --text="Required command '$1' is not installed.\n\nPlease install it and try again."
        exit 1
    fi
}

need_cmd zenity
need_cmd git

# -----------------------------
# Helper: run privileged actions
# -----------------------------

run_root() {
    if ! sudo bash -c "$1"; then
        zenity --error --title="ASAM Linux Installer" \
            --text="A privileged action failed:\n\n$1"
        exit 1
    fi
}

# -----------------------------
# Main menu
# -----------------------------

show_main_menu() {
    zenity --list \
        --title="ASAM Linux Installer (v$VERSION)" \
        --column="Action" --column="Description" \
        "stage1" "Run Stage 1: Base setup" \
        "stage2" "Run Stage 2: Remote access" \
        "stage3" "Run Stage 3: Firewall + ASAM" \
        "exit" "Exit installer"
}

run_stage1() {
    local script="$SCRIPT_DIR/ASAM_stage1_main.sh"
    if [[ ! -f "$script" ]]; then
        zenity --error --title="ASAM Linux Installer" \
            --text="Stage 1 script not found:\n$script"
        return
    fi
    run_root "$script"
}

run_stage2() {
    local script="$SCRIPT_DIR/ASAM_stage2_remote_access.sh"
    if [[ ! -f "$script" ]]; then
        zenity --error --title="ASAM Linux Installer" \
            --text="Stage 2 script not found:\n$script"
        return
    fi
    run_root "$script"
}

run_stage3() {
    local script="$SCRIPT_DIR/ASAM_stage3_firewall_asam.sh"
    if [[ ! -f "$script" ]]; then
        zenity --error --title="ASAM Linux Installer" \
            --text="Stage 3 script not found:\n$script"
        return
    fi
    run_root "$script"
}

# -----------------------------
# Event loop
# -----------------------------

while true; do
    choice="$(show_main_menu || echo "exit")"

    case "$choice" in
        "stage1") run_stage1 ;;
        "stage2") run_stage2 ;;
        "stage3") run_stage3 ;;
        "exit"|"") exit 0 ;;
        *)
            zenity --error --title="ASAM Linux Installer" \
                --text="Unknown selection: $choice"
            ;;
    esac
done