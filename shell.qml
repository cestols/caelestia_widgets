import QtQuick
import Quickshell
import Quickshell.Wayland
import "widgets"

ShellRoot {
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

            // Add one Region per widget below: only widgets take clicks, the rest falls through.
            mask: Region {
                Region { item: clock }
                Region { item: media }
                Region { item: sysmon }
            }

            DotGrid {}
            Clock { id: clock; screenName: modelData.name }
            MediaControls { id: media; screenName: modelData.name; defCol: 2 }
            SystemMonitor { id: sysmon; screenName: modelData.name; defRow: 1 }
        }
    }
}
