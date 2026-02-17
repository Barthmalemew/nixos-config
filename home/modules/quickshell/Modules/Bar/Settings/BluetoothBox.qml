import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.Config
import qs.Components

MouseArea {
    id: root
    width: Size.settingsBoxWidth
    height: Size.settingsBoxHeight
    cursorShape: Qt.PointingHandCursor

    readonly property var adapter: Bluetooth.defaultAdapter
    property bool enabled: adapter ? adapter.enabled : false
    property color background: enabled ? Colorscheme.pine : Colorscheme.overlay
    property color foreground: Colorscheme.text

    onClicked: {
        Quickshell.execDetached(["bluetoothctl", "power", root.enabled ? "off" : "on"]);
    }

    Rectangle {
        anchors.fill: parent
        radius: Size.borderRadiusLarge

        color: root.background

        SvgIcon {
            anchors.centerIn: parent
            source: "fa_bluetooth_b.svg"
            size: Size.settingsBoxIconSize
            color: root.foreground
        }
    }
}
