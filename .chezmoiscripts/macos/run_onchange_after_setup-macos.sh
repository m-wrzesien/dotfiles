#!/bin/bash

echo "Starting script for configuring macos"

################################################################################
# AltTab setup
################################################################################

defaults write com.lwouis.alt-tab-macos showWindowlessApps -int 1
# hide windows fom non-visible spaces
# this help with some software that isn't visible by default in Apple app/window switcher
defaults write com.lwouis.alt-tab-macos spacesToShow -int 1
# disable window about new version - brew is used for that
defaults write com.lwouis.alt-tab-macos SUEnableAutomaticChecks -int 0

################################################################################
# Rectangle setup
################################################################################

defaults write com.knollsoft.Rectangle almostMaximize {}
defaults write com.knollsoft.Rectangle bottomHalf {}
defaults write com.knollsoft.Rectangle bottomLeft {}
defaults write com.knollsoft.Rectangle bottomRight {}
defaults write com.knollsoft.Rectangle center {}
defaults write com.knollsoft.Rectangle larger {}
defaults write com.knollsoft.Rectangle launchOnLogin -int 1
defaults write com.knollsoft.Rectangle leftHalf '{ keyCode = 123; modifierFlags = 1048576;}'
defaults write com.knollsoft.Rectangle maximize '{ keyCode = 126; modifierFlags = 1048576;}'
defaults write com.knollsoft.Rectangle maximizeHeight {}
defaults write com.knollsoft.Rectangle nextDisplay '{ keyCode = 123; modifierFlags = 1179648;}'
defaults write com.knollsoft.Rectangle previousDisplay '{ keyCode = 124; modifierFlags = 1179648;}'
defaults write com.knollsoft.Rectangle restore {}
defaults write com.knollsoft.Rectangle rightHalf '{ keyCode = 124; modifierFlags = 1048576;}'
defaults write com.knollsoft.Rectangle smaller {}
defaults write com.knollsoft.Rectangle topHalf {}
defaults write com.knollsoft.Rectangle topLeft {}
defaults write com.knollsoft.Rectangle topRight {}
# don't move to different display on repeated commands
# https://github.com/rxhanson/Rectangle/blob/main/TerminalCommands.md#adjust-behavior-on-repeated-commands
defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 2

################################################################################
# System Preferences > Keyboard
################################################################################

# Enable key repeat
defaults write -globalDomain ApplePressAndHoldEnabled -bool false
# Speed it up
defaults write -globalDomain InitialKeyRepeat -int 15
defaults write -globalDomain KeyRepeat -int 2

# Click FN to use function keys (e.g mute audio)
defaults write -globalDomain com.apple.keyboard.fnState -bool true

# Txt Input > Correct spelling automatically
defaults write -globalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Txt Input > Capitalise words automatically
defaults write -globalDomain NSAutomaticCapitalizationEnabled -bool false

# Txt Input > Add full stop with double-space
defaults write -globalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

################################################################################
# Other
################################################################################
# speedup mouse
defaults write -globalDomain com.apple.mouse.scaling -float "0.875"
# disable mouse acceleration
defaults write -globalDomain com.apple.mouse.linear -bool "true"

# Show all filename extensions
defaults write -globalDomain AppleShowAllExtensions -bool true

# Autohide dock
defaults write com.apple.dock autohide -bool true

defaults write com.apple.dock show-recents -bool false

# Kill affected apps
for app in "Dock" "Finder"; do
  killall "${app}" >/dev/null 2>&1
done

# Done
echo "Done. Note that some of these changes require a logout/restart to take effect."
