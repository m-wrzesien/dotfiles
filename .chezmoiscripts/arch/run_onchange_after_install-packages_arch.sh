#!/bin/bash

ARCH="Arch Linux"
PACKAGES=(
    age
    bash-completion
    chezmoi
    firefox
    gbt
    hydrapaper-no-pandoc-git
    jq
    keepassxc
    kitty
    kubectl
    kubectx
    neofetch
    noto-fonts
    shellcheck-bin
    signal-desktop
    syncthing
    thunderbird
    ttf-hack-nerd
    vscodium-bin
    webcord-bin
    web-greeter
    wireguard-tools
    x11-ssh-askpass
    yubikey-manager
)

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
        echo "$package"
        case $package in
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

installYay
# Chech what packages needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<< "$(checkInstalation)"

install "${toInstall[@]}"

postInstallActions "${toInstall[@]}"
