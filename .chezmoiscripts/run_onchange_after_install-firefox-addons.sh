#!/bin/bash

set -euo pipefail

declare -A ADDONS


# Key is addons slug and value is GUID
# https://addons-server.readthedocs.io/en/latest/topics/api/addons.html#detail
ADDONS=(
    ["addy_io"]="browser-extension@anonaddy"
    ["canvasblocker"]="CanvasBlocker@kkapsner.de"
    ["cookie-autodelete"]="CookieAutoDelete@kennydo.com"
    ["darkreader"]="addon@darkreader.org"
    ["decentraleyes"]="jid1-BoFifL9Vbdl2zQ@jetpack"
    ["edithiscookie"]="{62c00091-53f5-42d0-a4d0-9e69fc3d5819}"
    ["modify-header-value"]="jid0-oEwF5ZcskGhjFv4Kk4lYc@jetpack"
    ["multi-account-containers"]="@testpilot-containers"
    ["ublock-origin"]="uBlock0@raymondhill.net"
)

EXTENSIONS_DIR=".config/firefox/profiles/default-release/extensions"


checkInstalation() {
    local notInstalled=()
    for name in "${!ADDONS[@]}"; do
        if ! [ -f "$EXTENSIONS_DIR/${ADDONS[$name]}.xpi" ] > /dev/null; then
            notInstalled+=("$name")
        fi
    done
    echo "${notInstalled[@]}"
}

install() {
    if [ "$#" -eq 0 ]; then
        echo "No addons to install"
        return 0
    fi
    echo "Following addons will be installed: $*"
    for name in "$@"; do
        fileURL=$(curl -s "https://addons.mozilla.org/api/v5/addons/addon/$name/" | jq -r .current_version.file.url)
        curl -s -o "$EXTENSIONS_DIR/${ADDONS[$name]}.xpi" "$fileURL"
        echo "Addon \"$name\" installed"
    done
}

postInstallActions() {
    for addon in "$@"; do
        case $addon in
            addy_io)
                echo "Remember about logging in using API key"
                ;;
            cookie-autodelete)
                echo "Remember to set following settings:"
                echo "'Enable Automatic Cleaning'"
                echo "'Enable Support for Container Tabs'"
                ;;
            *)
                echo "No action for $addon"
                ;;
        esac
    done
}

mkdir -p "$EXTENSIONS_DIR"

# Chech what addons needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<< "$(checkInstalation)"

install "${toInstall[@]}"

postInstallActions "${toInstall[@]}"