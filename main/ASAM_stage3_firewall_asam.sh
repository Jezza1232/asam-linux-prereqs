#!/bin/bash

# ============================================================
# ASAM Linux Auto Installer - Stage 3 (Firewall + ASAM Setup)
# ============================================================

echo ""
echo "============================================================"
echo "        STAGE 3: FIREWALL + ASAM FINAL SETUP"
echo "============================================================"
echo ""

# Must be root
if [[ $EUID -ne 0 ]]; then
    echo "Requesting sudo privileges for Stage 3..."
    exec sudo bash "$0" "$@"
fi

# ------------------------------------------------------------
# FIREWALL RULES
# ------------------------------------------------------------
echo "[1/4] Configuring firewall rules..."

# SSH
ufw allow 22/tcp

# Remote Desktop (XRDP)
ufw allow 3389/tcp

# ARK ASA GAME PORTS
ufw allow 7777/tcp
ufw allow 7778/tcp

# ARK ASA QUERY PORT
ufw allow 27015/tcp

# ARK ASA RCON PORT
ufw allow 27020/tcp

# Additional ASA ports (optional future-proofing)
ufw allow 32330/tcp

echo ""
echo "Firewall rules added."

# ------------------------------------------------------------
# ENABLE FIREWALL
# ------------------------------------------------------------
echo ""
echo "[2/4] Enabling UFW firewall..."
ufw --force enable

echo "Firewall is now active."

# ------------------------------------------------------------
# INSTALL GIT
# ------------------------------------------------------------
echo ""
echo "[3/4] Installing Git..."
apt install -y git

# ------------------------------------------------------------
# DOWNLOAD ASAM
# ------------------------------------------------------------
echo ""
echo "[4/4] Downloading ASAM from Brad's GitHub..."

ASAM_ZIP_URL="https://github.com/CSBrad/ASAM/archive/refs/heads/main.zip"

wget -O /tmp/asam.zip "$ASAM_ZIP_URL"
unzip -o /tmp/asam.zip -d ~/Desktop
mv -f ~/Desktop/ASAM-main ~/Desktop/ASAM
rm /tmp/asam.zip

echo ""
echo "ASAM has been installed to your Desktop."
echo ""

# ------------------------------------------------------------
# FINAL SUMMARY
# ------------------------------------------------------------
echo "============================================================"
echo "        ASAM LINUX INSTALLATION COMPLETE"
echo "============================================================"
echo ""
echo "Remote Access:"
echo " - SSH: port 22"
echo " - Remote Desktop (XRDP): port 3389"
echo ""
echo "ARK ASA Ports:"
echo " - Game: 7777 / 7778"
echo " - Query: 27015"
echo " - RCON: 27020"
echo " - Extra: 32330"
echo ""
echo "ASAM Location:"
echo " - ~/Desktop/ASAM"
echo ""
echo "You can now launch ASAM using Wine or via Remote Desktop."
echo ""
echo "Thank you for using the ASAM Linux Auto Installer."
echo ""