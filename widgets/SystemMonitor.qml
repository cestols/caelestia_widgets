import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// CPU / RAM / disk (/) bars, refreshed every 2 s. Layout idea from iNiR's systemMonitor "bars" mode.
Widget {
    key: "sysmon"
    cols: 2
    rows: 2

    property real cpu: 0
    property real ram: 0
    property real disk: 0
    property string ramText: ""
    property string diskText: ""
    property var prev: null

    function gib(kb) { return (kb / 1048576).toFixed(1) }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { stat.reload(); mem.reload(); df.running = true }
    }

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const f = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number)
            const idle = f[3] + f[4]
            const total = f.reduce((a, b) => a + b, 0)
            if (prev && total > prev[1]) cpu = 1 - (idle - prev[0]) / (total - prev[1])
            prev = [idle, total]
        }
    }

    FileView {
        id: mem
        path: "/proc/meminfo"
        onLoaded: {
            const t = text()
            const total = parseInt(t.match(/MemTotal:\s+(\d+)/)[1])
            const used = total - parseInt(t.match(/MemAvailable:\s+(\d+)/)[1])
            ram = used / total
            ramText = gib(used) + " / " + gib(total) + " GiB"
        }
    }

    Process {
        id: df
        command: ["df", "-k", "--output=used,size", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = text.trim().split("\n")[1]?.trim().split(/\s+/).map(Number)
                if (!v || !v[1]) return
                disk = v[0] / v[1]
                diskText = gib(v[0]) + " / " + gib(v[1]) + " GiB"
            }
        }
    }

    Column {
        anchors { fill: parent; margins: 16 }
        spacing: 12

        Repeater {
            model: [
                { name: "CPU", v: cpu, sub: Math.round(cpu * 100) + "%" },
                { name: "RAM", v: ram, sub: ramText },
                { name: "Disk", v: disk, sub: diskText }
            ]
            delegate: Column {
                required property var modelData
                width: parent.width
                spacing: 4
                Item {
                    width: parent.width; height: label.height
                    Text { id: label; text: modelData.name; color: Theme.onSurface; font { pixelSize: 14; weight: Font.Medium } }
                    Text {
                        anchors.right: parent.right
                        text: modelData.sub; color: Theme.onSurfaceVariant; font.pixelSize: 12
                    }
                }
                Rectangle {
                    width: parent.width; height: 8; radius: 4; color: Theme.surfaceHigh
                    border { color: Theme.outline; width: 1 }
                    Rectangle {
                        width: Math.max(8, parent.width * Math.min(1, Math.max(0, modelData.v)))
                        height: parent.height; radius: 4; color: Theme.primary
                        Behavior on width { NumberAnimation { duration: 300 } }
                    }
                }
            }
        }
    }
}
