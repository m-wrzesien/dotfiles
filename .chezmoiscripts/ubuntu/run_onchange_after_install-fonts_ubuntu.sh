#!/bin/bash

set -euo pipefail

declare -A FONTS

# Key is font name and value is sha256sum
FONTS=(
  ["Hack"]="1fd74197a196dcd70bc37c811c3a629acf7554c1fb45b4b48c634a7c75953e41"
)

VERSION='3.1.0'
FONTS_DIR="${HOME}/.local/share/fonts"

if [[ ! -d "$FONTS_DIR" ]]; then
  mkdir -p "$FONTS_DIR"
fi

# `!` is required to iterate over keys
for font in "${!FONTS[@]}"; do
  zip_file="${font}.zip"
  zip_file_location="/tmp/$zip_file"
  download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${VERSION}/${zip_file}"
  echo "Downloading $download_url"
  wget "$download_url" -O "$zip_file_location"
  echo "Checking checksum..."
  echo "${FONTS[$font]} ${zip_file_location}" | sha256sum -c
  unzip "$zip_file_location" -d "$FONTS_DIR" -x "*.txt/*" -x "*.md/*"
  rm "$zip_file_location"
done

find "$FONTS_DIR" -name '*Windows Compatible*' -delete

fc-cache -fv
