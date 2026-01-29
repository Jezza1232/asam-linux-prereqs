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
# Optional: ensure repo folder (no recursion)
# -----------------------------

if [[ ! -d "$SCRIPT_DIR/asam-linux-prereqs" ]]; then
    git clone https://github.com/Jezza1232/asam-linux-prereqs.git "$SCRIPT_DIR/asam-linux-prereqs"
fi

# -----------------------------
# Helper: run privileged actions
# -----------------------------

run_root() {
    local script_path="$1"
    local output
    output=$( (sudo --preserve-env=DISPLAY,XAUTHORITY bash "$script_path" 2>&1) || true)
    local exitcode=$?
    if [[ $exitcode -ne 0 ]]; then
        zenity --error --title="ASAM Linux Installer" \
            --text="Stage script failed with exit code $exitcode:\n\n$output"
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
    local repo_dir="$SCRIPT_DIR/asam-linux-prereqs"
    run_root "$repo_dir/ASAM_stage1_main.sh"
}

run_stage2() {
    local repo_dir="$SCRIPT_DIR/asam-linux-prereqs"
    run_root "$repo_dir/ASAM_stage2_remote_access.sh"
}

run_stage3() {
    local repo_dir="$SCRIPT_DIR/asam-linux-prereqs"
    run_root "$repo_dir/ASAM_stage3_firewall_asam.sh"
}

# -----------------------------
# Event loop
# -----------------------------

while true; do
    choice="$(show_main_menu || echo "exit")"

    case "$choice" in
        "stage1")
            run_stage1
            ;;
        "stage2")
            run_stage2
            ;;
        "stage3")
            run_stage3
            ;;
        "exit"|"")
            exit 0
            ;;
        *)
            zenity --error --title="ASAM Linux Installer" \
                --text="Unknown selection: $choice"
            ;;
    esac
done