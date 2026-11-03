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
    readonly property int col: saved?.col ?? defCol
    readonly property int row: saved?.row ?? defRow
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

    Item { id: body; anchors.fill: parent }

    MouseArea {
        anchors.fill: parent
        property real ox
        property real oy
        onPressed: m => {
            ox = m.x; oy = m.y
            w.dragX = w.x; w.dragY = w.y
            w.held = true
            Board.dragging = true
        }
        onPositionChanged: m => {
            if (!pressed) return
            const p = mapToItem(w.parent, m.x, m.y)
            w.dragX = p.x - ox
            w.dragY = p.y - oy
        }
        onReleased: {
            const c = Math.round((w.dragX - Board.margin) / Board.step)
            const r = Math.round((w.dragY - Board.margin) / Board.step)
            const maxC = Board.cols(w.parent.width) - w.cols
            const maxR = Board.rows(w.parent.height) - w.rows
            Board.set(w.screenName, w.key, Math.max(0, Math.min(c, maxC)), Math.max(0, Math.min(r, maxR)))
            w.held = false
            Board.dragging = false
        }
    }
}
