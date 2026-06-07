#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
INSTALLED_ROOT="$HOME/Library/Application Support/obs-studio/obs-bible-plugin"
PORT="${OBS_BIBLE_PORT:-8765}"
DOCK_URL="http://127.0.0.1:${PORT}/obs-bible-plugin-dock/index.html"

if [[ -d "$INSTALLED_ROOT/obs-bible-plugin-dock" && -d "$INSTALLED_ROOT/obs-bible-plugin-browser" ]]; then
	ROOT="$INSTALLED_ROOT"
else
	ROOT="$SCRIPT_DIR"
fi

if ! curl -fsS "$DOCK_URL" >/dev/null 2>&1; then
	ruby "$ROOT/tools/install_server_launch_agent.rb" "$ROOT" || true
fi

for _ in {1..20}; do
	if curl -fsS "$DOCK_URL" >/dev/null 2>&1; then
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
