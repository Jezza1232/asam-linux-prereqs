#!/bin/bash
source ./common_env.sh

# ============================================================
# ASAM Linux Auto Installer - Stage 1 (GUI Orchestrator)
# ============================================================

# ------------------ ROOT FIRST ------------------------------
require_root

# ------------------ FIRST RUN WIZARD ------------------------
first_run_wizard || exit 1

# ------------------ VERSION BANNER --------------------------
LOCAL_VERSION=$(cat ./version.txt)
zenity --info \
  --title="ASAM Linux Installer v$LOCAL_VERSION" \
  --width=420 \
  --text="Welcome to ASAM Linux Installer v$LOCAL_VERSION.\n\nClick OK to begin."

# ------------------ VERSION CHECK ---------------------------
check_for_updates

# ------------------ WELCOME SCREEN --------------------------
zenity --info \
  --title="ASAM Linux Installer" \
  --width=420 \
  --text="This installer will prepare your system for ASAM.\n\nIt will:\n• Install Wine + .NET 4.8\n• Install XRDP + SSH\n• Configure firewall\n• Download and prepare ASAM\n\nClick OK to begin."

if [[ $? -ne 0 ]]; then
    exit 1
fi

# ------------------ MAIN PROGRESS BAR -----------------------
(
    echo "5"
    echo "# Updating system and enabling Universe repository..."
    add-apt-repository universe -y >/dev/null 2>&1
    apt update -y >/dev/null 2>&1
    apt upgrade -y >/dev/null 2>&1

    echo "20"
    echo "# Installing XRDP (Remote Desktop)..."
    apt install -y xrdp >/dev/null 2>&1
    systemctl enable --now xrdp >/dev/null 2>&1

    echo "35"
    echo "# Installing Wine, Winetricks, Q4Wine, Winbind..."
    dpkg --add-architecture i386 >/dev/null 2>&1
    apt update -y >/dev/null 2>&1
    apt install -y wine wine64 winetricks q4wine winbind >/dev/null 2>&1

    echo "50"
    echo "# Installing unzip and SteamCMD..."
    apt install -y unzip steamcmd >/dev/null 2>&1

    echo "60"
    echo "# Resetting Wine environment..."
    wineserver -k 2>/dev/null || true
    rm -rf ~/.wine
    WINEARCH=win64 WINEPREFIX=~/.wine wineboot --init >/dev/null 2>&1

    echo "75"
    echo "# Installing .NET Framework 4.8 (this may take a while)..."
    WINEPREFIX=~/.wine winetricks -q dotnet48 >/dev/null 2>&1

    echo "85"
    echo "# Applying Wine registry configuration..."
    cat > /tmp/wine_x11_gamma.reg << 'EOF'
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\X11 Driver]
"UseXVidMode"="N"
"UseXRandR"="Y"
EOF

    WINEPREFIX="$HOME/.wine" wine regedit /S /tmp/wine_x11_gamma.reg >/dev/null 2>&1
    rm /tmp/wine_x11_gamma.reg
    wineserver -k 2>/dev/null || true

    echo "95"
    echo "# Downloading ASAM from Brad's GitHub to Desktop..."
    ASAM_ZIP_URL="https://github.com/CSBrad/ASAM/archive/refs/heads/main.zip"
    wget -O /tmp/asam.zip "$ASAM_ZIP_URL" >/dev/null 2>&1
    unzip -o /tmp/asam.zip -d ~/Desktop >/dev/null 2>&1
    mv -f ~/Desktop/ASAM-main ~/Desktop/ASAM >/dev/null 2>&1
    rm /tmp/asam.zip

    echo "100"
    echo "# Stage 1 complete."
    sleep 1
) | zenity --progress \
    --title="ASAM Linux Installer - Stage 1" \
    --text="Starting..." \
    --percentage=0 \
    --width=500 \
    --auto-close

if [[ $? -ne 0 ]]; then
    zenity --error \
      --title="ASAM Installer" \
      --text="Stage 1 was cancelled or failed.\n\nPlease review your network connection and try again."
    exit 1
fi

zenity --info \
  --title="Stage 1 Complete" \
  --width=400 \
  --text="Stage 1 completed successfully.\n\nWine, .NET 4.8, XRDP, and ASAM have been prepared.\n\nClick OK to continue to Stage 2 (Remote Access Setup)."

# ------------------ CALL STAGE 2 ----------------------------
bash ./asam_stage2_remote_access.sh
if [[ $? -ne 0 ]]; then
    zenity --error \
      --title="ASAM Installer" \
      --text="Stage 2 failed.\n\nPlease check logs or rerun the installer."
    exit 1
fi

zenity --info \
  --title="Stage 2 Complete" \
  --width=380 \
  --text="SSH and Remote Desktop are now configured.\n\nClick OK to continue to Stage 3 (Firewall + ASAM Finalization)."

# ------------------ CALL STAGE 3 ----------------------------
bash ./asam_stage3_firewall_asam.sh
if [[ $? -ne 0 ]]; then
    zenity --error \
      --title="ASAM Installer" \
      --text="Stage 3 failed.\n\nPlease check logs or rerun the installer."
    exit 1
fi

# ------------------ FINAL GUI MESSAGE -----------------------
zenity --info \
  --title="ASAM Installation Complete" \
  --width=450 \
  --text="ASAM has been successfully installed and configured.\n\nYou can now:\n• Connect via RDP or SSH\n• Launch ASAM from your Desktop icon\n\nThank you for using the ASAM Linux Auto Installer."