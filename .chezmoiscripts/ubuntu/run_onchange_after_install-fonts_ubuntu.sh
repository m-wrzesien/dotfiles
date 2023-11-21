#!/bin/bash

# Key is font name and value is sha256sum
FONTS=(
    ["Hack"]="1fd74197a196dcd70bc37c811c3a629acf7554c1fb45b4b48c634a7c75953e41"
)

VERSION='3.1.0'
FONTS_DIR="${HOME}/.local/share/fonts"

if [[ ! -d "$FONTS_DIR" ]]; then
    mkdir -p "$FONTS_DIR"
fi

for font in "${FONTS[@]}"; do
    zip_file="${font}.zip"
    download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${VERSION}/${zip_file}"
    echo "Downloading $download_url"
    wget "$download_url"
    echo "${FONTS[$name]} ${zip_file}" | sha256sum -c
    unzip "$zip_file" -d "$FONTS_DIR" -x "*.txt/*" -x "*.md/*"
    rm "$zip_file"
done

find "$FONTS_DIR" -name '*Windows Compatible*' -delete

fc-cache -fv
