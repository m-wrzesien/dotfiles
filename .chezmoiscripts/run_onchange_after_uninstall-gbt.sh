#!/bin/bash
# Script for removal of gbt as starship has replaced it
set -euo pipefail

if [ -d "$HOME/.cache/chezmoi_gbt" ]; then
  rm -rf "$HOME/.cache/chezmoi_gbt"
  echo "Dir for building gbt removed"
fi

if [ -f "$(which gbt)" ]; then
  rm "$(which gbt)"
  echo "gbt removed"
fi
