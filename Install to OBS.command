#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
DEST="$HOME/Library/Application Support/obs-studio/obs-bible-plugin"

mkdir -p "$DEST"
ditto "$SCRIPT_DIR/obs-bible-plugin-browser" "$DEST/obs-bible-plugin-browser"
ditto "$SCRIPT_DIR/obs-bible-plugin-dock" "$DEST/obs-bible-plugin-dock"

echo "Installed OBS Bible Plugin for macOS to:"
echo "$DEST"
echo
ruby "$SCRIPT_DIR/tools/print_urls.rb" "$DEST"
echo
echo "Opening the dock in your default browser for a quick smoke test..."
open "$DEST/obs-bible-plugin-dock/index.html"
