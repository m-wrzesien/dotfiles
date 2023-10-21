#!/bin/bash


ARCH="Arch Linux"
PACKAGES=(
    age
    bash-completion
    bind-tools
    chezmoi
    docker
    entr
    firefox
    gbt
    gnome-calculator-gtk3
    gnome-screenshot
    google-cloud-cli
    hydrapaper-no-pandoc-git
    jq
    keepassxc
    kitty
    kubectl
    kubectx
    meld
    neofetch
    noto-fonts
    qbittorrent
    shellcheck-bin
    signal-desktop
    syncthing
    thunderbird
    ttf-hack-nerd
    vlc
    vscodium-bin
    webcord-bin
    web-greeter
    wireguard-tools
    wireshark-qt
    x11-ssh-askpass
    yubikey-manager
)

# Version 1.13.2-1
MAPTOOL_COMMIT="e31378ba08d94f72c4d26b509e38beb8fd39ed73"
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

checkInstalation() {
    local notInstalled=()
    for package in "${PACKAGES[@]}"; do
        if ! yay -Q "$package" > /dev/null; then
            notInstalled+=("$package")
        fi
    done
    echo "${notInstalled[@]}"
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

postActions() {
    systemctl --user enable ssh-agent.service
    systemctl --user start ssh-agent.service
}

postInstallActions() {
    for package in "$@"; do
        case $package in
            docker)
                addToGrp docker
                sudo systemctl enable docker.service
                sudo systemctl start docker.service
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
# Chech what packages needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<< "$(checkInstalation)"

install "${toInstall[@]}"

installMapTool

postInstallActions "${toInstall[@]}" "$MAPTOOL_PKG"
