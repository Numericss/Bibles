#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
INSTALLED_ROOT="$HOME/Library/Application Support/obs-studio/obs-bible-plugin"
PORT="$(ruby "$SCRIPT_DIR/tools/server_config.rb")"
export OBS_BIBLE_PORT="$PORT"
DOCK_URL="http://127.0.0.1:${PORT}/obs-bible-plugin-dock/index.html"

if [[ -d "$INSTALLED_ROOT/obs-bible-plugin-dock" && -d "$INSTALLED_ROOT/obs-bible-plugin-browser" ]]; then
	ROOT="$INSTALLED_ROOT"
else
	ROOT="$SCRIPT_DIR"
fi

if ! ruby "$SCRIPT_DIR/tools/server_config.rb" --check >/dev/null 2>&1; then
	ruby "$ROOT/tools/install_server_launch_agent.rb" "$ROOT" || true
fi

for _ in {1..20}; do
	if ruby "$SCRIPT_DIR/tools/server_config.rb" --check >/dev/null 2>&1; then
		open "$DOCK_URL"
		echo "Opened Bible Dock:"
		echo "$DOCK_URL"
		echo
		ruby "$ROOT/tools/print_urls.rb" "$ROOT"
		exit 0
	fi
	sleep 0.5
done

echo "Could not reach the Bible server."
echo "Double-click Start OBS Bible Server.command, then use:"
echo "$DOCK_URL"
exit 1
