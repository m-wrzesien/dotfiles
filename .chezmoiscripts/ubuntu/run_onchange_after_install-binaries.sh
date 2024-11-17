#!/bin/bash

set -euo pipefail

CHECKSUM="f52a23175bde03d467e44a3d8b87793ae4daec526db8b5c1ab1832eed81a584b"
VERSION="v0.1.0"

curl -L https://github.com/mrjosh/helm-ls/releases/download/${VERSION}/helm_ls_linux_amd64 --output ~/.local/bin/helm_ls
echo "${CHECKSUM} ${HOME}/.local/bin/helm_ls" | sha256sum --check --status
chmod +x ~/.local/bin/helm_ls
