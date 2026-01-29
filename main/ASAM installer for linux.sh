code_here_for_log_output
sudo su
add-apt-repository universe -y
apt update
apt install -y xrdp
systemctl enable --now xrdp
dpkg --add-architecture i386
apt update
apt install upgrade
apt install -y wine
apt install -y wine64
apt install -y q4wine
apt install -y winetricks
apt install -y winbind
apt install -y unzip
ufw allow 7777,25015
wineserver -k

rm -rf ~/.wine
WINEARCH=win64 WINEPREFIX=~/.wine wineboot --init

WINEPREFIX=~/.wine winetricks -q dotnet48

cat > /tmp/wine_x11_gamma.reg << 'EOF'
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\X11 Driver]
"UseXVidMode"="N"
"UseXRandR"="Y"
EOF

WINEPREFIX="$HOME/.wine" wine regedit /S /tmp/wine_x11_gamma.reg
rm /tmp/wine_x11_gamma.reg
wineserver -k

ASAM_ZIP_URL="https://github.com/CSBrad/ASAM/archive/refs/heads/main.zip"
wget -O /tmp/asam.zip "$ASAM_ZIP_URL"
unzip -o /tmp/asam.zip -d ~/HOME/Desktop
mv ~/HOME/Desktop/ASAM-main ~/HOME/Desktop/ASAM-main
rm /tmp/asam.zip

#AT THIS POINT SOFTWARE NEEDS TO RUN ASAM.exe in Q4wine

echo 'WINEPREFIX="$HOME/.wine" wine "$HOME/Desktop/ASAM/ASAM.exe"' > ~/Desktop/run_asam.exe
chmod +x ~/Desktop/run_asam.exe
