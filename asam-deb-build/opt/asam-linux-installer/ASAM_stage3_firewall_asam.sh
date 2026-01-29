#!/bin/bash
source ./common_env.sh
source ./installer_config.ini

# ============================================================
# ASAM Linux Auto Installer - Stage 3 (Firewall + ASAM Setup)
# ============================================================

require_root

zenity --info \
    --title="ASAM Installer - Stage 3" \
    --width=420 \
    --text="Stage 3 will:\n\n• Configure firewall rules\n• Enable UFW\n• Install Git\n• Create ASAM launchers\n• Optionally enable the ASAM systemd service\n\nClick OK to continue."

(
    echo "10"
    echo "# Configuring firewall rules..."

    # SSH
    ufw allow 22/tcp >/dev/null 2>&1

    # XRDP
    ufw allow 3389/tcp >/dev/null 2>&1

    # ARK ASA ports
    ufw allow 7777/tcp >/dev/null 2>&1
    ufw allow 7778/tcp >/dev/null 2>&1
    ufw allow 27015/tcp >/dev/null 2>&1
    ufw allow 27020/tcp >/dev/null 2>&1

    # Optional extra port
    if [[ "$OPEN_EXTRA_PORT" == "yes" ]]; then
        ufw allow 32330/tcp >/dev/null 2>&1
    fi

    echo "35"
    echo "# Enabling UFW firewall..."
    ufw --force enable >/dev/null 2>&1

    echo "55"
    echo "# Installing Git..."
    apt install -y git >/dev/null 2>&1

    echo "75"
    echo "# Creating ASAM launcher script..."
    cp ./asam_run_launcher.sh "$HOME/Desktop/run_asam.sh"
    chmod +x "$HOME/Desktop/run_asam.sh"

    echo "90"
    echo "# Creating ASAM desktop shortcut..."
    DESKTOP_FILE="$HOME/Desktop/ASAM.desktop"

    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=ASAM
Comment=ASAM Server Manager (via Wine)
Exec=$HOME/Desktop/run_asam.sh
Icon=application-x-wine-extension-exe
Terminal=false
Categories=Game;Utility;
EOF

    chmod +x "$DESKTOP_FILE"

    echo "100"
    echo "# Stage 3 complete."
    sleep 1
) | zenity --progress \
    --title="ASAM Installer - Stage 3" \
    --text="Starting firewall and ASAM setup..." \
    --percentage=0 \
    --width=500 \
    --auto-close

if [[ $? -ne 0 ]]; then
    zenity --error \
        --title="ASAM Installer" \
        --text="Stage 3 was cancelled or failed.\n\nPlease check logs or rerun the installer."
    exit 1
fi

# ------------------ OPTIONAL SYSTEMD SERVICE ------------------
if [[ "$ENABLE_SERVICE" == "yes" ]]; then
    log "Installing ASAM systemd service..."

    cp ./asam.service /etc/systemd/system/asam.service
    systemctl daemon-reload
    systemctl enable --now asam.service

    success "ASAM systemd service enabled."
else
    warn "ASAM systemd service disabled by user choice."
fi

# ------------------ FINAL GUI MESSAGE ------------------------
zenity --info \
    --title="ASAM Installation Complete" \
    --width=450 \
    --text="ASAM installation is complete.\n\nFirewall, SSH, XRDP, and launchers are configured.\n\nYou can now:\n• Connect via RDP or SSH\n• Launch ASAM from your Desktop icon\n• (Optional) ASAM service is running if enabled\n\nThank you for using the ASAM Linux Auto Installer."