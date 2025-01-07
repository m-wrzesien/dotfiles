#!/bin/bash

set -euo pipefail

HELIX_CHECKSUM="548fe3c557327e3c023dd84617b667dbb982112b2078fc288c5b4e79059d91ef"
HELIX_VERSION="v25.01"
HELIX_TMP="/tmp/helix.tar.xz"

HELM_LS_CHECKSUM="f52a23175bde03d467e44a3d8b87793ae4daec526db8b5c1ab1832eed81a584b"
HELM_LS_VERSION="v0.1.0"

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
