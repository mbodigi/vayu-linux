// Notification popups, stacked in the top-right corner under the bar.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"

PanelWindow {
    id: root

    visible: Notifs.popups.length > 0 && !Notifs.centerOpen
    color: "transparent"
    readonly property bool atBottom: Settings.get("barPosition") === "bottom"
    anchors { top: !atBottom; bottom: atBottom; right: true }
    margins { top: 6; bottom: 6; right: 8 }
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "shell-notifications"
    implicitWidth: 380
    implicitHeight: stack.implicitHeight

    Column {
        id: stack
        spacing: 8

        Repeater {
            model: Notifs.popups

            NotifCard {
                required property var modelData
                notif: modelData
                popup: true
                onHidden: Notifs.dismissPopup(modelData)
            }
        }
    }
}
