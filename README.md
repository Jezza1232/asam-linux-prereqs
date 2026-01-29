# ASAM Linux Installer

<div align="center">

**A fully automated GUI-based installer for running ASAM on Ubuntu Linux with Wine, XRDP, SSH, firewall automation, and systemd integration.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-orange)](https://ubuntu.com)
![Bash](https://img.shields.io/badge/Bash-5.0%2B-brightgreen)

</div>

---

## 📋 Overview

This repository contains a **complete, production-ready installer** that transforms an Ubuntu system into a ASAM-ready environment. The installer uses a **GUI-driven three-stage approach** with zenity dialogs, comprehensive error handling, and systemd integration—all without requiring manual configuration.

### ✨ Key Highlights

- 🎯 **100% Automatic** - GUI menus guide users through setup; no manual config needed
- 📦 **Debian Package** - Install via `apt` or from the `.deb` file
- 🔧 **Three-Stage Setup**:
  - **Stage 1**: Wine environment + .NET 4.8 + ASAM download
  - **Stage 2**: SSH + XRDP remote access
  - **Stage 3**: UFW firewall + git + systemd service
- 🎨 **Modern GUI** - Zenity-based dialogs with progress bars and color-coded output
- 🔄 **Self-Update** - Built-in version checking and automatic update downloads
- 📊 **Advanced Options** - Config viewer, editor, systemd service toggle
- 🚀 **Systemd Ready** - Manage ASAM via `systemctl` or launcher script
- 📝 **Full Logging** - Timestamped logs for troubleshooting

---

## 📦 Installation Methods

### Method 1: From Source (GitHub) (Recommended)

```bash
git clone https://github.com/Jezza1232/asam-linux-prereqs.git
cd asam-linux-prereqs/asam-deb-build/opt/asam-linux-installer
bash asam_gui_menu.sh
```

### Method 2: Manual Build (deb from source)

```bash
cd asam-deb-build
dpkg-deb --build . ../asam-linux-installer_1.0.0_amd64.deb
sudo apt install ../asam-linux-installer_1.0.0_amd64.deb
```

---

## 🎮 GUI Menu & Options

When you run `asam-installer` (or `asam_gui_menu.sh`), you'll see:

```
┌─────────────────────────────────────────┐
│   ASAM Linux Installer v1.0.0           │
├─────────────────────────────────────────┤
│  ◉ Start Installation                   │
│  ○ Check for Updates                    │
│  ○ Advanced Options                     │
│  ○ About                                │
│  ○ Exit                                 │
└─────────────────────────────────────────┘
```

### Start Installation

Launches **three sequential stages** with progress bars and status updates:

#### Stage 1: Wine Environment & ASAM
- Updates system packages + enables Universe repo
- Installs XRDP (Remote Desktop Protocol)
- Installs Wine, Winetricks, Q4Wine, Winbind
- Installs SteamCMD + unzip utilities
- Resets Wine environment (clean prefix)
- Installs .NET Framework 4.8 via winetricks
- Applies X11 driver registry optimization
- Downloads ASAM from [Brad's GitHub](https://github.com/CSBrad/ASAM) to `~/Desktop/ASAM`

#### Stage 2: Remote Access (SSH + XRDP)
- Installs OpenSSH server
- Configures SSH for key-based authentication
- Verifies XRDP is running on port 3389

#### Stage 3: Firewall & Systemd
- Installs git
- Enables UFW firewall
- Configures UFW rules (SSH, XRDP, ASAM ports)
- Installs systemd service (`asam.service`)
- Optionally enables systemd startup on boot

### Check for Updates

- Fetches latest version from GitHub (`version.txt`)
- If newer version available, prompts to download
- Downloads as ZIP, extracts, replaces all files
- Automatically restarts installer

### Advanced Options

- **View current config** - Display `installer_config.ini`
- **Edit config** - Open config in text editor
- **Toggle ASAM systemd service** - Enable/disable auto-start on boot
- **Back** - Return to main menu

### About

Shows installer version, author, and description.

---

## 📥 What Gets Installed

### System Packages
| Package | Purpose |
|---------|---------|
| **wine64** | 64-bit Windows compatibility layer |
| **wine** | 32-bit Windows compatibility (i386 architecture) |
| **winetricks** | Wine package installer (used for .NET 4.8) |
| **q4wine** | GUI for managing Wine prefixes |
| **winbind** | Windows SMB/CIFS name resolution |
| **xrdp** | Remote Desktop Protocol server (port 3389) |
| **openssh-server** | SSH remote access |
| **ufw** | Firewall management |
| **zenity** | GUI dialogs |
| **unzip** | Archive extraction |
| **steamcmd** | Valve's Steam Command (runtime support) |
| **git** | Version control |

### Wine Configuration
- **Architecture**: 64-bit (`WINEARCH=win64`)
- **.NET Framework**: 4.8 (installed via winetricks)
- **X11 Driver**: Optimized for Linux display servers
- **Wine Prefix**: `~/.wine` (standard location)

### ASAM Application
- **Source**: [CSBrad/ASAM](https://github.com/CSBrad/ASAM)
- **Location**: `~/Desktop/ASAM`
- **Launch Scripts**:
  - `/usr/local/bin/asam-installer` (global menu launcher)
  - `~/Desktop/run_asam.sh` (single-use launcher)
  - `/opt/asam-linux-installer/asam_systemd_launcher.sh` (systemd runner)
- **Systemd Service**: `/etc/systemd/system/asam.service` (optional auto-start)

---

## 🚀 Running ASAM

### Option 1: Systemd Service (Best for always-on)

```bash
sudo systemctl enable asam.service
sudo systemctl start asam.service
```

Check status:
```bash
sudo systemctl status asam.service
```

View logs:
```bash
journalctl -u asam.service -f
```

### Option 2: Direct Launcher Script

```bash
~/.wine/drive_c/Program\ Files/ASAM/ASAM.exe
```

Or via shell wrapper:
```bash
bash ~/Desktop/run_asam.sh
```

### Option 3: Wine Command

```bash
WINEPREFIX=~/.wine wine64 ~/Desktop/ASAM/ASAM.exe
```

---

## 🌐 Remote Access

### XRDP (Remote Desktop)

After installation, XRDP runs on **port 3389**. Connect from another machine:

**Windows:**
```bash
mstsc /v:YOUR_SERVER_IP:3389
```

**Linux:**
```bash
rdesktop -u root YOUR_SERVER_IP:3389
```

**macOS:**
```bash
open rdp://YOUR_SERVER_IP:3389
```

### SSH Access

```bash
ssh -i ~/.ssh/id_rsa root@YOUR_SERVER_IP
```

---

## 🔒 Firewall Configuration

UFW is enabled with these rules:

| Port | Service | Direction |
|------|---------|-----------|
| **22** | SSH | Allow incoming |
| **3389** | XRDP | Allow incoming |
| **3210** | ASAM (custom) | Allow incoming |
| **Others** | Default | Deny incoming |

View rules:
```bash
sudo ufw status
```

---

## 📁 File Structure

```
asam-deb-build/
├── DEBIAN/
│   ├── control              # Package metadata
│   ├── postinst             # Post-install script (sets permissions, installs service)
│   └── postrm               # Post-remove script (cleans up service)
├── opt/asam-linux-installer/
│   ├── ASAM_stage1_main.sh      # Stage 1: Wine + .NET + ASAM
│   ├── ASAM_stage2_remote_access.sh  # Stage 2: SSH + XRDP
│   ├── ASAM_stage3_firewall_asam.sh  # Stage 3: UFW + Systemd
│   ├── asam_gui_menu.sh         # Main menu (zenity dialogs)
│   ├── asam_systemd_launcher.sh # Systemd service launcher
│   ├── common_env.sh            # Shared functions (colors, logs, GUI)
│   ├── asam.service             # Systemd unit file
│   ├── version.txt              # Current version (1.0.0)
│   └── installer_config.ini     # User config (created at first run)
└── usr/local/bin/
    └── asam-installer           # Global command launcher
```

---

## 🛠️ Configuration

### First Run Wizard

On first run, you'll be prompted to:
- Confirm username for ASAM install
- Confirm home directory path
- Choose to enable systemd auto-start

Config is saved to `installer_config.ini` and reused on subsequent runs.

### Manual Config Edit

From the GUI menu → **Advanced Options** → **Edit config** opens the config file in your default editor.

---

## 📊 Logging

All operations are logged to:
```
/opt/asam-linux-installer/logs/
```

Log filename format: `asam_stage1_YYYYMMDD_HHMMSS.log`

Example log output:
```
[2026-01-29 12:11:15] [*] Starting Stage 1 installation...
[2026-01-29 12:11:16] [*] Updating system packages...
[2026-01-29 12:12:45] [✓] System updated successfully
[2026-01-29 12:13:02] [*] Installing Wine...
[2026-01-29 12:30:15] [✓] .NET Framework 4.8 installed
[2026-01-29 12:31:20] [✓] ASAM downloaded to ~/Desktop/ASAM
[2026-01-29 12:31:25] [✓] ====== ASAM Ubuntu Setup Completed Successfully ======
```

---

## 🔄 Self-Update System

The installer checks for updates on every startup:

1. **Local version** read from `version.txt`
2. **Remote version** fetched from GitHub `version.txt`
3. **If newer available**:
   - Zenity dialog offers update
   - Download latest `.zip` from `main` branch
   - Extract and replace all files
   - Automatically restart

To **disable** auto-update prompts, edit `installer_config.ini`:
```ini
CHECK_FOR_UPDATES=false
```

---

## 🐛 Troubleshooting

### Wine/ASAM won't start
```bash
# Reset Wine environment
wineserver -k
rm -rf ~/.wine
WINEARCH=win64 WINEBOOT wineboot --init
```

### XRDP connection refused
```bash
sudo systemctl restart xrdp
sudo systemctl status xrdp
```

### .NET installation stalled
```bash
# Retry manually
WINEPREFIX=~/.wine winetricks -q dotnet48
```

### Check installer logs
```bash
tail -f /opt/asam-linux-installer/logs/asam_stage*.log
```

### SSH key permission issues
```bash
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

---

## 📋 Requirements

- **OS**: Ubuntu Linux 20.04 LTS or later
- **Architecture**: x86_64 (amd64)
- **RAM**: 4GB recommended (8GB+ for comfortable use)
- **Disk**: 10GB free space (Wine + .NET + ASAM)
- **Network**: Internet connection (for downloads)
- **Privileges**: Root or sudo access (installer requests automatically)

---

## 🤝 Support & Contributing

For issues, bugs, or feature requests:
- Open an issue on [GitHub](https://github.com/Jezza1232/asam-linux-prereqs/issues)
- Check existing logs: `tail -f /opt/asam-linux-installer/logs/asam_stage*.log`
- Provide output from: `dpkg -l | grep -E "wine|asam|xrdp"`

---

## 📄 License

MIT License — See LICENSE file for details.

---

## 🙏 Credits

- **ASAM Application**: [CSBrad/ASAM](https://github.com/CSBrad/ASAM)
- **Wine Project**: [Wine HQ](https://www.winehq.org/)
- **Created by**: Jez

---

**Last Updated**: January 29, 2026 | **Version**: 1.0.0

Check logs for:
- Installation progress
- Any errors encountered
- Command execution details
- Final setup summary

## Firewall Ports

The following ports are automatically configured:
- **3389** - XRDP (Remote Desktop)
- **7777** - Custom application port
- **25015** - Custom application port

## Project Structure

```
asam-linux-prereqs/
├── main/
│   └── ASAM installer for linux.sh    # Main setup script
├── launcher                            # Symlink launcher script
├── logs/                              # Log directory (created on first run)
├── Info/
│   └── linux coding notes.txt
└── README.md                          # This file
```

## Troubleshooting

### Wine-related issues
If Wine initialization fails, manually reinitialize:
```bash
rm -rf ~/.wine
WINEARCH=win64 WINEPREFIX=~/.wine wineboot --init
WINEPREFIX=~/.wine winetricks -q dotnet48
```

### XRDP connection issues
Restart the XRDP service:
```bash
sudo systemctl restart xrdp
```

### Check installation log
Review the timestamped log file in `logs/` directory for detailed error information

### ASAM not launching
Verify the installation path:
```bash
ls -la ~/Desktop/ASAM/
```

## Advanced Usage

### Run ASAM with additional parameters
```bash
~/Desktop/run_asam.sh --argument value
```

### Uninstall ASAM (keeps Wine)
```bash
rm -rf ~/Desktop/ASAM
```

### Remove entire Wine environment
```bash
rm -rf ~/.wine
```

## Support

For issues with this setup script, check the logs and review the troubleshooting section above.

For ASAM-specific issues, visit the [ASAM GitHub repository](https://github.com/CSBrad/ASAM)

## License

This setup script is provided as-is for the ASAM community.

## Notes

- The script uses Wine 64-bit architecture for better compatibility
- .NET Framework 4.8 is installed as a prerequisite for ASAM
- Logs are never deleted automatically; you can safely remove old logs from the `logs/` folder
- The script is idempotent and can be run multiple times safely

---

**Last Updated:** January 2026

For more information on Wine and ASAM, visit:
- [Wine Project](https://www.winehq.org/)
- [ASAM GitHub](https://github.com/CSBrad/ASAM)


