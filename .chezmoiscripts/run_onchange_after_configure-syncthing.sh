#!/bin/bash

set -euo pipefail

# Disable global discovery
# https://docs.syncthing.net/users/config#config-option-options.globalannounceenabled
syncthing cli config options global-ann-enabled set false
# Disable NAT traversal
# https://docs.syncthing.net/users/config#config-option-options.natenabled
syncthing cli config options natenabled set false
# Disable usage of relays
# https://docs.syncthing.net/users/config#config-option-options.relaysenabled
syncthing cli config options relays-enabled set false

# Setting up folder defaults
# Creating base folder used for synchronization
mkdir -p "$HOME/Documents/Syncthing"
syncthing cli config defaults folder path set "$HOME/Documents/Syncthing"
# Set default versioning type to simple
# https://docs.syncthing.net/users/versioning#simple-file-versioning
syncthing cli config defaults folder versioning type set simple