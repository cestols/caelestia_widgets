import QtQuick
import "."

// Dot grid shown while a widget is being dragged.
Item {
    anchors.fill: parent
    opacity: Board.dragging ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    Repeater {
        model: Board.cols(width) * Board.rows(height)
        Rectangle {
            required property int index
            readonly property int n: Board.cols(parent.width)
            width: Board.cell; height: Board.cell; radius: 16
            x: Board.margin + (index % n) * Board.step
            y: Board.margin + Math.floor(index / n) * Board.step
            color: "transparent"
            border { width: 1; color: Theme.outline }
        }
    }
}
