#!/bin/bash

UBUNTU="Ubuntu"
PACKAGES=(
    codium
    dnsutils
    entr
    firefox
    gbt
    hydrapaper
    jq
    keepassxc
    kitty
    meld
    neofetch
    shellcheck
    signal-desktop
    syncthing
    wireshark
)

addRepo() {
    sudo add-apt-repository -y ppa:mozillateam/ppa
    curl -sL https://packagecloud.io/gbt/release/gpgkey | sudo tee /etc/apt/trusted.gpg.d/gbt.asc > /dev/null
    echo 'deb https://packagecloud.io/gbt/release/ubuntu/ xenial main' | sudo tee /etc/apt/sources.list.d/gbt.list >/dev/null
    curl -sL https://updates.signal.org/desktop/apt/keys.asc | sudo tee /etc/apt/trusted.gpg.d/signal.asc > /dev/null
    echo 'deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal.list
    curl -sL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | sudo tee /etc/apt/trusted.gpg.d/vscodium.asc > /dev/null
    echo 'deb https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
    sudo apt-get update
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
    sudo apt-get install "$@"
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

# postInstallActions "${toInstall[@]}"
