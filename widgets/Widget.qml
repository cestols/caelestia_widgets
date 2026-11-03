import QtQuick
import ".."

// Base card for every desktop widget: sits on the grid, drags with snap, remembers its cell.
// Usage: Widget { key: "clock"; cols: 2; rows: 1; defCol: 0; defRow: 0; <content> }
// Content children go inside and fill/anchor to the card.
Rectangle {
    id: w
    required property string key
    required property string screenName
    property int cols: 2
    property int rows: 1
    property int defCol: 0
    property int defRow: 0
    default property alias content: body.data

    readonly property var saved: Board.get(screenName, key)
    // Clamped so a saved cell never lands off-screen after a resolution change.
    readonly property int col: Math.max(0, Math.min(saved?.col ?? defCol, Board.cols(parent.width) - cols))
    readonly property int row: Math.max(0, Math.min(saved?.row ?? defRow, Board.rows(parent.height) - rows))
    property bool held: false
    property real dragX
    property real dragY

    width: cols * Board.step - Board.gap
    height: rows * Board.step - Board.gap
    x: held ? dragX : Board.margin + col * Board.step
    y: held ? dragY : Board.margin + row * Board.step
    radius: 24
    color: Theme.surface
    Behavior on x { enabled: !w.held; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on y { enabled: !w.held; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    // Snap to the nearest free cell block; if it overlaps another widget, stay where we were.
    function dropAt(c, r) {
        c = Math.max(0, Math.min(c, Board.cols(parent.width) - cols))
        r = Math.max(0, Math.min(r, Board.rows(parent.height) - rows))
        for (const o of parent.children) {
            if (o === w || o.key === undefined || o.cols === undefined) continue
            if (c < o.col + o.cols && o.col < c + cols && r < o.row + o.rows && o.row < r + rows) return
        }
        Board.set(screenName, key, c, r)
    }

    // Declared before the content so content MouseAreas (buttons) receive clicks first.
    MouseArea {
        anchors.fill: parent
        property real ox
        property real oy
        property bool moved: false
        onPressed: m => {
            ox = m.x; oy = m.y
            moved = false
            w.dragX = w.x; w.dragY = w.y
            w.held = true
            Board.dragging = true
        }
        onPositionChanged: m => {
            if (!pressed) return
            moved = true
            const p = mapToItem(w.parent, m.x, m.y)
            w.dragX = p.x - ox
            w.dragY = p.y - oy
        }
        onReleased: {
            if (moved) w.dropAt(Math.round((w.dragX - Board.margin) / Board.step),
                                Math.round((w.dragY - Board.margin) / Board.step))
            w.held = false
            Board.dragging = false
        }
        onCanceled: { w.held = false; Board.dragging = false }
    }

    Item { id: body; anchors.fill: parent }
}
