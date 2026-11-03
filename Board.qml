pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Shared grid geometry + persisted widget cells ("<screen>/<key>" -> {col, row}).
Singleton {
    id: root
    readonly property int cell: 96
    readonly property int gap: 12
    readonly property int margin: 24
    readonly property int step: cell + gap
    property bool dragging: false
    property var cells: ({})

    function cols(w) { return Math.max(1, Math.floor((w - 2 * margin + gap) / step)) }
    function rows(h) { return Math.max(1, Math.floor((h - 2 * margin + gap) / step)) }
    function get(screen, key) { return cells[screen + "/" + key] }
    function set(screen, key, col, row) {
        const n = Object.assign({}, cells)
        n[screen + "/" + key] = { col: col, row: row }
        cells = n
        file.setText(JSON.stringify(n))
    }

    FileView {
        id: file
        path: Quickshell.statePath("cells.json")
        printErrors: false
        onLoaded: root.cells = JSON.parse(text() || "{}")
    }
}
