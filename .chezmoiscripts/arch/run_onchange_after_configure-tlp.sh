#!/bin/bash

set -euo pipefail

if ! [ -d /etc/tlp.d ] || ! pacman -Q tlp >/dev/null; then
  echo "TLP not installed, skipping..."
  return
fi

echo "Starting TLP configuration"

sudo tee /etc/tlp.d/10-dotfiles.conf >/dev/null <<EOF
# Managed by dotfiles
TLP_PROFILE_AC=BAL
TLP_PROFILE_BAT=SAV
EOF

echo "Enabling and starting/restarting services..."

if sudo systemctl is-active -q tlp.service || systemctl is-enabled -q tlp.service; then
  sudo systemctl restart tlp.service
else
  sudo systemctl -enable --now tlp.service
fi

if sudo systemctl is-active -q tlp-pd.service || systemctl is-enabled -q tlp-pd.service; then
  sudo systemctl restart tlp-pd.service
else
  sudo systemctl enable --now tlp-pd.service
fi

echo "TLP configured"
