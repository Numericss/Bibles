# OBS Bible Plugin for macOS

macOS OBS Bible browser dock and overlay: pick a verse in the dock, send it to a live lower-third overlay. Runs a small local server on `127.0.0.1:8765` so the dock and Browser Source can talk. No Windows generator app required.

**Related:** Companion tooling for church streaming / [VIDA TV](https://github.com/Numericss/VidaTV) production workflows. This plugin is optional and does not depend on that stack.

## Install

Double-click `Install to OBS.command`. It copies the plugin files to:

`~/Library/Application Support/obs-studio/obs-bible-plugin`

The script prints the exact HTTP URLs for the dock and Browser Source after it finishes.

The installer also starts a small local Bible server at `127.0.0.1:8765`. It serves the dock and the Bible Text source from the same local address so they can communicate. If the local server ever stops, double-click `Start OBS Bible Server.command`.

## Add It In OBS

Always include port `8765`: opening `http://127.0.0.1:8765/` takes you directly to the dock.

1. In OBS, add a `Browser` source named `Bible Text`.
2. Leave `Local file` unchecked and paste this URL:

   `http://127.0.0.1:8765/obs-bible-plugin-browser/index.html`

3. Set the browser source size to match your canvas, such as `1920 x 1080`.
4. Go to `Docks > Custom Browser Docks`.
5. Add a dock named `Bible` and paste this URL:

   `http://127.0.0.1:8765/obs-bible-plugin-dock/index.html`

6. Use the dock to select a Bible, search a reference, send verses to the overlay, and show or hide the text.

The dock and browser source need the same `127.0.0.1` address so their `BroadcastChannel` connection can find the overlay.

## Match The Target Layout

The target OBS layout is:

1. A background `Image` source at the bottom of the scene.
2. The `Bible Overlay` browser source above the background image.
3. A right-side custom browser dock named `Bible`.
4. The dock opened to a passage list, such as `John 3:1-36 (KJV)`.
5. One selected verse sent to the lower-third overlay.

For the lower-third style shown in the target screenshot, open the dock's theme tab and use `Bookmark: Purple`. It gives the purple banner-style overlay with the reference on the left, translation on the right, and verse text underneath.

## Included Bibles

The package includes the original JavaScript Bibles plus converted OpenLP/SQLite Bibles from the supplied folder. To rebuild the generated Bible files, double-click `Rebuild Bibles.command`.

## If macOS Blocks A Script

Right-click the `.command` file and choose `Open`, or run this from Terminal inside the package folder:

```zsh
chmod +x *.command tools/*.rb
```

## Server Troubleshooting

The installer checks the Bible server's `/healthz` endpoint before reporting
success. If startup fails, read `server.err.log` in the installed plugin folder.
An unrelated app listening on the same port is not considered a working Bible server.

To use another port, run the installer from Terminal:

```zsh
OBS_BIBLE_PORT=8766 zsh "Install to OBS.command"
```

Use the printed URLs for **both** the dock and overlay. The port is saved in the
launch agent. When running the Open/Start helpers from Terminal, pass that same
`OBS_BIBLE_PORT`; double-clicking those helpers uses the default `8765`.
Invalid ports fail with an explanation instead of silently using another port.

## Development Checks

```zsh
ruby tests/server_test.rb
```

The tests start temporary loopback servers and do not install or modify an OBS
launch agent. They cover readiness, unrelated servers, routing, allowed assets,
custom-port URLs, and invalid ports.

The dock is supplied as compiled React bundles, and the overlay JavaScript is
obfuscated. Original frontend sources and a reproducible build are needed for
maintainable changes to searching, keyboard controls, and overlay rendering.
