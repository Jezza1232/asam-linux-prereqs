#!/bin/bash

# ============================================================
# ASAM Linux Auto Installer - Stage 2 (Remote Access)
# ============================================================

echo ""
echo "============================================================"
echo "        STAGE 2: REMOTE ACCESS SETUP"
echo "============================================================"
echo ""

# Must be root (Stage 1 already escalates, but we keep this safe)
if [[ $EUID -ne 0 ]]; then
    echo "Requesting sudo privileges for Stage 2..."
    exec sudo bash "$0" "$@"
fi

# ------------------------------------------------------------
# INSTALL SSH SERVER
# ------------------------------------------------------------
echo "[1/3] Installing OpenSSH server..."
apt install -y openssh-server

echo ""
echo "[2/3] Enabling and starting SSH service..."
systemctl enable --now ssh

# ------------------------------------------------------------
# CONFIRM XRDP STATUS
# (XRDP was installed in Stage 1, here we just ensure it's running)
# ------------------------------------------------------------
echo ""
echo "[3/3] Ensuring XRDP (Remote Desktop) service is running..."
systemctl enable --now xrdp

# ------------------------------------------------------------
# SHOW CONNECTION INFO
# ------------------------------------------------------------
echo ""
echo "------------------------------------------------------------"
echo " Remote Access is now configured:"
echo "------------------------------------------------------------"
echo " - SSH service:        ENABLED (port 22)"
echo " - Remote Desktop:     ENABLED (XRDP on port 3389)"
echo ""
echo "You can now connect to this machine using:"
echo " - SSH client (e.g., PuTTY, terminal):"
echo "       ssh <username>@<server-ip>"
echo ""
echo " - Remote Desktop client (Windows RDP, Remmina, etc.):"
echo "       Connect to: <server-ip>:3389"
echo ""
echo "Tip: You can find this machine's IP with:"
echo "       ip addr show | grep 'inet '"
echo ""
echo "Stage 2 complete. Returning to main installer..."
echo ""