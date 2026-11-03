pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Caelestia palette (Material 3 roles), reloaded whenever caelestia rewrites scheme.json.
Singleton {
    id: root
    property var c: ({})
    function col(k, fb) { return "#" + (c[k] ?? fb) }

    readonly property color surface: col("surfaceContainer", "0b0506")
    readonly property color surfaceHigh: col("surfaceContainerHigh", "0e0708")
    readonly property color primary: col("primary", "ffb2bc")
    readonly property color onPrimary: col("onPrimary", "050203")
    readonly property color onSurface: col("onSurface", "f7e0e3")
    readonly property color onSurfaceVariant: col("onSurfaceVariant", "baa6a9")
    readonly property color outline: col("outlineVariant", "534447")

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/caelestia/scheme.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.c = JSON.parse(text()).colours
    }
}
