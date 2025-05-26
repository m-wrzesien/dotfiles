#!/bin/bash

set -euo pipefail

UBUNTU="Ubuntu"
PACKAGES=(
  @microsoft/compose-language-service
)

REMOVE_PACKAGES=(
  # those are installed via brew
  bash-language-server
  dockerfile-language-server-nodejs
  vscode-json-languageserver
  vscode-langservers-extracted
  yaml-language-server
)

checkDistro() {
  distroName=$(grep -Po '^NAME="\K.*(?=")' /etc/os-release)

  if [ "$distroName" != "$UBUNTU" ]; then
    return 1
  fi
}

getPackagesToInstall() {
  local output=()
  for package in "${PACKAGES[@]}"; do
    if ! npm list -g "$package" &>/dev/null; then
      output+=("$package")
    fi
  done
  echo "${output[@]}"
}

getPackagesToRemove() {
  local output=()
  for package in "${REMOVE_PACKAGES[@]}"; do
    if npm list -g "$package" &>/dev/null; then
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
  npm install -g "$@"
}

remove() {
  if [ "$#" -eq 0 ]; then
    echo "No packages to remove"
    return 0
  fi
  echo "Following packages will be removed: $*"
  npm uninstall -g "$@"
}

checkDistro || exit 0

# Chech what packages needs to be removed and put them in to array
IFS=" " read -r -a toRemove <<<"$(getPackagesToRemove)"

remove "${toRemove[@]}"

# Chech what packages needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<<"$(getPackagesToInstall)"

install "${toInstall[@]}"
