#!/bin/bash

echo "Disabling pcspkr..."
sudo sh -c 'echo -e  "#File added by dotfiles\nblacklist pcspkr" > /etc/modprobe.d/nobeep.conf'
echo "Speaker disabled - reboot required to apply those changes"
