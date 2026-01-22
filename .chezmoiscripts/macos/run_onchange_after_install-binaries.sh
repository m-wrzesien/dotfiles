#!/bin/bash
# force to use bash from homebrew on mac
if command -v brew >/dev/null && [[ "$(uname)" == "Darwin" && "$BASH" != "$(brew --prefix)/bin/bash" && -x "$(brew --prefix)/bin/bash" ]]; then
  exec "$(brew --prefix)/bin/bash" "$0" "$@"
fi

set -euo pipefail
set -x

echo "$PATH"

JSONNET_LANGUAGE_SERVER_CHECKSUM="8b6e642374d3004c3ac35254874ed1d14203a85c979f6684fc6218f58a8072d4"
JSONNET_LANGUAGE_SERVER_VERSION="0.16.0"
JSONNET_LANGUAGE_SERVER_BINARY="jsonnet-language-server"

MPLS_CHECKSUM="bbad22f50544576d8b255d3f3161f8868509fd50377dc5d18a03a72cfd221b16"
MPLS_VERSION="0.17.0"
MPLS_BINARY="mpls"
MPLS_ARCHIVE_PATH="/tmp/mpls.tar.gz"

curl -L "https://github.com/grafana/jsonnet-language-server/releases/download/v${JSONNET_LANGUAGE_SERVER_VERSION}/jsonnet-language-server_${JSONNET_LANGUAGE_SERVER_VERSION}_darwin_arm64" --output "${HOME}/.local/bin/${JSONNET_LANGUAGE_SERVER_BINARY}"
echo "${JSONNET_LANGUAGE_SERVER_CHECKSUM} ${HOME}/.local/bin/${JSONNET_LANGUAGE_SERVER_BINARY}" | sha256sum --check --status
chmod +x "${HOME}/.local/bin/${JSONNET_LANGUAGE_SERVER_BINARY}"

curl -L "https://github.com/mhersson/mpls/releases/download/v${MPLS_VERSION}/mpls_${MPLS_VERSION}_darwin_arm64.tar.gz" --output "${MPLS_ARCHIVE_PATH}"
echo "${MPLS_CHECKSUM} ${MPLS_ARCHIVE_PATH}" | sha256sum --check --status
tar -C "${HOME}/.local/bin" -xzf "${MPLS_ARCHIVE_PATH}" "${MPLS_BINARY}"
