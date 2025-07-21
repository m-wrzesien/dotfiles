#!/bin/bash
# force to use bash from homebrew on mac
if command -v brew >/dev/null && [[ "$(uname)" == "Darwin" && "$BASH" != "$(brew --prefix)/bin/bash" && -x "$(brew --prefix)/bin/bash" ]]; then
  exec "$(brew --prefix)/bin/bash" "$0" "$@"
fi

set -euo pipefail

EXTENSIONS_URL=(
  https://mk12.gallery.vsassets.io/_apis/public/gallery/publisher/mk12/extension/better-git-line-blame/0.2.14/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
)

checkInstalation() {
  local notInstalled=()
  local installed=""
  installed=$(code --list-extensions --show-versions)
  for ext in "${EXTENSIONS_URL[@]}"; do
    extensionName=$(awk -F "/" '{printf "%s.%s", $(NF-5), $(NF-3)}' <<<"$ext")
    extensionVersion=$(awk -F "/" '{print $(NF-2)}' <<<"$ext")
    if ! echo "$installed" | grep "$extensionName" >/dev/null; then
      notInstalled+=("$ext")
    fi
    if ! echo "$installed" | grep "$extensionName" | awk -F "@" '{print $2}' | grep "$extensionVersion" >/dev/null; then
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
    extensionName=$(awk -F "/" '{printf "%s.%s", $(NF-5), $(NF-3)}' <<<"$ext")
    tempDir=$(mktemp -d)
    extensionPath="$tempDir/$extensionName.vsix"
    curl "$ext" -o "$extensionPath"
    code --install-extension "$extensionPath"
  done
}

# Chech what extensions needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<<"$(checkInstalation)"

install "${toInstall[@]}"
