# caelestia_widgets

Desktop widgets (clock, weather, media, system monitor, day progress, ...) on top of the
caelestia-shell wallpaper, as a separate Quickshell config.

The widget layer is vendored from [snowarch/iNiR](https://github.com/snowarch/iNiR)
(GPL-3.0, commit 48cdcec). See `NOTICE` and `LICENSE`.

## Run

    qs -p /path/to/caelestia_widgets/shell.qml

Autostart: `exec-once = qs -p /path/to/caelestia_widgets/shell.qml`

## What is ours, what is vendored

- `shell.qml`, `CaelestiaBridge.qml`: minimal host. The bridge converts caelestia's
  `~/.local/state/caelestia/scheme.json` into the colour file inir expects, live.
- `modules/`, `services/`, `defaults/`, `scripts/`, `assets/`, `translations/`: inir, with patches.

## Patches to the vendored code (all marked `patched` or `Neutralised`)

- Config/state go to `~/.config/caelestia-widgets/` and `~/.local/state/quickshell/caelestia-widgets/`,
  never to the illogical-impulse paths.
- `scripts/colors/*` that rewrite GTK/Qt/terminal/Spotify/Vesktop/browser themes are replaced by no-ops,
  and `IconThemeService._apply` returns early: this project must not touch system theming.
- `Background.qml`: guard on `HyprlandData.windowList` being undefined at startup.

## Enabling widgets

Edit `background.widgets.<name>.enable` and `x`/`y` in `~/.config/caelestia-widgets/config.json`
(hot-reloaded). All widgets are disabled by default.

## Known gaps

- inir's Notifications service tries to register the notification server (it fails while caelestia owns it).
- Only checked on Hyprland with two monitors; edit mode and drag were not exercised.
