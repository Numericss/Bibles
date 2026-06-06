#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
open "$SCRIPT_DIR/obs-bible-plugin-dock/index.html"
ruby "$SCRIPT_DIR/tools/print_urls.rb" "$SCRIPT_DIR"
