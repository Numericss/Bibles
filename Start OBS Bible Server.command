#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
INSTALLED_ROOT="$HOME/Library/Application Support/obs-studio/obs-bible-plugin"

if [[ -d "$INSTALLED_ROOT/obs-bible-plugin-dock" && -d "$INSTALLED_ROOT/obs-bible-plugin-browser" ]]; then
	ROOT="$INSTALLED_ROOT"
else
	ROOT="$SCRIPT_DIR"
fi

ruby "$SCRIPT_DIR/tools/obs_bible_server.rb" "$ROOT"
