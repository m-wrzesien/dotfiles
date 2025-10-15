#!/bin/bash

echo "Starting script for configuring macos"

################################################################################
# AltTab setup
################################################################################

defaults write com.lwouis.alt-tab-macos showWindowlessApps -int 1

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

################################################################################
# System Preferences > Keyboard
################################################################################

# Enable key repeat
defaults write -globaldomain ApplePressAndHoldEnabled -bool false

# Txt Input > Correct spelling automatically
defaults write -globalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Txt Input > Capitalise words automatically
defaults write -globalDomain NSAutomaticCapitalizationEnabled -bool false

# Txt Input > Add full stop with double-space
defaults write -globalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

################################################################################
# Finder > Preferences
################################################################################

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Kill affected apps
for app in "Dock" "Finder"; do
  killall "${app}" >/dev/null 2>&1
done

# Done
echo "Done. Note that some of these changes require a logout/restart to take effect."
