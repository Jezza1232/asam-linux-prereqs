#!/bin/bash
source ./common_env.sh

# ============================================================
# ASAM Linux Auto Installer - Stage 2 (Remote Access Setup)
# ============================================================

require_root

zenity --info \
    --title="ASAM Installer - Stage 2" \
    --width=420 \
    --text="Stage 2 will configure remote access:\n\n• Install and enable SSH\n• Ensure XRDP is running\n\nClick OK to continue."

(
    echo "10"
    echo "# Installing OpenSSH server..."
    apt install -y openssh-server >/dev/null 2>&1

    echo "40"
    echo "# Enabling SSH service..."
    systemctl enable --now ssh >/dev/null 2>&1

    echo "70"
    echo "# Ensuring XRDP service is running..."
    systemctl enable --now xrdp >/dev/null 2>&1

    echo "100"
    echo "# Stage 2 complete."
    sleep 1
) | zenity --progress \
    --title="ASAM Installer - Stage 2" \
    --text="Starting remote access setup..." \
    --percentage=0 \
    --width=500 \
    --auto-close

if [[ $? -ne 0 ]]; then
    zenity --error \
        --title="ASAM Installer" \
        --text="Stage 2 was cancelled or failed.\n\nPlease check your network connection and try again."
    exit 1
fi

zenity --info \
    --title="Stage 2 Complete" \
    --width=420 \
    --text="Remote access is now configured.\n\nSSH (port 22) and XRDP (port 3389) are enabled.\n\nClick OK to return to the installer."