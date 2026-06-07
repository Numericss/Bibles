# OBS Bible Plugin for macOS

This is a macOS-ready package of the OBS Bible browser source and dock. It does not need the Windows generator app.

## Install

Double-click `Install to OBS.command`. It copies the plugin files to:

`~/Library/Application Support/obs-studio/obs-bible-plugin`

The script prints the exact Dock URL and Browser Source path after it finishes.

For the most reliable macOS setup, double-click `Start OBS Bible Server.command` after installing and keep that window open while OBS is using the Bible. It serves the dock and the Bible Text source from the same local address so they can communicate.

## Add It In OBS

1. Double-click `Start OBS Bible Server.command`.
2. In OBS, add a `Browser` source named `Bible Text`.
3. Leave `Local file` unchecked and paste this URL:

   `http://127.0.0.1:8765/obs-bible-plugin-browser/index.html`

4. Set the browser source size to match your canvas, such as `1920 x 1080`.
5. Go to `Docks > Custom Browser Docks`.
6. Add a dock named `Bible` and paste this URL:

   `http://127.0.0.1:8765/obs-bible-plugin-dock/index.html`

7. Use the dock to select a Bible, search a reference, send verses to the overlay, and show or hide the text.

Keep the server window open. The dock and browser source need the same `127.0.0.1` address so their `BroadcastChannel` connection can find the overlay.

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
