#!/bin/bash

echo "Configuring locales..."
sudo localectl set-locale LANG=en_US.UTF-8
# required for 24h format in some of gui apps (e.g Thunderbird)
sudo localectl set-locale LC_TIME=pl_PL.UTF-8
# keyboard
sudo localectl set-x11-keymap pl
sudo localectl set-keymap pl2
echo "Locales has been updated - reboot is required to apply those changes"
