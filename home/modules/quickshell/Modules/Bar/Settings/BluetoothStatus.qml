import QtQuick
import qs.Config
import qs.Components
import Quickshell.Bluetooth

Item {
    id: root
    implicitWidth: svgIcon.width
    implicitHeight: svgIcon.height
    readonly property var adapter: Bluetooth.defaultAdapter
    property bool enabled: adapter ? adapter.enabled : false
    property color iconColor: Colorscheme.gold

    SvgIcon {
        id: svgIcon
        color: root.iconColor
        source: "fa_bluetooth_b.svg"
        size: Size.settingsBoxIconSize
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }
}
