#!/bin/bash

EXTENSIONS=(
    eamodio.gitlens
    EditorConfig.EditorConfig
    golang.go
    Gruntfuggly.todo-tree
    hashicorp.terraform
    ms-azuretools.vscode-docker
    ms-kubernetes-tools.vscode-kubernetes-tools
    redhat.vscode-yaml
    shardulm94.trailing-spaces
    signageos.signageos-vscode-sops
    timonwong.shellcheck
)

checkInstalation() {
    local notInstalled=()
    local installed=""
    installed=$(code --list-extensions)
    for ext in "${EXTENSIONS[@]}"; do
        if ! echo "$installed" | grep "$ext" > /dev/null; then
            notInstalled+=("$ext")
        fi
    done
    echo "${notInstalled[@]}"
}

install() {
    if [ "$#" -eq 0 ]; then
        echo "No extensions to install"
        return 0
    fi
    echo "Following extensions will be installed: $*"
    for ext in "$@"; do
        code --install-extension "$ext"
    done
}

# Chech what extensions needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<< "$(checkInstalation)"

install "${toInstall[@]}"