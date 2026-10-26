#!/bin/bash

set -euo pipefail

LAPTOP_PACKAGES=(
  # bluetooth management used in cinnamon
  blueberry
  steam
  # power management
  tlp
  tlp-pd
  # required for steam
  ttf-liberation
)

PACMAN_CONF="/etc/pacman.conf"
PACKAGES=(
  7zip
  age
  android-tools
  android-udev
  ansible
  ansible-core
  apache-tools
  argocd
  bash-completion
  bash-language-server
  bind-tools
  bolt
  caffeine
  chezmoi
  chromium
  cilium-cli
  cinnamon
  # Canon TS3300 driver
  cnijfilter2
  cups
  docker
  docker-buildx
  docker-compose
  dockerfile-language-server
  dosfstools
  efm-langserver
  entr
  fastfetch
  firefox
  flameshot
  fluffychat-bin
  fzf
  gnome-calculator
  # required at least by networkmanager
  gnome-keyring
  go
  golangci-lint
  golangci-lint-langserver-bin
  gopls
  hadolint-bin
  helix
  # create symlink hx -> helix
  helixbinhx
  helm
  helm-diff
  helm-ls-bin
  htop
  # cilium observability
  hubble-bin
  imagemagick
  iperf3
  jq
  k9s
  keepassxc
  kitty
  kolourpaint
  kubectl
  kubectl-cnpg
  kubectx
  libreoffice-still
  # fixes problem with frontend-tools obs plugin load due to missing libluajit-5.1.so.2
  luajit
  lxdm
  lxdm-themes
  man-db
  man-pages
  marksman
  meld
  minikube
  mpls-bin
  ncdu
  nmap
  nodejs-compose-language-service
  # font used by desktop apps (like cinnamon and firefox)
  noto-fonts
  # enabled emojis in terminal
  noto-fonts-emoji
  obs-studio
  packer
  pacman-cleanup-hook
  # provide pdf preview for yazi
  poppler
  poppler-data
  python-pylibssh
  # music player
  rufin-bin
  qbittorrent
  # Required for packer-builder-arm
  qemu-user-static-binfmt
  # modify pdfs
  qpdf
  # canon printer scanner
  scangearmp2
  shellcheck-bin
  shfmt
  signal-desktop
  smartmontools
  sops
  starship
  syncthing
  # required, so wg-quick can set up dns
  systemd-resolvconf
  # remote decryption for servers
  tang
  # for toml lsp
  taplo
  termux-language-server
  terraform
  terraform-ls-bin
  terragrunt
  thunderbird
  ttf-hack-nerd
  ttf-nerd-fonts-symbols
  ttf-nerd-fonts-symbols-common
  usbutils
  vesktop-bin
  vim
  vlc
  vlc-plugin-ffmpeg
  vscode-css-languageserver
  vscode-html-languageserver
  vscode-json-languageserver
  vscodium-bin
  whois
  wireguard-tools
  wireshark-qt
  # enable copy in k9s and yazi
  xsel
  # zenity replacement
  yad
  yaml-language-server
  yamlfmt
  yaycache-hook
  yazi
  yubikey-manager
)

REMOVE_PACKAGES=(
  gnome-calculator-gtk3
  hydrapaper-no-pandoc-git
  libsoup
  libxml2-legacy
)

REPOS=(
  multilib
)

addToGrp() {
  sudo usermod -aG "$1" "$USER"
  echo "Relog or use \"newgrp $1\" or change won't take effect."
}

cdOrFail() {
  cd "$1" || echo "Can't cd. $1 not found"
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
  # TODO: migrate this to something different than hostname...
  if chezmoi data | jq .chezmoi.hostname | grep -qi pad; then
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

installYay

enableRepo

# Chech what packages needs to be removed and put them in to array
IFS=" " read -r -a toRemove <<<"$(getPackagesToRemove)"

remove "${toRemove[@]}"

# Chech what packages needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<<"$(getPackagesToInstall)"

install "${toInstall[@]}"
