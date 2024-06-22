#!/bin/bash

set -euo pipefail

EXTENSIONS_URL=(
    https://mk12.gallery.vsassets.io/_apis/public/gallery/publisher/mk12/extension/better-git-line-blame/0.2.7/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
)

checkInstalation() {
    local notInstalled=()
    local installed=""
    installed=$(code --list-extensions)
    for ext in "${EXTENSIONS_URL[@]}"; do
        extensionName=$(awk -F "/" '{printf "%s.%s", $(NF-5), $(NF-3)}' <<< "$ext")
        if ! echo "$installed" | grep "$extensionName" > /dev/null; then
            notInstalled+=("$ext")
        fi
    done
    echo "${notInstalled[@]}"
}

install() {
    if [ "$#" -eq 0 ]; then
        echo "No extensions to install from vsix"
        return 0
    fi
    echo "Following extensions will be installed: $*"
    for ext in "$@"; do
        extensionName=$(awk -F "/" '{printf "%s.%s", $(NF-5), $(NF-3)}' <<< "$ext")
        tempDir=$(mktemp  -d)
        extensionPath="$tempDir/$extensionName.vsix"
        wget "$ext" -O "$extensionPath"
        code --install-extension "$extensionPath"
    done
}

# Chech what extensions needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<< "$(checkInstalation)"

install "${toInstall[@]}"