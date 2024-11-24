#!/bin/bash

set -euo pipefail

# File was moved to "template" included in `.chezmoiscripts`, so it can be shellchecked

# Forces daemon-reload and service enable/restart on file change
# ssh-agent.service.tmpl hash: {{ include "dot_config/systemd/user/ssh-agent.service.tmpl" | sha256sum }}

systemctl --user daemon-reload
systemctl --user enable ssh-agent.service
# This will also start service that was stopped
systemctl --user restart ssh-agent.service
echo "Restart KeePassXC, as keys won't be loaded to agent until it's done"
