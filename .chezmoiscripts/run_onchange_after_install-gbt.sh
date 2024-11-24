#!/bin/bash
# Script build & install gbt manually, based on specific commit
# It was added, as this wasn't released for the long time, while changes are still being made
# TODO: look for some replacement?
set -euo pipefail

# Latest main, as of 26.02.2024
COMMIT="df9991cceca64baa6e76602c6e38befe9c04a1d9"
PKG="gbt"
URL="git@github.com:jtyr/gbt.git"

cdOrFail() {
  cd "$1" || echo "Can't cd. $1 not found"
}

installGbt() {
  mkdir -p "$HOME/.cache/chezmoi_$PKG"
  cdOrFail "$HOME/.cache/chezmoi_$PKG"
  if ! [ -d "$PKG" ]; then
    git clone "$URL"
  fi
  cdOrFail "$PKG"
  git checkout main
  git pull
  git checkout "$COMMIT"
  cdOrFail "cmd/$PKG"
  go build
  mkdir -p "$HOME/.local/bin/"
  cp $PKG "$HOME/.local/bin/"
}

installGbt
