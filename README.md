# ASAM Linux Prerequisites

An automatic setup script for installing ASAM on Ubuntu Linux with Wine support and remote desktop access.

## Overview

This repository contains a fully automated bash script that sets up a complete Ubuntu Linux environment for running ASAM (a Windows application) using Wine. The script handles all dependencies, configuration, and installation with comprehensive logging.

## Features

- ✅ **Fully Automatic** - Single command setup with no user interaction required
- 📝 **Comprehensive Logging** - All actions logged to timestamped files in the `logs/` folder
- 🔧 **Complete Setup** - Installs Wine, .NET 4.8, XRDP, and all dependencies
- 🎯 **Error Handling** - Automatic error detection and detailed error messages
- 🚀 **Ready to Use** - Creates launcher scripts and desktop shortcuts
- 🔒 **Firewall Configuration** - Automatically configures UFW for required ports

## Requirements

- Ubuntu Linux (20.04 LTS or later recommended)
- Root or sudo access
- Internet connection for downloading packages and ASAM

## Installation

### Quick Start

1. Clone the repository:
```bash
git clone https://github.com/Jezza1232/asam-linux-prereqs.git
cd asam-linux-prereqs
```

2. Make the script executable:
```bash
chmod +x main/ASAM\ installer\ for\ linux.sh
```

3. Run the setup script:
```bash
sudo bash main/ASAM\ installer\ for\ linux.sh
```

The script will automatically:
- Request sudo privileges if needed
- Update system packages
- Install Wine and dependencies
- Configure Wine for .NET 4.8
- Download and extract ASAM
- Create launcher scripts
- Set up remote desktop access

## What Gets Installed

### System Packages
- **Wine & Wine64** - Windows compatibility layer
- **Q4Wine** - Wine GUI manager
- **Winetricks** - Wine package installer
- **Winbind** - Windows name resolution
- **XRDP** - Remote desktop protocol server
- **UFW** - Firewall management

### Wine Configuration
- 64-bit Wine prefix
- .NET Framework 4.8
- X11 Driver optimization

### ASAM Application
- Downloaded from official GitHub repository
- Extracted to `~/Desktop/ASAM`
- Launcher script in both Desktop and project root

## Usage

After installation, run ASAM using any of these methods:

### Method 1: Desktop Shortcut
Click the `ASAM.desktop` shortcut on your desktop

### Method 2: Terminal Command
```bash
~/Desktop/run_asam.sh
```

### Method 3: Launcher Script
```bash
./launcher
```

## Remote Desktop Access

XRDP is automatically configured and running on **port 3389**.

Connect from another machine using RDP client:
```bash
mstsc /v:YOUR_SERVER_IP:3389
```

## Logging

All installation logs are saved to the `logs/` directory with timestamps:
```
logs/setup_20260129_120000.log
```

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
