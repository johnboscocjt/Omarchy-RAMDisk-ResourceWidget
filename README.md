# Omarchy RAMDisk Resource Widget

An Omarchy top-bar widget that displays RAM and root disk usage and opens a details popup when clicked.

## Features

- RAM used/total and usage percentage.
- Root disk used/total and usage percentage.
- Popup details for available RAM, swap, free disk space, and the root mount.
- Five-second refresh interval.
- Uses `/proc/meminfo` and `df` only.
- No background service, network access, privileged command, or configuration overwrite.

## Install

Install from the repository root:

```sh
mkdir -p ~/.config/omarchy/plugins/io.github.johnboscocjt.ramdisk
cp manifest.json BarWidget.qml ~/.config/omarchy/plugins/io.github.johnboscocjt.ramdisk/
omarchy plugin validate ~/.config/omarchy/plugins/io.github.johnboscocjt.ramdisk
omarchy plugin enable io.github.johnboscocjt.ramdisk
omarchy bar move io.github.johnboscocjt.ramdisk --section left --index 2
omarchy restart shell
```

The widget is intended to appear after the menu and workspaces. Omarchy bar placement uses `omarchy bar move`; it does not currently provide freehand drag-and-drop for widgets.

## Remove

```sh
omarchy plugin disable io.github.johnboscocjt.ramdisk
rm -rf ~/.config/omarchy/plugins/io.github.johnboscocjt.ramdisk
omarchy restart shell
```

## Development

Validate the repository before submitting changes:

```sh
omarchy plugin validate .
qmllint -I "$OMARCHY_PATH/shell" BarWidget.qml
```

The plugin runs inside the existing Omarchy shell with the current user's permissions. Review the source before installing it.
