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

server_is_up() {
	ruby "$SCRIPT_DIR/tools/server_config.rb" --check >/dev/null 2>&1
}

if ! server_is_up; then
	ruby "$ROOT/tools/install_server_launch_agent.rb" "$ROOT" || true
fi

for _ in {1..20}; do
	if server_is_up; then
		echo "OBS Bible server is running."
		echo
		echo "Opening Bible Dock:"
		echo "$DOCK_URL"
		open "$DOCK_URL"
		echo
		echo "Bible Text Browser Source URL:"
		echo "http://127.0.0.1:${PORT}/obs-bible-plugin-browser/index.html"
		exit 0
	fi
	sleep 0.5
done

echo "Auto-start did not respond, so this window will run the Bible server directly."
echo "Leave this window open while using OBS."
echo
ruby "$ROOT/tools/obs_bible_server.rb" "$ROOT" &
SERVER_PID="$!"

for _ in {1..20}; do
	if server_is_up; then
		open "$DOCK_URL"
		break
	fi
	sleep 0.5
done

wait "$SERVER_PID"
