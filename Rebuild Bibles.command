#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
ruby "$SCRIPT_DIR/tools/build_bibles.rb"
echo
ruby "$SCRIPT_DIR/tools/print_urls.rb" "$SCRIPT_DIR"
