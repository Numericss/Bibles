#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
ruby "$SCRIPT_DIR/tools/build_bibles.rb"
echo
echo "Rebuilt Bibles. Installing the rebuilt files to OBS and restarting the local server..."
echo
zsh "$SCRIPT_DIR/Install to OBS.command"
