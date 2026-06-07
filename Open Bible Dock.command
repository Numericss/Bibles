#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
open "http://127.0.0.1:${OBS_BIBLE_PORT:-8765}/obs-bible-plugin-dock/index.html"
ruby "$SCRIPT_DIR/tools/print_urls.rb" "$SCRIPT_DIR"
