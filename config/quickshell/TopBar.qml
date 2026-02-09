import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "theme" as Theme

Scope {
    id: root
    property var screen

    Theme.Colors { id: colors }

    PanelWindow {
        screen: root.screen
        anchors { top: true; left: true; right: true }
        implicitHeight: 32 * colors.scale
        color: colors.panelBg
        
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusionMode: ExclusionMode.Exclusive

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12 * colors.scale
            anchors.rightMargin: 12 * colors.scale

            Text {
                text: "UNIT_02 // ONLINE"
                color: colors.color1
                font.pixelSize: 12 * colors.scale
                font.weight: 900
                font.family: "JetBrainsMono Nerd Font"
            }

            Item { Layout.fillWidth: true }

            Text {
                text: Qt.formatDateTime(new Date(), "HH:mm")
                color: colors.foreground
                font.pixelSize: 12 * colors.scale
                font.weight: 700
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }
}
