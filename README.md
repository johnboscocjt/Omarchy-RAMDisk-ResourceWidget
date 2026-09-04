# Omarchy-RAMDisk-ResourceWidget

Two independent Omarchy bar widgets for a top-bar resource monitor:

- `jbtechnix.ram`: RAM used/total in the bar; click for available memory, percentage, and swap details.
- `jbtechnix.disk`: root disk used/total in the bar; click for free space, percentage, and mount details.

Both widgets refresh every five seconds and use only user-level data sources: `/proc/meminfo` and `df`. They do not start services or require privileges.

## Local install

Copy the plugin folders into the user plugin directory:

```sh
mkdir -p ~/.config/omarchy/plugins
cp -a plugins/jbtechnix.ram plugins/jbtechnix.disk ~/.config/omarchy/plugins/
omarchy plugin validate ~/.config/omarchy/plugins/jbtechnix.ram
omarchy plugin validate ~/.config/omarchy/plugins/jbtechnix.disk
omarchy plugin enable jbtechnix.ram --section left --index 2
omarchy plugin enable jbtechnix.disk --section left --index 3
omarchy bar move jbtechnix.ram --section left --index 2
omarchy bar move jbtechnix.disk --section left --index 3
omarchy restart shell
```

The intended default placement is after the menu and workspaces. Omarchy does not currently provide freehand drag-and-drop for bar widgets; use `omarchy bar move` to place each widget independently in `left`, `center`, or `right`.

## Development

Edit the QML files under `~/.config/omarchy/plugins/`. Changes hot-reload in the Omarchy shell. Validate each plugin after editing:

```sh
omarchy plugin validate plugins/jbtechnix.ram
omarchy plugin validate plugins/jbtechnix.disk
journalctl --user -u omarchy-shell --since '5 minutes ago' --no-pager
```

The plugin IDs are intentionally namespaced under `jbtechnix` for local development. Rename them before marketplace submission if a different publisher namespace is required.
