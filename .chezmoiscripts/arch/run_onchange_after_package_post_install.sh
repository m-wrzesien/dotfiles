#!/bin/bash

set -euo pipefail

addToGrp() {
  if groups "$USER" | grep -q "$1"; then
    echo "Group \"$1\" to \"$USER\" already added. Skipping it..."
    return
  fi

  sudo usermod -aG "$1" "$USER"
  echo "Relog or use \"newgrp $1\" or change won't take effect."
}

echo "Running post install script..."

# blueberry
sudo systemctl enable --now bluetooth.service

# cups
sudo systemctl enable --now cups.service

# docker
addToGrp docker
sudo systemctl enable --now docker.service

# helm-diff
if ! helm plugin list | grep -q diff; then
  helm plugin install /usr/lib/helm/plugins/diff
else
  echo "helm-diff plugin already installed"
fi

# lxdm
sudo sed -i 's|^# session=/usr/bin/startlxde|session=/usr/bin/cinnamon-session|' /etc/lxdm/lxdm.conf
sudo systemctl enable lxdm.service

# lxdm-themes
sudo sed -i 's|^gtk_theme=.*|# gtk_theme=disabled|' /etc/lxdm/lxdm.conf
sudo sed -i 's|^theme=.*|theme=ArchlinuxFull|' /etc/lxdm/lxdm.conf

# systemd-resolved
sudo systemctl enable --now systemd-resolved
# Force NetworkManager, to use systemd-resolved as DNS resolver
if ! [ -L "/etc/resolv.conf" ]; then
  sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
else
  echo "Symlink for /etc/resolv.conf already exists"
fi

# vscodium-bin
if ! [ -L "/usr/local/bin/code" ]; then
  sudo ln -s /usr/bin/codium /usr/local/bin/code
else
  echo "Symlink for /usr/local/bin/code already exists"
fi

# yaycache-hook
# add configuration to yaycache-hook
# without `cache_dirs` it will try to remove yay cache from root,
# while it is stored at our user at $XDG_CACHE_HOME/yay/
sudo sed -i 's|extra_args=.*|extra_args="-v --remove-build-files"|' /etc/yaycache-hook.conf
sudo sed -i "s|^cache_dirs=.*|cache_dirs=(\"$XDG_CACHE_HOME/yay/*/\")|" /etc/yaycache-hook.conf
sudo sed -i 's|^uninstalled_keep=.*|uninstalled_keep=0|' /etc/yaycache-hook.conf

# yubikey-manager
sudo systemctl enable --now pcscd.service

# wireshark
# Group "wireshark" required, so app won't need to be start as root
addToGrp wireshark

echo "Done"
