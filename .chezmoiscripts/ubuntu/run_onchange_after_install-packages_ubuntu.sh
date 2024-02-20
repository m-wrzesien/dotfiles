#!/bin/bash

set -euo pipefail

UBUNTU="Ubuntu"
PACKAGES=(
    # preview archives in ranger
    atool
    # provide ASCII-art image previews for ranger
    caca-utils
    codium
    dnsutils
    entr
    firefox
    gbt
    # syntax highlighter in ranger
    highlight
    hydrapaper
    jq
    keepassxc
    kitty
    # provide info about media files for ranger
    mediainfo
    meld
    ncdu
    neofetch
    # provide pdf preview for ranger
    poppler-utils
    ranger
    shellcheck
    signal-desktop
    syncthing
    # preview html pagers in ranger
    w3m
    wireshark
)

addRepo() {
    # https://support.mozilla.org/en-US/kb/install-firefox-linux#w_install-firefox-deb-package-for-debian-based-distributions
    curl -sL https://packages.mozilla.org/apt/repo-signing-key.gpg | sudo tee /etc/apt/trusted.gpg.d/packages.mozilla.org.asc > /dev/null
    echo 'deb https://packages.mozilla.org/apt mozilla main' | sudo tee /etc/apt/sources.list.d/mozilla.list >/dev/null
    echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
    curl -sL https://packagecloud.io/gbt/release/gpgkey | sudo tee /etc/apt/trusted.gpg.d/gbt.asc > /dev/null
    echo 'deb https://packagecloud.io/gbt/release/ubuntu/ xenial main' | sudo tee /etc/apt/sources.list.d/gbt.list >/dev/null
    curl -sL https://updates.signal.org/desktop/apt/keys.asc | sudo tee /etc/apt/trusted.gpg.d/signal.asc > /dev/null
    echo 'deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal.list
    curl -sL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | sudo tee /etc/apt/trusted.gpg.d/vscodium.asc > /dev/null
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

checkInstalation() {
    local notInstalled=()
    for package in "${PACKAGES[@]}"; do
        if ! dpkg -s "$package" > /dev/null; then
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
    sudo apt install "$@"
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

addRepo

# Chech what packages needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<< "$(checkInstalation)"

install "${toInstall[@]}"

postInstallActions "${toInstall[@]}"
