import QtQuick
import Quickshell.Services.Mpris
import ".."

// Active MPRIS player: art, title/artist, progress, prev / play-pause / next.
Widget {
    id: root
    key: "media"
    cols: 3
    rows: 1

    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
    readonly property real progress: player && player.length > 0 ? Math.min(1, player.position / player.length) : 0

    // position is not a notifying property: poll it while playing.
    Timer {
        running: root.player?.isPlaying ?? false
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    Text {
        visible: !root.player
        anchors.centerIn: parent
        text: "Nothing playing"
        color: Theme.onSurfaceVariant
        font.pixelSize: 14
    }

    Row {
        visible: !!root.player
        anchors { fill: parent; margins: 12 }
        spacing: 12

        Rectangle {
            width: parent.height
            height: parent.height
            radius: 14
            color: Theme.surfaceHigh
            clip: true
            Image {
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
            }
        }

        Column {
            width: parent.width - parent.height - parent.spacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                width: parent.width
                text: root.player?.trackTitle || "Unknown"
                color: Theme.onSurface
                elide: Text.ElideRight
                font { pixelSize: 15; weight: Font.Medium }
            }
            Text {
                width: parent.width
                text: root.player?.trackArtist ?? ""
                color: Theme.onSurfaceVariant
                elide: Text.ElideRight
                font.pixelSize: 12
            }
            Rectangle {
                width: parent.width
                height: 4
                radius: 2
                color: Theme.outline
                Rectangle {
                    width: parent.width * root.progress
                    height: parent.height
                    radius: 2
                    color: Theme.primary
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Repeater {
                    model: [
                        { t: "⏮", main: false },
                        { t: root.player?.isPlaying ? "⏸" : "▶", main: true },
                        { t: "⏭", main: false }
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: 28; height: 28; radius: 14
                        color: modelData.main ? Theme.primary : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: modelData.t
                            color: modelData.main ? Theme.onPrimary : Theme.onSurface
                            font.pixelSize: 14
                        }
                        // Own MouseArea above the Widget's drag area.
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                const p = root.player
                                if (!p) return
                                if (index === 0) p.previous()
                                else if (index === 1) p.togglePlaying()
                                else p.next()
                            }
                        }
                    }
                }
            }
        }
    }
}
