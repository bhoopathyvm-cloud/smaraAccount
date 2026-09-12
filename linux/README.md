# Linux desktop icon

The runner embeds `assets/branding/app_icon.png` using
`glib-compile-resources` (provided by the GLib development tools). GTK loads
this resource for its window icon, so it does not depend on the working
directory or a separately installed PNG.

`flutter build linux` also puts desktop integration files in the bundle:

- `share/applications/com.smaraaccounting.smaraAccounting.desktop`
- `share/icons/hicolor/1024x1024/apps/com.smaraaccounting.smaraAccounting.png`

When packaging/installing, place these under the desktop's applications and
icon search locations, and make `smara_accounting` available on PATH (or set
an absolute installed executable path in the desktop entry). Wayland shells
use this installed desktop entry and matching application ID to show the
launcher icon; extracting the portable bundle alone does not install a menu
entry. GTK window-icon display also depends on the desktop/window manager.

Regenerate the shared artwork and other platforms' icons with:

```sh
python3 tool/branding/generate_app_icon.py
```
