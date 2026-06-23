#!/bin/bash
# force to use bash from homebrew on mac
if command -v brew >/dev/null && [[ "$(uname)" == "Darwin" && "$BASH" != "$(brew --prefix)/bin/bash" && -x "$(brew --prefix)/bin/bash" ]]; then
  exec "$(brew --prefix)/bin/bash" "$0" "$@"
fi

set -euo pipefail
set -x

echo "$PATH"

KUBECTL_ARGO_ROLLOUT_CHECKSUM="e822127ff7a783739c23b0f9e3005910f4cb7cf5b52a281cbf41c409fa3c9e80"
KUBECTL_ARGO_ROLLOUT_VERSION="1.9.0"
KUBECTL_ARGO_ROLLOUT_BINARY="kubectl-argo-rollouts"

MPLS_CHECKSUM="bbad22f50544576d8b255d3f3161f8868509fd50377dc5d18a03a72cfd221b16"
MPLS_VERSION="0.17.0"
MPLS_BINARY="mpls"
MPLS_ARCHIVE_PATH="/tmp/mpls.tar.gz"

curl -L "https://github.com/argoproj/argo-rollouts/releases/download/v${KUBECTL_ARGO_ROLLOUT_VERSION}/kubectl-argo-rollouts-darwin-arm64" --output "${HOME}/.local/bin/${KUBECTL_ARGO_ROLLOUT_BINARY}"
echo "${KUBECTL_ARGO_ROLLOUT_CHECKSUM} ${HOME}/.local/bin/${KUBECTL_ARGO_ROLLOUT_BINARY}" | sha256sum --check --status
chmod +x "${HOME}/.local/bin/${KUBECTL_ARGO_ROLLOUT_BINARY}"

curl -L "https://github.com/mhersson/mpls/releases/download/v${MPLS_VERSION}/mpls_${MPLS_VERSION}_darwin_arm64.tar.gz" --output "${MPLS_ARCHIVE_PATH}"
echo "${MPLS_CHECKSUM} ${MPLS_ARCHIVE_PATH}" | sha256sum --check --status
tar -C "${HOME}/.local/bin" -xzf "${MPLS_ARCHIVE_PATH}" "${MPLS_BINARY}"
