import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

// Mirrors caelestia's palette (scheme.json, camelCase, no '#') into the
// snake_case colors.json that inir's MaterialThemeLoader watches.
Scope {
    id: root

    readonly property string src: Quickshell.env("HOME") + "/.local/state/caelestia/scheme.json"
    readonly property string dir: Directories.stateUserPath + "/generated"

    function sync(): void {
        let c;
        try { c = JSON.parse(scheme.text()).colours; } catch (e) { return; }
        if (!c) return;
        const out = {};
        for (const k in c)
            out[k.replace(/[A-Z]/g, m => "_" + m.toLowerCase())] = "#" + c[k];
        out.background = out.background ?? out.surface;
        dest.setText(JSON.stringify(out, null, 2));
    }

    FileView {
        id: scheme
        path: root.src
        watchChanges: true
        onFileChanged: reload()
        onLoaded: mk.running = true
    }
    Process {
        id: mk
        command: ["mkdir", "-p", root.dir]
        onExited: root.sync()
    }
    FileView { id: dest; path: root.dir + "/colors.json"; printErrors: false }
}
