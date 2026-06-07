#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
DEST="$HOME/Library/Application Support/obs-studio/obs-bible-plugin"

mkdir -p "$DEST"
ditto "$SCRIPT_DIR/obs-bible-plugin-browser" "$DEST/obs-bible-plugin-browser"
ditto "$SCRIPT_DIR/obs-bible-plugin-dock" "$DEST/obs-bible-plugin-dock"
ditto "$SCRIPT_DIR/tools" "$DEST/tools"
cp "$SCRIPT_DIR/Start OBS Bible Server.command" "$DEST/Start OBS Bible Server.command"
chmod +x "$DEST/Start OBS Bible Server.command" "$DEST/tools/"*.rb

echo "Installed OBS Bible Plugin for macOS to:"
echo "$DEST"
echo
ruby "$SCRIPT_DIR/tools/print_urls.rb" "$DEST"
echo
echo "For the most reliable OBS setup, double-click:"
echo "$DEST/Start OBS Bible Server.command"
echo
echo "Then use the 127.0.0.1 URLs printed by that window in OBS."
