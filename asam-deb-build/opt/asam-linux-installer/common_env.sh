#!/bin/bash

# ============================================================
# Shared Environment for ASAM Linux Installer
# ============================================================

# ------------------ COLORS ------------------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
RESET="\e[0m"

# ------------------ LOGGING ------------------
log() {
    echo -e "${CYAN}[*]${RESET} $1"
}

success() {
    echo -e "${GREEN}[✓]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[!]${RESET} $1"
}

error() {
    echo -e "${RED}[X]${RESET} $1"
}

# ------------------ ZENITY CHECK ------------------
if ! command -v zenity &> /dev/null; then
    apt update -y >/dev/null 2>&1
    apt install -y zenity >/dev/null 2>&1
fi

# ------------------ ADVANCED OPTIONS MENU ------------------
advanced_options_menu() {
    choice=$(zenity --list \
        --title="ASAM Installer - Advanced Options" \
        --width=420 --height=300 \
        --column="Option" \
        "View current config" \
        "Edit config (text editor)" \
        "Toggle ASAM systemd service" \
        "Back")

    case "$choice" in

        "View current config")
            if [[ -f ./installer_config.ini ]]; then
                zenity --text-info \
                    --title="Current Configuration" \
                    --filename="./installer_config.ini" \
                    --width=500 --height=400
            else
                zenity --info \
                    --title="No Config" \
                    --text="No configuration file found yet."
            fi
            ;;

        "Edit config (text editor)")
            if command -v nano &> /dev/null; then
                x-terminal-emulator -e nano ./installer_config.ini &
            else
                zenity --error \
                    --title="Editor Not Found" \
                    --text="No terminal editor found (nano). Install nano to use this feature."
            fi
            ;;

        "Toggle ASAM systemd service")
            if systemctl is-enabled --quiet asam.service; then
                systemctl disable --now asam.service
                zenity --info \
                    --title="Service Disabled" \
                    --text="ASAM systemd service has been disabled."
            else
                systemctl enable --now asam.service
                zenity --info \
                    --title="Service Enabled" \
                    --text="ASAM systemd service has been enabled."
            fi
            ;;

        *)
            ;;
    esac
}

# ------------------ ROOT CHECK ------------------
require_root() {
    if [[ $EUID -ne 0 ]]; then
        warn "Root required. Requesting sudo..."
        exec sudo bash "$0" "$@"
    fi
}

# ------------------ VERSION CHECK ------------------
check_for_updates() {
    LOCAL_VERSION=$(cat ./version.txt)
    REMOTE_VERSION=$(curl -s https://raw.githubusercontent.com/Jezza1232/asam-linux-installer/main/version.txt)

    if [[ -z "$REMOTE_VERSION" ]]; then
        warn "Unable to check for updates (no internet or GitHub unreachable)."
        return
    fi

    if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
        zenity --question \
            --title="Installer Update Available" \
            --width=400 \
            --text="A new version of the ASAM Linux Installer is available.\n\nCurrent version: $LOCAL_VERSION\nNew version: $REMOTE_VERSION\n\nWould you like to update now?"

        if [[ $? -eq 0 ]]; then
            perform_self_update "$REMOTE_VERSION"
        else
            warn "User skipped installer update."
        fi
    else
        success "Installer is up to date (v$LOCAL_VERSION)."
    fi
}

# ------------------ FIRST RUN WIZARD ------------------
first_run_wizard() {
    CONFIG_FILE="./installer_config.ini"

    RESULT=$(zenity --forms \
        --title="ASAM Installer - First Run Wizard" \
        --width=420 \
        --text="Configure basic options before installation:" \
        --add-entry="Linux user to run ASAM under (e.g. root or arkadmin)" \
        --add-combo="Enable ASAM systemd service on boot?" \
        --combo-values="yes|no" \
        --add-combo="Open optional ASA ports (32330)?" \
        --combo-values="yes|no")

    if [[ $? -ne 0 ]]; then
        warn "First run wizard cancelled."
        return 1
    fi

    INSTALL_USER=$(echo "$RESULT" | cut -d'|' -f1)
    ENABLE_SERVICE=$(echo "$RESULT" | cut -d'|' -f2)
    OPEN_EXTRA_PORT=$(echo "$RESULT" | cut -d'|' -f3)

    cat > "$CONFIG_FILE" << EOF
INSTALL_USER=$INSTALL_USER
ENABLE_SERVICE=$ENABLE_SERVICE
OPEN_EXTRA_PORT=$OPEN_EXTRA_PORT
EOF

    success "Configuration saved to $CONFIG_FILE."
}

# ------------------ SELF UPDATE SYSTEM ------------------
perform_self_update() {
    NEW_VERSION="$1"

    # Prevent updating from /tmp
    if [[ "$PWD" == "/tmp"* ]]; then
        zenity --error \
            --title="Update Error" \
            --text="The installer cannot update itself while running from /tmp.\n\nPlease extract it to a folder first."
        return
    fi

    log "Downloading latest installer package..."
    wget -O /tmp/asam_installer_update.zip \
        https://github.com/Jezza1232/asam-linux-installer/archive/refs/heads/main.zip >/dev/null 2>&1

    if [[ $? -ne 0 ]]; then
        zenity --error \
            --title="Update Failed" \
            --text="Unable to download update. Please check your connection."
        return
    fi

    log "Extracting update..."
    unzip -o /tmp/asam_installer_update.zip -d /tmp >/dev/null 2>&1

    log "Replacing installer files..."
    cp -r /tmp/asam-linux-installer-main*/* ./ >/dev/null 2>&1

    echo "$NEW_VERSION" > version.txt

    success "Installer updated to version $NEW_VERSION."

    zenity --info \
        --title="Update Complete" \
        --text="The installer has been updated to version $NEW_VERSION.\n\nIt will now restart."

    exec bash ./asam_stage1_main.sh
}