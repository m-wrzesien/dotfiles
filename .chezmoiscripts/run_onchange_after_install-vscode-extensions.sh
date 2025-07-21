#!/bin/bash
# force to use bash from homebrew on mac
if command -v brew >/dev/null && [[ "$(uname)" == "Darwin" && "$BASH" != "$(brew --prefix)/bin/bash" && -x "$(brew --prefix)/bin/bash" ]]; then
  exec "$(brew --prefix)/bin/bash" "$0" "$@"
fi

set -euo pipefail

EXTENSIONS=(
  editorconfig.editorconfig
  golang.go
  gruntfuggly.todo-tree
  hashicorp.terraform
  html-validate.vscode-html-validate
  ms-azuretools.vscode-docker
  ms-kubernetes-tools.vscode-kubernetes-tools
  redhat.ansible
  redhat.vscode-yaml
  reduckted.vscode-gitweblinks
  shardulm94.trailing-spaces
  signageos.signageos-vscode-sops
  timonwong.shellcheck
)

REMOVE_EXTENSIONS=(
  eamodio.gitlens
  ziyasal.vscode-open-in-github
)

getExtensionsToInstall() {
  local notInstalled=()
  local installed=""
  installed=$(code --list-extensions)
  for ext in "${EXTENSIONS[@]}"; do
    if ! echo "$installed" | grep "$ext" >/dev/null; then
      notInstalled+=("$ext")
    fi
  done
  echo "${notInstalled[@]}"
}

getExtensionsToRemove() {
  local toRemove=()
  local installed=""
  installed=$(code --list-extensions)
  for ext in "${REMOVE_EXTENSIONS[@]}"; do
    if echo "$installed" | grep "$ext" >/dev/null; then
      toRemove+=("$ext")
    fi
  done
  echo "${toRemove[@]}"
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

remove() {
  if [ "$#" -eq 0 ]; then
    echo "No extensions to remove"
    return 0
  fi
  echo "Following extensions will be removed: $*"
  for ext in "$@"; do
    code --uninstall-extension "$ext"
  done
}

# Chech what extensions needs to be removed and put them in to array
IFS=" " read -r -a toRemove <<<"$(getExtensionsToRemove)"

remove "${toRemove[@]}"

# Chech what extensions needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<<"$(getExtensionsToInstall)"

install "${toInstall[@]}"
