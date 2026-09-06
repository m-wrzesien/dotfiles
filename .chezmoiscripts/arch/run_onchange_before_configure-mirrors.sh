#!/bin/bash

set -euo pipefail

echo "Configuring pacman mirrors..."
# $ needs to be escaped
sudo tee /etc/pacman.d/mirrorlist <<EOF
## Managed by dotfiles
## Generated with https://archlinux.org/mirrorlist/?country=PL&protocol=https&ip_version=4
##
## Arch Linux repository mirrorlist
## Generated on 2026-09-06
##

## Poland
Server = https://mirror.alldaydev.com/archlinux/\$repo/os/\$arch
Server = https://ftp.icm.edu.pl/pub/Linux/dist/archlinux/\$repo/os/\$arch
Server = https://mirror.juniorjpdj.pl/archlinux/\$repo/os/\$arch
Server = https://arch.midov.pl/arch/\$repo/os/\$arch
Server = https://ftp.psnc.pl/linux/archlinux/\$repo/os/\$arch
Server = https://arch.sakamoto.pl/\$repo/os/\$arch
EOF

echo "Pacman mirrors configured"
