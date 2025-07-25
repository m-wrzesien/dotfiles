#!/bin/bash

set -euo pipefail

UBUNTU="Ubuntu"
PACKAGES=(
  codium
  dnsutils
  firefox
  flameshot
  hydrapaper
  keepassxc
  kitty
  meld
  neofetch
  # provide pdf preview for yazi
  poppler-data
  poppler-utils
  syncthing
  wireshark
  xdotool
)

REMOVE_PACKAGES=(
  atool
  caca-utils
  entr
  fonts-noto-color-emoji
  gbt
  helix
  highlight
  jq
  mediainfo
  ncdu
  nodejs
  ranger
  shellcheck
  shfmt
  terraform-ls
  w3m
)

REMOVE_REPO_FILES=(
  /etc/apt/preferences.d/nodejs
  /etc/apt/sources.list.d/gbt.list
  /etc/apt/sources.list.d/maveonair-ubuntu-helix-editor-jammy.list
  /etc/apt/sources.list.d/nodesource.list
  /etc/apt/trusted.gpg.d/gbt.asc
  /etc/apt/trusted.gpg.d/maveonair-ubuntu-helix-editor.gpg
  /etc/apt/trusted.gpg.d/maveonair-ubuntu-helix-editor.gpg~
  /etc/apt/trusted.gpg.d/nodesource.gpg
)

removeRepo() {
  for file in "${REMOVE_REPO_FILES[@]}"; do
    if ! [ -f "$file" ]; then
      continue
    fi
    sudo rm "$file"
  done
}

addRepo() {
  # https://support.mozilla.org/en-US/kb/install-firefox-linux#w_install-firefox-deb-package-for-debian-based-distributions
  curl -sL https://packages.mozilla.org/apt/repo-signing-key.gpg | sudo tee /etc/apt/trusted.gpg.d/packages.mozilla.org.asc >/dev/null
  echo 'deb https://packages.mozilla.org/apt mozilla main' | sudo tee /etc/apt/sources.list.d/mozilla.list >/dev/null
  echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla >/dev/null
  curl -sL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | sudo tee /etc/apt/trusted.gpg.d/vscodium.asc >/dev/null
  echo 'deb https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list

  sudo apt update
}

cdOrFail() {
  cd "$1" || echo "Can't cd. $1 not found"
}

checkDistro() {
  distroName=$(grep -Po '^NAME="\K.*(?=")' /etc/os-release)

  if [ "$distroName" != "$UBUNTU" ]; then
    return 1
  fi
}

getPackagesToInstall() {
  local output=()
  for package in "${PACKAGES[@]}"; do
    if ! dpkg -s "$package" &>/dev/null; then
      output+=("$package")
    fi
  done
  echo "${output[@]}"
}

getPackagesToRemove() {
  local output=()
  for package in "${REMOVE_PACKAGES[@]}"; do
    if dpkg -s "$package" &>/dev/null; then
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
  sudo apt install "$@"
}

remove() {
  if [ "$#" -eq 0 ]; then
    echo "No packages to remove"
    return 0
  fi
  echo "Following packages will be removed: $*"
  sudo apt remove "$@"
}

postInstallActions() {
  for package in "$@"; do
    echo "$package"
    case $package in
    syncthing)
      systemctl --user enable syncthing.service
      systemctl --user start syncthing.service
      ;;
    vscodium-bin)
      sudo ln -s /usr/bin/codium /usr/local/bin/code
      ;;
    yubikey-manager*)
      sudo systemctl enable pcscd.service
      sudo systemctl start pcscd.service
      ;;
    *)
      echo "No action for $package"
      ;;
    esac
  done
}

checkDistro || exit 0

removeRepo

addRepo

# Chech what packages needs to be removed and put them in to array
IFS=" " read -r -a toRemove <<<"$(getPackagesToRemove)"

remove "${toRemove[@]}"

# Chech what packages needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<<"$(getPackagesToInstall)"

install "${toInstall[@]}"

postInstallActions "${toInstall[@]}"
