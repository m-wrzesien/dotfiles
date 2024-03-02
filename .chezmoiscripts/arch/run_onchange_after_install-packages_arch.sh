#!/bin/bash

set -euo pipefail

ARCH="Arch Linux"
PACKAGES=(
    age
    ansible
    ansible-core
    # preview archives in ranger
    atool
    bash-completion
    bind-tools
    chezmoi
    docker
    docker-compose
    entr
    firefox
    gnome-calculator-gtk3
    gnome-screenshot
    go
    google-cloud-cli
    helm
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
    noto-fonts
    packer
    pacman-cleanup-hook
    # provide pdf preview for ranger
    poppler
    python-pylibssh
    ranger
    qbittorrent
    # Required for packer-builder-arm
    qemu-user-static-binfmt
    # modify pdfs
    qpdf
    shellcheck-bin
    signal-desktop
    sops
    # canon printer scanner
    scangearmp2
    syncthing
    # required, so wg-quick can set up dns
    systemd-resolvconf
    # remote decryption for servers
    tang
    terraform
    terragrunt
    thunderbird
    ttf-hack-nerd
    vlc
    vscodium-bin
    # preview html pagers in ranger
    w3m
    webcord-bin
    web-greeter
    wireguard-tools
    wireshark-qt
    # enable copy in k9s
    xsel
    yaycache-hook
    yubikey-manager
)

REMOVE_PACKAGES=(
    gbt
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

getPackagesToInstall() {
    local output=()
    for package in "${PACKAGES[@]}"; do
        if ! yay -Q "$package" > /dev/null; then
            output+=("$package")
        fi
    done
    echo "${output[@]}"
}

getPackagesToRemove() {
    local output=()
    for package in "${REMOVE_PACKAGES[@]}"; do
        if yay -Q "$package" > /dev/null; then
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
    set -- "${newparams[@]}"  # overwrites the original positional params
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
    set -- "${newparams[@]}"  # overwrites the original positional params
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
    if yay -Q "$MAPTOOL_PKG" > /dev/null; then
        # shellcheck source=/dev/null disable=SC2154
        if [ "$(source PKGBUILD && echo "$MAPTOOL_PKG $pkgver-$pkgrel")" == "$(yay -Q "$MAPTOOL_PKG")" ]; then
            echo "Maptool is already installed with correct version"
            return
        fi
    fi
    makepkg -si
    # remove .maptool-rptools from $HOME
    sudo sed -s 's|.maptool-rptools|.local/share/maptool-rptools|' -i /opt/maptool/lib/app/MapTool.cfg
}

installYay() {
    local temp
    local oldPWD

    if pacman -Q yay > /dev/null; then
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
                local conf=/etc/pacman.conf
                grep "IgnorePkg   = maptool-bin" "$conf" > /dev/null || sudo sed -i 's|#IgnorePkg   =|###START ADDED BY CHEZMOI###\nIgnorePkg   = maptool-bin\n###STOP ADDED BY CHEZMOI###|' "$conf"
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

# Chech what packages needs to be removed and put them in to array
IFS=" " read -r -a toRemove <<< "$(getPackagesToRemove)"

remove "${toRemove[@]}"

# Chech what packages needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<< "$(getPackagesToInstall)"

install "${toInstall[@]}"

installMapTool

postInstallActions "${toInstall[@]}" "$MAPTOOL_PKG"
