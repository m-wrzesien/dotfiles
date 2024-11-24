#!/bin/bash

set -euo pipefail

ARCH="Arch Linux"
LAPTOP_PACKAGES=(
  steam
  # required for steam
  ttf-liberation
)

PACMAN_CONF="/etc/pacman.conf"
PACKAGES=(
  age
  android-tools
  ansible
  ansible-core
  apache-tools
  argocd
  # preview archives in ranger
  atool
  bash-completion
  bash-language-server
  bind-tools
  chezmoi
  chromium
  cilium-cli
  docker
  docker-buildx
  docker-compose
  dockerfile-language-server-bin
  entr
  firefox
  flameshot
  gnome-calculator-gtk3
  go
  google-cloud-cli
  gopls
  helix
  # create symlink hx -> helix
  helixbinhx
  helm
  helm-ls-bin
  # syntax highlighter in ranger
  highlight
  hydrapaper-no-pandoc-git
  jq
  k9s
  keepassxc
  kitty
  kubectl
  kubectx
  # provide ASCII-art image previews for ranger
  libcaca
  man-db
  man-pages
  # provide info about media files for ranger
  mediainfo
  meld
  minikube
  ncdu
  neofetch
  nodejs-compose-language-service
  noto-fonts
  packer
  pacman-cleanup-hook
  # provide pdf preview for ranger
  poppler
  python-pylibssh
  qbittorrent
  # Required for packer-builder-arm
  qemu-user-static-binfmt
  # modify pdfs
  qpdf
  ranger
  # canon printer scanner
  scangearmp2
  shellcheck-bin
  shfmt
  signal-desktop
  sops
  syncthing
  # required, so wg-quick can set up dns
  systemd-resolvconf
  # remote decryption for servers
  tang
  terraform
  terraform-ls-bin
  terragrunt
  thunderbird
  ttf-hack-nerd
  vlc
  vscode-css-languageserver
  vscode-html-languageserver
  vscode-json-languageserver
  vscodium-bin
  # preview html pagers in ranger
  w3m
  webcord-bin
  web-greeter
  whois
  wireguard-tools
  wireshark-qt
  # enable copy in k9s
  xsel
  # zenity replacement
  yad
  yaml-language-server
  yaycache-hook
  yubikey-manager
)

REMOVE_PACKAGES=(
  gbt
  gnome-screenshot
)

REPOS=(
  multilib
)

# Version 1.14.1-1
MAPTOOL_COMMIT="227f028defeaf7c9a2c541b35089228bd128ba06"
MAPTOOL_PKG="maptool-bin"
MAPTOOL_URL="https://aur.archlinux.org/maptool-bin.git"

addToGrp() {
  sudo usermod -aG "$1" "$USER"
  echo "Relog or use \"newgrp $1\" or change won't take effect."
}

cdOrFail() {
  cd "$1" || echo "Can't cd. $1 not found"
}

checkDistro() {
  distroName=$(grep -Po '^NAME="\K.*(?=")' /etc/os-release)

  if [ "$distroName" != "$ARCH" ]; then
    return 1
  fi
}

enableRepo() {
  local repoEnabled=false
  for repo in "${REPOS[@]}"; do
    pattern="^#\[$repo\]"
    if ! grep "$pattern" "$PACMAN_CONF" &>/dev/null; then
      continue
    fi
    echo "Enabling $repo"
    sudo sed -i "/${pattern}$/{n;s/^#//g;}" "$PACMAN_CONF"
    sudo sed -i "/${pattern}/s/^#//g" "$PACMAN_CONF"
    repoEnabled=true
  done

  if $repoEnabled; then
    echo "Triggering system upgrade, as new repo was installed"
    yay
  fi
}

getPackagesToInstall() {
  local output=()
  for package in "${PACKAGES[@]}"; do
    if ! yay -Q "$package" &>/dev/null; then
      output+=("$package")
    fi
  done
  if chezmoi data | jq .chezmoi.hostname | grep -qi thinkpad; then
    for package in "${LAPTOP_PACKAGES[@]}"; do
      if ! yay -Q "$package" &>/dev/null; then
        output+=("$package")
      fi
    done
  fi
  echo "${output[@]}"
}

getPackagesToRemove() {
  local output=()
  for package in "${REMOVE_PACKAGES[@]}"; do
    if yay -Q "$package" &>/dev/null; then
      output+=("$package")
    fi
  done
  echo "${output[@]}"
}

install() {
  if [ "$#" -eq 0 ]; then
    echo "No packages to install"
    return 0
  fi
  echo "Following packages will be installed: $*"
  local newparams=()
  for package in "$@"; do
    case $package in
    hydrapaper-no-pandoc-git)
      installHydrapaper
      ;;
    *)
      newparams+=("$package")
      ;;
    esac
  done
  set -- "${newparams[@]}" # overwrites the original positional params
  yay -S "$@"
}

