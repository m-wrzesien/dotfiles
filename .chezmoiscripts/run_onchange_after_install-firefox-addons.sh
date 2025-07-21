#!/bin/bash
# force to use bash from homebrew on mac
if command -v brew >/dev/null && [[ "$(uname)" == "Darwin" && "$BASH" != "$(brew --prefix)/bin/bash" && -x "$(brew --prefix)/bin/bash" ]]; then
  exec "$(brew --prefix)/bin/bash" "$0" "$@"
fi

set -euo pipefail

declare -A ADDONS REMOVE_ADDONS

# Key is addons slug and value is GUID
# https://addons-server.readthedocs.io/en/latest/topics/api/addons.html#detail
# https://addons.mozilla.org/api/v5/addons/addon/[SLUG]/
ADDONS=(
  ["addy_io"]="browser-extension@anonaddy"
  ["canvasblocker"]="CanvasBlocker@kkapsner.de"
  ["cookie-autodelete"]="CookieAutoDelete@kennydo.com"
  ["darkreader"]="addon@darkreader.org"
  ["decentraleyes"]="jid1-BoFifL9Vbdl2zQ@jetpack"
  ["edithiscookie"]="{62c00091-53f5-42d0-a4d0-9e69fc3d5819}"
  ["elasticvue"]="{2879bc11-6e9e-4d73-82c9-1ed8b78df296}"
  ["keepassxc-browser"]="keepassxc-browser@keepassxc.org"
  ["multi-account-containers"]="@testpilot-containers"
  ["polish-spellchecker-dictionary"]="pl@dictionaries.addons.mozilla.org"
  ["ublock-origin"]="uBlock0@raymondhill.net"
)

REMOVE_ADDONS=(
  ["modify-header-value"]="jid0-oEwF5ZcskGhjFv4Kk4lYc@jetpack"
)

EXTENSIONS_DIR=".config/firefox/profiles/default-release/extensions"

getAddonsToInstall() {
  local notInstalled=()
  # `!` is required to iterate over keys
  for name in "${!ADDONS[@]}"; do
    if ! [ -f "$EXTENSIONS_DIR/${ADDONS[$name]}.xpi" ] >/dev/null; then
      notInstalled+=("$name")
    fi
  done
  echo "${notInstalled[@]}"
}

getAddonsToRemove() {
  local installed=()
  # `!` is required to iterate over keys
  for name in "${!REMOVE_ADDONS[@]}"; do
    if [ -f "$EXTENSIONS_DIR/${REMOVE_ADDONS[$name]}.xpi" ] >/dev/null; then
      installed+=("$name")
    fi
  done
  echo "${installed[@]}"
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

remove() {
  if [ "$#" -eq 0 ]; then
    echo "No addons to remove"
    return 0
  fi
  echo "Following addons will be removed: $*"
  for name in "$@"; do
    rm "$EXTENSIONS_DIR/${REMOVE_ADDONS[$name]}.xpi"
    echo "Addon \"$name\" removed"
  done
}

mkdir -p "$EXTENSIONS_DIR"

# Chech what addons needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<<"$(getAddonsToInstall)"

IFS=" " read -r -a toRemove <<<"$(getAddonsToRemove)"

remove "${toRemove[@]}"

install "${toInstall[@]}"

postInstallActions "${toInstall[@]}"
