#!/bin/bash

set -euo pipefail
set -x

GOLANGCI_LINT_CHECKSUM="e6bd399a0479c5fd846dcf9f3990d20448b4f0d1e5027d82348eab9f80f7ac71"
GOLANGCI_LINT_VERSION="1.64.5"
GOLANGCI_LINT_TMP="/tmp/golangci-lint.tar.gz"

GOLANGCI_LINT_LANGSERVER_CHECKSUM="5c9d0be947d9e61b0df241d90e13454a38b928f011b45044c5f11d97e637caf9"
GOLANGCI_LINT_LANGSERVER_VERSION="v0.0.10"
GOLANGCI_LINT_LANGSERVER_TMP="/tmp/golangci-lint-langserver.tar.gz"

HELIX_CHECKSUM="548fe3c557327e3c023dd84617b667dbb982112b2078fc288c5b4e79059d91ef"
HELIX_VERSION="v25.01"
HELIX_TMP="/tmp/helix.tar.xz"

HELM_LS_CHECKSUM="f52a23175bde03d467e44a3d8b87793ae4daec526db8b5c1ab1832eed81a584b"
HELM_LS_VERSION="v0.1.0"

STARSHIP_CHECKSUM="cef41df04378c6f692913c5d9c1032d3b9a4369a1d2f3296c8300ed8838c2197"
STARSHIP_VERSION="v1.23.0"
STARSHIP_TMP="/tmp/starship.tar.gz"

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
