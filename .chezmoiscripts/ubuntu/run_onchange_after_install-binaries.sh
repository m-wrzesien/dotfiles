#!/bin/bash

set -euo pipefail
set -x

GOLANGCI_LINT_CHECKSUM="e55e0eb515936c0fbd178bce504798a9bd2f0b191e5e357768b18fd5415ee541"
GOLANGCI_LINT_VERSION="2.1.6"
GOLANGCI_LINT_TMP="/tmp/golangci-lint.tar.gz"

GOLANGCI_LINT_LANGSERVER_CHECKSUM="b4efa95267c29ca4d08e0a977e90e7c6a8a606bafe1dcedfd5e48e952536b331"
GOLANGCI_LINT_LANGSERVER_VERSION="v0.0.11"
GOLANGCI_LINT_LANGSERVER_TMP="/tmp/golangci-lint-langserver.tar.gz"

HELIX_CHECKSUM="548fe3c557327e3c023dd84617b667dbb982112b2078fc288c5b4e79059d91ef"
HELIX_VERSION="v25.01"
HELIX_TMP="/tmp/helix.tar.xz"

HELM_LS_CHECKSUM="13facde6db4d30202a9cba0ebc4445869a9008da26840583462f6ab0f2b30349"
HELM_LS_VERSION="v0.2.2"

STARSHIP_CHECKSUM="cef41df04378c6f692913c5d9c1032d3b9a4369a1d2f3296c8300ed8838c2197"
STARSHIP_VERSION="v1.23.0"
STARSHIP_TMP="/tmp/starship.tar.gz"

YAZI_CHECKSUM="01128a2d9d79018721cc557976ade57c28c61daa47e9f7207f2cbd3d5553a734"
YAZI_VERSION="25.4.8"
YAZI_TMP="/tmp/yazi.zip"

curl -L https://github.com/mrjosh/helm-ls/releases/download/${HELM_LS_VERSION}/helm_ls_linux_amd64 --output ~/.local/bin/helm_ls
echo "${HELM_LS_CHECKSUM} ${HOME}/.local/bin/helm_ls" | sha256sum --check --status
chmod +x ~/.local/bin/helm_ls

curl -L https://github.com/zydou/helix/releases/download/${HELIX_VERSION}/helix-${HELIX_VERSION}-x86_64-unknown-linux-gnu.tar.xz --output ${HELIX_TMP}
trap 'rm ${HELIX_TMP}' EXIT
echo "${HELIX_CHECKSUM} ${HELIX_TMP}" | sha256sum --check --status
if [ -f "$HOME/.local/bin/hx" ]; then
  rm -r "${HOME}"/.local/bin/{hx,runtime}
fi
tar -xf ${HELIX_TMP} --strip-components=1 -C "${HOME}/.local/bin/" helix-${HELIX_VERSION}-x86_64-unknown-linux-gnu/{hx,runtime}

curl -L https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64.tar.gz --output ${GOLANGCI_LINT_TMP}
trap 'rm ${GOLANGCI_LINT_TMP}' EXIT
echo "${GOLANGCI_LINT_CHECKSUM} ${GOLANGCI_LINT_TMP}" | sha256sum --check --status
tar -xf ${GOLANGCI_LINT_TMP} --strip-components=1 -C "${HOME}/.local/bin/" golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64/golangci-lint

curl -L https://github.com/nametake/golangci-lint-langserver/releases/download/${GOLANGCI_LINT_LANGSERVER_VERSION}/golangci-lint-langserver_Linux_x86_64.tar.gz --output ${GOLANGCI_LINT_LANGSERVER_TMP}
trap 'rm ${GOLANGCI_LINT_LANGSERVER_TMP}' EXIT
echo "${GOLANGCI_LINT_LANGSERVER_CHECKSUM} ${GOLANGCI_LINT_LANGSERVER_TMP}" | sha256sum --check --status
tar -xf ${GOLANGCI_LINT_LANGSERVER_TMP} -C "${HOME}/.local/bin/"

curl -L "https://github.com/starship/starship/releases/download/${STARSHIP_VERSION}/starship-x86_64-unknown-linux-gnu.tar.gz" --output "${STARSHIP_TMP}"
echo "${STARSHIP_CHECKSUM} ${STARSHIP_TMP}" | sha256sum --check --status
trap 'rm ${STARSHIP_TMP}' EXIT
tar -xf "${STARSHIP_TMP}" -C "${HOME}/.local/bin/"

curl -L https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-x86_64-unknown-linux-musl.zip --output ${YAZI_TMP}
trap 'rm ${YAZI_TMP}' EXIT
echo "${YAZI_CHECKSUM} ${YAZI_TMP}" | sha256sum --check --status
unzip -j -d "${HOME}/.local/bin/" ${YAZI_TMP} yazi-x86_64-unknown-linux-musl/{ya,yazi}
# install all yazi packages (like flavors)
ya pack -u
