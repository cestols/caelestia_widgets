//@ pragma UseQApplication
//@ pragma ShellId caelestia-widgets
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
// Minimal host: only inir's desktop Background module, vendored from snowarch/iNiR (GPL-3.0).
import QtQuick
import Quickshell
import qs
import qs.modules.common
import qs.modules.background
import qs.services

ShellRoot {
    Component.onCompleted: { GlobalStates.shellEntryReady = true; GlobalStates.deferredPanelsReady = true }
    CaelestiaBridge {}
    Loader { active: Config.ready; sourceComponent: Background {} }
}
