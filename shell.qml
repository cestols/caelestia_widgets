import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    property var pos: ({})        // screen name -> {x, y}
    property var c: ({})          // caelestia palette, hex without '#'
    function col(k, fb) { return "#" + (c[k] ?? fb) }

    FileView {
        id: posFile
        path: Quickshell.statePath("positions.json")
        printErrors: false
        onLoaded: root.pos = JSON.parse(text() || "{}")
    }

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/caelestia/scheme.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.c = JSON.parse(text()).colours
    }

    SystemClock { id: clock; precision: SystemClock.Minutes }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "caelestia-widgets"
            mask: Region { item: card }   // only the widget takes clicks

            Rectangle {
                id: card
                width: 220; height: 110; radius: 24
                color: root.col("surfaceContainer", "0b0506")
                x: root.pos[modelData.name]?.x ?? 80
                y: root.pos[modelData.name]?.y ?? 80

                Column {
                    anchors.centerIn: parent
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatTime(clock.date, "HH:mm")
                        color: root.col("primary", "ffb2bc")
                        font { pixelSize: 48; weight: Font.Medium }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDate(clock.date, "dddd d MMMM")
                        color: root.col("onSurfaceVariant", "baa6a9")
                        font.pixelSize: 14
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    drag.target: card
                    drag.minimumX: 0; drag.maximumX: parent.parent.width - card.width
                    drag.minimumY: 0; drag.maximumY: parent.parent.height - card.height
                    onReleased: {
                        const p = Object.assign({}, root.pos)
                        p[modelData.name] = { x: card.x, y: card.y }
                        root.pos = p
                        posFile.setText(JSON.stringify(p))
                    }
                }
            }
        }
    }
}
