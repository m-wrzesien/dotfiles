#!/bin/bash

set -euo pipefail

echo "Running post install script..."

echo "Patching steam application shortcut to use wrapper"
sudo sed -i 's|^Exec=/usr/bin/steam-runtime|Exec=steam|' /usr/share/applications/steam.desktop
echo "Rembember to install OpenGL for multilib!!!"
echo "https://wiki.archlinux.org/title/Xorg#Driver_installation"

echo "Done"
