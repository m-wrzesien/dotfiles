#!/bin/bash

set -euo pipefail

YAZI_FLAVORS_DIR="$HOME/.config/yazi/flavors"

# File was moved to "template" included in `.chezmoiscripts`, so it can be shellchecked

# Forces package upgrade on file change
# package.toml hash: {{ include "dot_config/yazi/package.toml" | sha256sum }}

echo "Removing yazi flavors dir..."

if [ -d "$YAZI_FLAVORS_DIR" ]; then
  rm -rf "$YAZI_FLAVORS_DIR"
fi

echo "Upgrading yazi packages..."

ya pkg upgrade

echo "Yazi package upgrade done"
