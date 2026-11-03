import QtQuick
import Quickshell
import ".."

Widget {
    key: "clock"
    cols: 2
    rows: 1
    SystemClock { id: clock; precision: SystemClock.Minutes }
    Column {
        anchors.centerIn: parent
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(clock.date, "HH:mm")
            color: Theme.primary
            font { pixelSize: 48; weight: Font.Medium }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(clock.date, "dddd d MMMM")
            color: Theme.onSurfaceVariant
            font.pixelSize: 14
        }
    }
}
