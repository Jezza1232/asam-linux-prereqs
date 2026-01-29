#!/bin/bash
source ./common_env.sh

require_root

# Load version dynamically
LOCAL_VERSION=$(cat ./version.txt)

while true; do
    choice=$(zenity --list \
        --title="ASAM Linux Installer v$LOCAL_VERSION" \
        --width=420 --height=300 \
        --column="Action" \
        "Start Installation" \
        "Check for Updates" \
        "Advanced Options" \
        "About" \
        "Exit")

    case "$choice" in

        "Start Installation")
            bash ./asam_stage1_main.sh
            ;;

        "Check for Updates")
            check_for_updates
            # Reload version in case update occurred
            LOCAL_VERSION=$(cat ./version.txt)
            ;;

        "Advanced Options")
            advanced_options_menu
            ;;

        "About")
            zenity --info \
                --title="About ASAM Linux Installer" \
                --width=420 \
                --text="ASAM Linux Installer v$LOCAL_VERSION

Created by Jez.
Powered by Wine, Zenity, and pure wizardry.

This installer prepares Linux to run ASAM (Windows-only) using Wine, XRDP, SSH, firewall automation, and systemd integration."
            ;;

        "Exit")
            exit 0
            ;;

        *)
            # User closed the window
            exit 0
            ;;
    esac
done