remove() {
  if [ "$#" -eq 0 ]; then
    echo "No packages to remove"
    return 0
  fi
  echo "Following packages will be removed: $*"
  local newparams=()
  for package in "$@"; do
    case $package in
    *)
      newparams+=("$package")
      ;;
    esac
  done
  set -- "${newparams[@]}" # overwrites the original positional params
  yay -Rs "$@"
}

# workaround for problems with ssl certificate during checks
installHydrapaper() {
  echo "Change \"check()\" to look like following code:"
  echo "
check() {
  #meson test -C build --print-errorlogs
  echo "Disable checks, as they fail due to ssl cert expiration"
}"
  yay --editmenu -S hydrapaper-no-pandoc-git --save
}

installMapTool() {
  mkdir -p "$HOME/.cache/chezmoi_makepkg"
  cdOrFail "$HOME/.cache/chezmoi_makepkg"
  if ! [ -d "$MAPTOOL_PKG" ]; then
    git clone "$MAPTOOL_URL"
  fi
  cdOrFail "$MAPTOOL_PKG"
  git checkout master
  git pull
  git checkout "$MAPTOOL_COMMIT"
  if yay -Q "$MAPTOOL_PKG" >/dev/null; then
    # shellcheck source=/dev/null disable=SC2154
    if [ "$(source PKGBUILD && echo "$MAPTOOL_PKG $pkgver-$pkgrel")" == "$(yay -Q "$MAPTOOL_PKG")" ]; then
      echo "Maptool is already installed with correct version"
      return
    fi
  fi
  makepkg -si
}

installYay() {
  local temp
  local oldPWD

  if pacman -Q yay >/dev/null; then
    echo "Yay already installed"
    return
  fi
  sudo pacman -S --needed git base-devel

  temp=$(mktemp -d)
  oldPWD=$(pwd)
  cdOrFail "$temp"

  git clone https://aur.archlinux.org/yay.git
  cdOrFail yay

  makepkg -si
  cdOrFail "$oldPWD"

  rm -rf "$temp"
}

postInstallActions() {
  for package in "$@"; do
    case $package in
    docker)
      addToGrp docker
      sudo systemctl enable docker.service
      sudo systemctl start docker.service
      ;;
    helm)
      helm plugin install https://github.com/databus23/helm-diff
      ;;
    maptool-bin)
      # Exclude maptool-bin for pacman/yay, as we upgrade it manually
      grep "IgnorePkg   = maptool-bin" "$PACMAN_CONF" >/dev/null || sudo sed -i 's|#IgnorePkg   =|###START ADDED BY CHEZMOI###\nIgnorePkg   = maptool-bin\n###STOP ADDED BY CHEZMOI###|' "$PACMAN_CONF"
      ;;
    steam)
      echo "Patching steam application shortcut to use wrapper"
      sudo sed -i 's|Exec=/usr/bin/steam-runtime|Exec=steam|' /usr/share/applications/steam.desktop
      echo "Rembember to install OpenGL for multilib!!!"
      echo "https://wiki.archlinux.org/title/Xorg#Driver_installation"
      ;;
    syncthing)
      systemctl --user enable syncthing.service
      systemctl --user start syncthing.service
      ;;
    systemd-resolvconf)
      sudo systemctl enable systemd-resolved
      sudo systemctl start systemd-resolved
      # Force NetworkManager, to use systemd-resolved as DNS resolver
      sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
      ;;
    vscodium-bin)
      sudo ln -s /usr/bin/codium /usr/local/bin/code
      ;;
    web-greeter)
      sudo sed -i 's|#greeter-session=.*|greeter-session=web-greeter|' /etc/lightdm/lightdm.conf
      ;;
    yaycache-hook)
      # add configuration to yaycache-hook
      # without `cache_dirs` it will try to remove yay cache from root,
      # while it is stored at our user at $XDG_CACHE_HOME/yay/
      sudo sed -i 's/extra_args=.*/extra_args="-v --remove-build-files"/' /etc/yaycache-hook.conf
      sudo sed -i "s|cache_dirs=.*|cache_dirs=(\"$XDG_CACHE_HOME/yay/*/\")|" /etc/yaycache-hook.conf
      sudo sed -i 's/uninstalled_keep=.*/uninstalled_keep=0/' /etc/yaycache-hook.conf
      ;;
    yubikey-manager)
      sudo systemctl enable pcscd.service
      sudo systemctl start pcscd.service
      ;;
    wireshark-qt)
      # Group "wireshark" required, so app won't need to be start as root
      addToGrp wireshark
      ;;
    *)
      echo "No action for $package"
      ;;
    esac
  done
}

checkDistro || exit 0

installYay

enableRepo

# Chech what packages needs to be removed and put them in to array
IFS=" " read -r -a toRemove <<<"$(getPackagesToRemove)"

remove "${toRemove[@]}"

# Chech what packages needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<<"$(getPackagesToInstall)"

install "${toInstall[@]}"

installMapTool

postInstallActions "${toInstall[@]}" "$MAPTOOL_PKG"
