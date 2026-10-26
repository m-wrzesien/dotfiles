#!/bin/bash
# force to use bash from homebrew on mac
if command -v brew >/dev/null && [[ "$(uname)" == "Darwin" && "$BASH" != "$(brew --prefix)/bin/bash" && -x "$(brew --prefix)/bin/bash" ]]; then
  exec "$(brew --prefix)/bin/bash" "$0" "$@"
fi

set -euo pipefail

echo "Configuring music player..."

if ! [ -d '/Applications/Rufin.app' ] || ! [ -d '/Applications/Music Decoy.app' ]; then
  echo "Music decoy or Rufin missing. Exiting..."
  exit 1
fi

if xattr -p com.apple.quarantine /Applications/Rufin.app; then
  echo "Removing quantime from the Rufin app..."
  xattr -dr com.apple.quarantine /Applications/Rufin.app
fi

echo "Configuring Decoy to start Rufin instead..."
defaults write com.lowtechguys.MusicDecoy mediaAppPath /Applications/Rufin.app

echo "Configuration complete. Launch MusicDecoy at least once, so it can register itself!"
