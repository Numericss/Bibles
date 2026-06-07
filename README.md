# OBS Bible Plugin for macOS

This is a macOS-ready package of the OBS Bible browser source and dock. It does not need the Windows generator app.

## Install

Double-click `Install to OBS.command`. It copies the plugin files to:

`~/Library/Application Support/obs-studio/obs-bible-plugin`

The script prints the exact Dock URL and Browser Source path after it finishes.

## Add It In OBS

1. In OBS, add a `Browser` source named `Bible Overlay`.
2. Enable `Local file` and choose `obs-bible-plugin-browser/index.html` from the installed folder.
3. Set the browser source size to match your canvas, such as `1920 x 1080`.
4. Go to `Docks > Custom Browser Docks`.
5. Add a dock named `Bible` and paste the printed `Bible Dock URL`.
6. Use the dock to select a Bible, search a reference, send verses to the overlay, and show or hide the text.

Keep the dock and browser source files from the same installed folder so their `BroadcastChannel` connection can find the overlay.

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
