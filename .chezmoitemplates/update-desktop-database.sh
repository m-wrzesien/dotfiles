#!/bin/bash

set -euo pipefail

# File was moved to "template" included in `.chezmoiscripts`, so it can be shellchecked

# Forces reload of database on file change
# steam.desktop hash: {{ include "dot_local/private_share/applications/steam.desktop" | sha256sum }}

update-desktop-database ~/.local/share/applications/

echo "Warning: relogin is needed, as desktop database was updated"