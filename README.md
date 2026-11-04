# caelestia_widgets

Desktop widgets (clock, weather, media, system monitor, day progress, ...) on top of the
caelestia-shell wallpaper, as a separate Quickshell config.

Based on iNiR by snowarch (https://github.com/snowarch/inir)

This is a modified version: the widget layer is vendored from iNiR (GPL-3.0, commit 48cdcec) and
patched as listed below. See `NOTICE` and `LICENSE`.

## Run

    qs -p /path/to/caelestia_widgets/shell.qml

Autostart and keybind live in `~/.config/hypr/hyprland/execs.lua` and `keybinds.lua`.

## What is ours, what is vendored

- `shell.qml`, `CaelestiaBridge.qml`: minimal host. The bridge converts caelestia's
  `~/.local/state/caelestia/scheme.json` into the colour file inir expects, live.
- `modules/`, `services/`, `defaults/`, `scripts/`, `assets/`, `translations/`: inir, with patches.

## Patches to the vendored code (all marked `patched` or `Neutralised`)

- Config/state go to `~/.config/caelestia-widgets/` and `~/.local/state/quickshell/caelestia-widgets/`,
  never to the illogical-impulse paths.
- `scripts/colors/*` that rewrite GTK/Qt/terminal/Spotify/Vesktop/browser themes are replaced by no-ops,
  and `IconThemeService._apply` returns early: this project must not touch system theming.
- `services/Notifications.qml`: the `NotificationServer` is a stub, so we never claim `org.freedesktop.Notifications`.
- `AbstractBackgroundWidget.qml`, `Background.qml`: drag only in edit mode, `ExclusionMode.Normal`, widgets sized from the window rather than the screen.
- `ShellLayoutController.qml`: insets come from `edgeInset`; free placement and zones share one work area.
- `AbstractBackgroundWidget.sanitizeValues`: every committed scale, size and position fits the work area.
- `Background.qml`: guard on `HyprlandData.windowList` being undefined at startup.
- `LiveLayer.qml`: the surface uses the host's exclusion mode, so both share an origin; it stays home
  while a widget stacked above overlaps it or a menu is open.
- `Wallpapers.qml`: reads caelestia's wallpaper path for glass and colour adaptation, without drawing it.
- `Idle.qml`: never starts `swayidle`; idle, locking and sleep stay with caelestia.
- `scripts/inir` always targets this checkout, never the running caelestia instance.
- `services/qmldir`: `HyprlandData` is declared as a singleton, as it is written (upstream omits it).
- Menu entries and buttons for a settings window, wallpaper selector or shell layout editor are removed:
  this shell has none of them. Locking goes to caelestia.
- Custom widgets live in `~/.config/caelestia-widgets/widgets/`.

## Enabling widgets

Edit `background.widgets.<name>.enable` and `x`/`y` in `~/.config/caelestia-widgets/config.json`
(hot-reloaded). All widgets are disabled by default.

## Edit mode

`SUPER + SHIFT + E` (or `qs -p shell.qml ipc call background toggleEditMode`) toggles inir's edit mode:
snap grid, resize handles, and the bottom toolbar (Add widgets, Grid size, Done). Click a widget to get its
options menu (Widget / Look / Arrange tabs).

Widgets are not draggable outside edit mode. The window uses `ExclusionMode.Normal`, so it follows whatever
space caelestia's bar and border reserve, and the grid, toolbar and widgets follow the window.

## The band around the edges

On a monitor with no windows, caelestia's drawers layer (above ours) extends its input region by its panels'
drag threshold (`dragMaskPadding` in `modules/drawers/ContentWindow.qml`, about 80 px) on every side, so the
pointer never reaches our layer there. Widgets and the grid stay out of that band through
`background.widgets.edgeInset` (default 80). If you lower caelestia's `dragThreshold` values, lower this too.

## Known gaps

- Only checked on Hyprland with two monitors; edit mode and drag were not exercised.
